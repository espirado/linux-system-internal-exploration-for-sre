package config

import (
	"os"
	"time"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Server   ServerConfig   `yaml:"server"`
	Database DatabaseConfig `yaml:"database"`
	Redis    RedisConfig    `yaml:"redis"`
	Metrics  MetricsConfig  `yaml:"metrics"`
	Debug    DebugConfig    `yaml:"debug"`
}

type ServerConfig struct {
	Address         string        `yaml:"address"`
	ReadTimeout     time.Duration `yaml:"readTimeout"`
	WriteTimeout    time.Duration `yaml:"writeTimeout"`
	IdleTimeout     time.Duration `yaml:"idleTimeout"`
	ShutdownTimeout time.Duration `yaml:"shutdownTimeout"`
}

type DatabaseConfig struct {
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	User     string `yaml:"user"`
	Password string `yaml:"password"`
	DBName   string `yaml:"dbname"`
	SSLMode  string `yaml:"sslmode"`
}

type RedisConfig struct {
	Address  string `yaml:"address"`
	Password string `yaml:"password"`
	DB       int    `yaml:"db"`
}

type MetricsConfig struct {
	EnableProfiling bool `yaml:"enableProfiling"`
	EnableTracing   bool `yaml:"enableTracing"`
}

type DebugConfig struct {
	Enabled bool `yaml:"enabled"`
}

// Load loads configuration from file and environment variables
func Load() (*Config, error) {
	// Default configuration
	config := &Config{
		Server: ServerConfig{
			Address:         ":8080",
			ReadTimeout:     15 * time.Second,
			WriteTimeout:    15 * time.Second,
			IdleTimeout:     60 * time.Second,
			ShutdownTimeout: 30 * time.Second,
		},
	}

	// Load from file if exists
	if configFile := os.Getenv("CONFIG_FILE"); configFile != "" {
		f, err := os.Open(configFile)
		if err != nil {
			return nil, err
		}
		defer f.Close()

		decoder := yaml.NewDecoder(f)
		if err := decoder.Decode(config); err != nil {
			return nil, err
		}
	}

	// Override with environment variables
	if addr := os.Getenv("SERVER_ADDRESS"); addr != "" {
		config.Server.Address = addr
	}

	// Database configuration from environment
	if dbHost := os.Getenv("DB_HOST"); dbHost != "" {
		config.Database.Host = dbHost
	}

	return config, nil
}
