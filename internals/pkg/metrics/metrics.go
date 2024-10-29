package metrics

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

type Metrics struct {
	GoroutineLeaks      prometheus.Counter
	MemoryLeaks         prometheus.Counter
	CPUUtilization      prometheus.Counter
	FileDescriptorLeaks prometheus.Counter
	NetworkConnections  prometheus.Counter
	DBConnections       prometheus.Counter
}

func NewMetrics() *Metrics {
	return &Metrics{
		GoroutineLeaks: promauto.NewCounter(prometheus.CounterOpts{
			Name: "sre_goroutine_leaks_total",
			Help: "Total number of goroutines leaked",
		}),
		MemoryLeaks: promauto.NewCounter(prometheus.CounterOpts{
			Name: "sre_memory_leaks_bytes_total",
			Help: "Total bytes of memory leaked",
		}),
		CPUUtilization: promauto.NewCounter(prometheus.CounterOpts{
			Name: "sre_cpu_burn_instances_total",
			Help: "Total number of CPU burn instances",
		}),
		FileDescriptorLeaks: promauto.NewCounter(prometheus.CounterOpts{
			Name: "sre_file_descriptor_leaks_total",
			Help: "Total number of file descriptors leaked",
		}),
		NetworkConnections: promauto.NewCounter(prometheus.CounterOpts{
			Name: "sre_network_flood_connections_total",
			Help: "Total number of flooding network connections",
		}),
		DBConnections: promauto.NewCounter(prometheus.CounterOpts{
			Name: "sre_db_connection_leaks_total",
			Help: "Total number of leaked database connections",
		}),
	}
}
