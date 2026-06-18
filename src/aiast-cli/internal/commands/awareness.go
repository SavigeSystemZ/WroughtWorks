package commands

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// RunCheckAwareness runs the system awareness and boundary checks purely in Go.
// This replaces check-system-awareness.sh
func RunCheckAwareness(args []string) bool {
	targetRepo := "."
	if len(args) > 0 {
		targetRepo = args[0]
	}

	absTarget, err := filepath.Abs(targetRepo)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error resolving target repo path: %v\n", err)
		return false
	}

	registryPath := filepath.Join(absTarget, "_system", "SYSTEM_REGISTRY.json")
	
	// 1. Check if registry exists
	if _, err := os.Stat(registryPath); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "[FAIL] Missing system registry: %s. Regenerate with generate-system-registry.sh (aiast sync).\n", "_system/SYSTEM_REGISTRY.json")
		return false
	}

	// 2. Load registry
	registryData, err := os.ReadFile(registryPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "[FAIL] Could not read registry: %v\n", err)
		return false
	}

	var registry struct {
		Entries []struct {
			Path string `json:"path"`
		} `json:"entries"`
	}

	if err := json.Unmarshal(registryData, &registry); err != nil {
		fmt.Fprintf(os.Stderr, "[FAIL] Corrupt system registry: %v. Regenerate with generate-system-registry.sh (aiast sync).\n", err)
		return false
	}

	// 3. Verify registry files exist physically
	allPassed := true
	for _, entry := range registry.Entries {
		filePath := filepath.Join(absTarget, entry.Path)
		if _, err := os.Stat(filePath); os.IsNotExist(err) {
			fmt.Fprintf(os.Stderr, "[FAIL] Registry references missing file: %s\n", entry.Path)
			allPassed = false
		}
	}

	// 4. Boundary check for absolute paths bleeding into system docs
	fmt.Println("Running absolute path boundary leak scan...")
	
	docsToScan := []string{
		filepath.Join(absTarget, "_system", "MASTER_SYSTEM_PROMPT.md"),
		filepath.Join(absTarget, "_system", "CONTEXT_INDEX.md"),
		filepath.Join(absTarget, "README.md"),
	}

	// Regex to detect "file:///" or "/home/"
	absPathRegex := regexp.MustCompile(`(file:///|/home/\w+)`)

	for _, docPath := range docsToScan {
		if _, err := os.Stat(docPath); os.IsNotExist(err) {
			continue // Skip if missing
		}

		content, err := os.ReadFile(docPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "[WARN] Could not read %s for absolute path scan\n", filepath.Base(docPath))
			continue
		}

		lines := strings.Split(string(content), "\n")
		for i, line := range lines {
			if absPathRegex.MatchString(line) {
				fmt.Fprintf(os.Stderr, "[FAIL] Absolute path boundary leak detected in %s on line %d: %s\n", filepath.Base(docPath), i+1, strings.TrimSpace(line))
				allPassed = false
			}
		}
	}

	if allPassed {
		fmt.Println("[PASS] System awareness and boundary checks clean.")
	} else {
		fmt.Fprintln(os.Stderr, "[FAIL] System awareness checks failed.")
	}

	return allPassed
}
