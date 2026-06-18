package commands

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// RunValidate is the entry point for the "aiast validate" command.
// Phase 2 transition: Currently wraps legacy bash validation scripts.
// Future iterations will port the raw bash logic into native Go functions.
func RunValidate(args []string) {
	fmt.Println("================================================================")
	fmt.Println("AIAST Meta-System Validation (Go Orchestrator)")
	fmt.Println("================================================================")

	targetRepo := "."
	if len(args) > 0 {
		targetRepo = args[0]
	}

	absTarget, err := filepath.Abs(targetRepo)
	if err != nil {
		fmt.Printf("Error resolving target repo path: %v\n", err)
		os.Exit(1)
	}

	bootstrapDir := filepath.Join(absTarget, "bootstrap")
	
	scriptsToRun := []string{}

	allPassed := true

	for _, script := range scriptsToRun {
		scriptPath := filepath.Join(bootstrapDir, script)
		
		if _, err := os.Stat(scriptPath); os.IsNotExist(err) {
			fmt.Printf("[SKIP] %s not found in bootstrap directory\n", script)
			continue
		}

		fmt.Printf("\n--- Running %s ---\n", script)
		cmd := exec.Command("bash", scriptPath, absTarget)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		
		err := cmd.Run()
		if err != nil {
			fmt.Printf("[FAIL] %s failed: %v\n", script, err)
			allPassed = false
		} else {
			fmt.Printf("[PASS] %s completed successfully\n", script)
		}
	}

	fmt.Println("\n--- Running check-host-adapter-alignment (Native Go) ---")
	if !RunCheckAlignment(args) {
		allPassed = false
	}

	fmt.Println("\n--- Running check-agent-surface-integrity (Native Go) ---")
	if !RunCheckIntegrity(args) {
		allPassed = false
	}

	fmt.Println("\n--- Running validate-instruction-layer (Native Go) ---")
	if !RunValidateInstructionLayer(args) {
		allPassed = false
	}

	fmt.Println("\n--- Running check-system-awareness (Native Go) ---")
	if !RunCheckAwareness(args) {
		allPassed = false
	}

	fmt.Println("\n================================================================")
	if allPassed {
		fmt.Println("Validation Result: SUCCESS")
		os.Exit(0)
	} else {
		fmt.Println("Validation Result: FAILURE")
		os.Exit(1)
	}
}
