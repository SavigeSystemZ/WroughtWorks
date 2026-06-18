package commands

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// RunDoctor is the entry point for the "aiast doctor" command.
// Phase 2 transition: Currently wraps legacy system-doctor.sh checks.
func RunDoctor(args []string) {
	doctorCmd := flag.NewFlagSet("doctor", flag.ExitOnError)
	heal := doctorCmd.Bool("heal", false, "Attempt safe automatic recovery first")
	report := doctorCmd.Bool("report", false, "Generate a full diagnostic report")
	record := doctorCmd.Bool("record", false, "Append result to _system/health-history.json")
	strict := doctorCmd.Bool("strict", false, "Run strict validation")
	
	doctorCmd.Parse(args)

	targetRepo := "."
	if len(doctorCmd.Args()) > 0 {
		targetRepo = doctorCmd.Args()[0]
	}

	absTarget, err := filepath.Abs(targetRepo)
	if err != nil {
		fmt.Printf("Error resolving target repo path: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("================================================================")
	fmt.Println("AIAST System Doctor (Go Orchestrator)")
	fmt.Printf("Target: %s\n", absTarget)
	fmt.Printf("Heal: %v | Report: %v | Record: %v | Strict: %v\n", *heal, *report, *record, *strict)
	fmt.Println("================================================================")

	bootstrapDir := filepath.Join(absTarget, "bootstrap")

	if *heal {
		fmt.Println("\n--- Running Heal Operations ---")
		healScripts := []string{"repair-safe-permission-drift.sh", "sync-metasystem-contracts.sh"}
		for _, script := range healScripts {
			runScript(filepath.Join(bootstrapDir, script), absTarget)
		}
	}

	fmt.Println("\n--- Running Health Checks ---")
	checkScripts := []string{
		"check-git-discipline.sh",
		"check-context-isolation.sh",
	}

	allPassed := true
	for _, script := range checkScripts {
		if !runScript(filepath.Join(bootstrapDir, script), absTarget) {
			allPassed = false
		}
	}

	fmt.Println("\n--- Running check-host-adapter-alignment (Native Go) ---")
	if !RunCheckAlignment([]string{absTarget}) {
		allPassed = false
	}

	fmt.Println("\n--- Running check-agent-surface-integrity (Native Go) ---")
	if !RunCheckIntegrity([]string{absTarget}) {
		allPassed = false
	}

	fmt.Println("\n--- Running validate-instruction-layer (Native Go) ---")
	if !RunValidateInstructionLayer([]string{absTarget}) {
		allPassed = false
	}

	fmt.Println("\n--- Running check-system-awareness (Native Go) ---")
	if !RunCheckAwareness([]string{absTarget}) {
		allPassed = false
	}

	fmt.Println("\n================================================================")
	if allPassed {
		fmt.Println("Doctor Diagnosis: HEALTHY")
		if *record {
			fmt.Println("[Not Implemented] Would record success to health-history.json")
		}
		os.Exit(0)
	} else {
		fmt.Println("Doctor Diagnosis: SICK (See logs above)")
		if *record {
			fmt.Println("[Not Implemented] Would record failure to health-history.json")
		}
		os.Exit(1)
	}
}

func runScript(scriptPath, target string) bool {
	if _, err := os.Stat(scriptPath); os.IsNotExist(err) {
		fmt.Printf("[SKIP] %s not found\n", filepath.Base(scriptPath))
		return true // Treat missing as skip for now
	}

	fmt.Printf("Executing %s...\n", filepath.Base(scriptPath))
	cmd := exec.Command("bash", scriptPath, target)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	err := cmd.Run()
	if err != nil {
		fmt.Printf("[FAIL] %s\n", filepath.Base(scriptPath))
		return false
	}
	fmt.Printf("[PASS] %s\n", filepath.Base(scriptPath))
	return true
}
