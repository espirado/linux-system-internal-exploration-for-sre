package cleanup

import (
	"os"
	"path/filepath"
	"runtime"
	"runtime/debug"
)

// Cleanup performs emergency cleanup operations
func Cleanup() error {
	// Force garbage collection
	runtime.GC()
	debug.FreeOSMemory()

	// Clean up temporary files
	err := filepath.Walk("/tmp", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.Name() == "leak-" {
			return os.Remove(path)
		}
		return nil
	})

	return err
}
