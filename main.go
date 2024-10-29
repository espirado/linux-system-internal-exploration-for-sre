package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/espirado/linux-system-internal-exploration-for-sre/internal/app/config"
	"github.com/espirado/linux-system-internal-exploration-for-sre/internal/app/handlers"
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Application version
const version = "1.0.0"

func main() {
	// Initialize logger
	logger := log.New(os.Stdout, "[SRE-APP] ", log.LstdFlags|log.Lshortfile)

	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		logger.Fatalf("Failed to load configuration: %v", err)
	}

	// Create router
	router := mux.NewRouter()

	// Initialize handlers
	h := handlers.NewHandler(cfg, logger)

	// Register routes
	registerRoutes(router, h)

	// Create server
	srv := &http.Server{
		Addr:         cfg.Server.Address,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in goroutine
	go func() {
		logger.Printf("Starting server on %s", cfg.Server.Address)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	logger.Println("Shutting down server...")

	// Create shutdown context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Attempt graceful shutdown
	if err := srv.Shutdown(ctx); err != nil {
		logger.Fatalf("Server forced to shutdown: %v", err)
	}

	logger.Println("Server exited properly")
}

func registerRoutes(router *mux.Router, h *handlers.Handler) {
	// API Routes
	api := router.PathPrefix("/api/v1").Subrouter()

	// Health and version endpoints
	api.HandleFunc("/health", h.HealthCheck).Methods(http.MethodGet)
	api.HandleFunc("/version", h.Version).Methods(http.MethodGet)

	// Problem simulation endpoints
	problems := api.PathPrefix("/problems").Subrouter()
	problems.HandleFunc("/goroutine-leak", h.GoroutineLeak).Methods(http.MethodPost)
	problems.HandleFunc("/memory-leak", h.MemoryLeak).Methods(http.MethodPost)
	problems.HandleFunc("/cpu-burn", h.CPUBurn).Methods(http.MethodPost)
	problems.HandleFunc("/io-flood", h.IOFlood).Methods(http.MethodPost)

	// Metrics endpoint
	router.Handle("/metrics", promhttp.Handler())

	// Debug endpoints (only in development)
	if os.Getenv("ENV") == "development" {
		debug := router.PathPrefix("/debug").Subrouter()
		debug.HandleFunc("/goroutines", h.GoroutinesDump).Methods(http.MethodGet)
		debug.HandleFunc("/heap", h.HeapDump).Methods(http.MethodGet)
	}
}
