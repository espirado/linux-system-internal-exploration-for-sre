module github.com/yourusername/linux-system-internal-exploration-for-sre

go 1.21

require (
    // Core HTTP routing and middleware
    github.com/gorilla/mux v1.8.1
    
    // Database drivers
    github.com/lib/pq v1.10.9                // PostgreSQL driver
    github.com/redis/go-redis/v9 v9.3.0      // Redis client
    
    // Observability and metrics
    github.com/prometheus/client_golang v1.17.0  // Prometheus metrics
    go.opentelemetry.io/otel v1.21.0            // OpenTelemetry for tracing
    go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.21.0
    
    // Logging and error handling
    github.com/sirupsen/logrus v1.9.3         // Structured logging
    
    // Configuration management
    github.com/spf13/viper v1.18.2            // Configuration management
    
    // System metrics and profiling
    github.com/shirou/gopsutil/v3 v3.23.11    // System and process metrics
    
    // Testing
    github.com/stretchr/testify v1.8.4        // Testing assertions
)