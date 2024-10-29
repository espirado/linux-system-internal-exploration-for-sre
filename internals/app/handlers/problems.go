package handlers

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"sync"
	"time"

	"github.com/espirado/linux-system-internal-exploration-for-sre/internal/pkg/metrics"
)

type Handler struct {
	logger  *log.Logger
	config  *config.Config
	metrics *metrics.Metrics
	// Channels to control stress tests
	stressCtrl chan struct{}
	// Global variables for memory leaks
	leakySlice []string
	leakyMutex sync.Mutex
	// Map to track goroutine leaks
	leakyGoroutines sync.WaitGroup
}

// NewHandler creates a new handler instance
func NewHandler(cfg *config.Config, logger *log.Logger) *Handler {
	return &Handler{
		logger:     logger,
		config:     cfg,
		metrics:    metrics.NewMetrics(),
		stressCtrl: make(chan struct{}),
		leakySlice: make([]string, 0),
	}
}

// GoroutineLeak simulates a goroutine leak
func (h *Handler) GoroutineLeak(w http.ResponseWriter, r *http.Request) {
	h.logger.Printf("Starting goroutine leak simulation")

	// Start leaking goroutines
	for i := 0; i < 100; i++ {
		h.leakyGoroutines.Add(1)
		go func(id int) {
			defer h.leakyGoroutines.Done()
			h.logger.Printf("Goroutine %d started", id)
			select {} // This goroutine will never exit
		}(i)
	}

	h.metrics.GoroutineLeaks.Add(100)
	fmt.Fprintf(w, "Started 100 leaking goroutines\n")
}

// MemoryLeak simulates a memory leak
func (h *Handler) MemoryLeak(w http.ResponseWriter, r *http.Request) {
	h.logger.Printf("Starting memory leak simulation")

	h.leakyMutex.Lock()
	defer h.leakyMutex.Unlock()

	// Create large strings and store them
	for i := 0; i < 1000; i++ {
		data := make([]byte, 1024*1024) // 1MB
		h.leakySlice = append(h.leakySlice, string(data))
	}

	h.metrics.MemoryLeaks.Add(float64(1000 * 1024 * 1024))
	fmt.Fprintf(w, "Leaked approximately 1000MB of memory\n")
}

// CPUBurn simulates high CPU usage
func (h *Handler) CPUBurn(w http.ResponseWriter, r *http.Request) {
	h.logger.Printf("Starting CPU burn simulation")

	numCPU := runtime.NumCPU()
	duration := 30 * time.Second

	// Start CPU-intensive tasks
	for i := 0; i < numCPU; i++ {
		go func() {
			start := time.Now()
			for time.Since(start) < duration {
				// Perform meaningless calculations
				for j := 0; j < 1000000; j++ {
					_ = j * j
				}
			}
		}()
	}

	h.metrics.CPUUtilization.Inc()
	fmt.Fprintf(w, "Started CPU burn on %d cores for %v\n", numCPU, duration)
}

// FileDescriptorLeak simulates file descriptor leaks
func (h *Handler) FileDescriptorLeak(w http.ResponseWriter, r *http.Request) {
	h.logger.Printf("Starting file descriptor leak simulation")

	// Create temporary files without closing them
	for i := 0; i < 100; i++ {
		fileName := fmt.Sprintf("/tmp/leak-%d.tmp", i)
		_, err := os.OpenFile(fileName, os.O_RDWR|os.O_CREATE, 0666)
		if err != nil {
			h.logger.Printf("Error creating file: %v", err)
			continue
		}
		// Intentionally not closing the file
	}

	h.metrics.FileDescriptorLeaks.Add(100)
	fmt.Fprintf(w, "Leaked 100 file descriptors\n")
}

// NetworkFlood simulates network congestion
func (h *Handler) NetworkFlood(w http.ResponseWriter, r *http.Request) {
	h.logger.Printf("Starting network flood simulation")

	// Start multiple goroutines making HTTP requests
	for i := 0; i < 100; i++ {
		go func() {
			for {
				select {
				case <-h.stressCtrl:
					return
				default:
					// Make HTTP requests to localhost
					_, _ = http.Get("http://localhost:8080/health")
					time.Sleep(10 * time.Millisecond)
				}
			}
		}()
	}

	h.metrics.NetworkConnections.Add(100)
	fmt.Fprintf(w, "Started 100 connections flooding the network\n")
}

// DBConnectionLeak simulates database connection leaks
func (h *Handler) DBConnectionLeak(w http.ResponseWriter, r *http.Request) {
	h.logger.Printf("Starting DB connection leak simulation")

	// Create multiple database connections without proper pooling
	for i := 0; i < 50; i++ {
		go func() {
			db, err := sql.Open("postgres", h.config.Database.DSN)
			if err != nil {
				h.logger.Printf("Error opening DB connection: %v", err)
				return
			}
			// Intentionally not closing the connection

			// Execute a slow query
			_, _ = db.Exec("SELECT pg_sleep(30)")
		}()
	}

	h.metrics.DBConnections.Add(50)
	fmt.Fprintf(w, "Leaked 50 database connections\n")
}
