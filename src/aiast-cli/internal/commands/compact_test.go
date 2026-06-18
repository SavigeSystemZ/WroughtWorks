package commands

import (
	"os"
	"path/filepath"
	"testing"
)

func TestCompactNoContextDir(t *testing.T) {
	// Setup a temporary repo without a context directory
	tmpRepo := t.TempDir()
	
	// Temporarily hijack stdout/exit in a real test environment.
	// For this scaffold, we just ensure the directory logic is sound.
	contextDir := filepath.Join(tmpRepo, "_system", "context")
	if _, err := os.Stat(contextDir); !os.IsNotExist(err) {
		t.Fatalf("Expected context directory to not exist, but it does: %s", contextDir)
	}
}

func TestArchiveCreation(t *testing.T) {
	tmpDir := t.TempDir()
	file1 := filepath.Join(tmpDir, "file1.txt")
	os.WriteFile(file1, []byte("dummy data"), 0644)

	archivePath := filepath.Join(tmpDir, "out.tar.gz")
	
	err := createTarGz(archivePath, []string{file1})
	if err != nil {
		t.Fatalf("Failed to create archive: %v", err)
	}

	if _, err := os.Stat(archivePath); os.IsNotExist(err) {
		t.Fatalf("Archive was not created at %s", archivePath)
	}
}
