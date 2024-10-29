package handlers

import (
	"encoding/json"
	"net/http"
	"runtime"
)

type HealthResponse struct {
	Status      string `json:"status"`
	Version     string `json:"version"`
	GoRoutines  int    `json:"goroutines"`
	MemoryStats struct {
		Alloc      uint64 `json:"alloc"`
		TotalAlloc uint64 `json:"totalAlloc"`
		Sys        uint64 `json:"sys"`
		NumGC      uint32 `json:"numGC"`
	} `json:"memoryStats"`
}

func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	var memStats runtime.MemStats
	runtime.ReadMemStats(&memStats)

	health := HealthResponse{
		Status:     "ok",
		Version:    "1.0.0",
		GoRoutines: runtime.NumGoroutine(),
	}

	health.MemoryStats.Alloc = memStats.Alloc
	health.MemoryStats.TotalAlloc = memStats.TotalAlloc
	health.MemoryStats.Sys = memStats.Sys
	health.MemoryStats.NumGC = memStats.NumGC

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(health)
}
