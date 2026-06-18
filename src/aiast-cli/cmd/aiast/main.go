package main

import (
	"fmt"
	"os"

	"aiast-cli/internal/commands"
)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	command := os.Args[1]
	args := os.Args[2:]

	switch command {
	case "compact":
		commands.RunCompact(args)
	case "doctor":
		commands.RunDoctor(args)
	case "validate":
		commands.RunValidate(args)
	case "check-awareness":
		success := commands.RunCheckAwareness(args)
		if !success {
			os.Exit(1)
		}
	case "check-alignment":
		success := commands.RunCheckAlignment(args)
		if !success {
			os.Exit(1)
		}
	case "check-integrity":
		success := commands.RunCheckIntegrity(args)
		if !success {
			os.Exit(1)
		}
	case "check-validate-layer":
		success := commands.RunValidateInstructionLayer(args)
		if !success {
			os.Exit(1)
		}
	case "check-bootstrap-permissions":
		success := commands.RunCheckBootstrapPermissions(args)
		if !success {
			os.Exit(1)
		}
	case "check-install-boundary":
		success := commands.RunCheckInstallBoundary(args)
		if !success {
			os.Exit(1)
		}
	case "check-agent-orchestration":
		success := commands.RunCheckAgentOrchestration(args)
		if !success {
			os.Exit(1)
		}
	case "check-evidence-quality":
		success := commands.RunCheckEvidenceQuality(args)
		if !success {
			os.Exit(1)
		}
	case "check-repo-permissions":
		success := commands.RunCheckRepoPermissions(args)
		if !success {
			os.Exit(1)
		}
	default:
		fmt.Printf("Unknown command: %s\n", command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println("AIAST Meta-System CLI (lean validator accelerator)")
	fmt.Println("Usage: aiast <command> [target-repo] [options]")
	fmt.Println("\nThis binary is an OPTIONAL, dependency-free accelerator for the")
	fmt.Println("validation layer. Operational commands (init, scaffold, gitops, swarm,")
	fmt.Println("locks) live in pure bash under bootstrap/ and never require this binary.")
	fmt.Println("\nValidation Commands:")
	fmt.Println("  doctor                     - Run deep system health diagnostics")
	fmt.Println("  validate                   - Verify integrity and instruction layers")
	fmt.Println("  compact                    - Garbage-collect stale LLM context files")
	fmt.Println("  check-awareness            - System awareness + boundary leak scan")
	fmt.Println("  check-alignment            - Host-adapter alignment")
	fmt.Println("  check-integrity            - Agent surface integrity")
	fmt.Println("  check-validate-layer       - Instruction-layer validation")
	fmt.Println("  check-bootstrap-permissions - bootstrap/ script executability")
	fmt.Println("  check-install-boundary     - Installed-repo boundary purity")
	fmt.Println("  check-agent-orchestration  - Agent orchestration alignment")
	fmt.Println("  check-evidence-quality     - Grounded-evidence scan of status files")
	fmt.Println("  check-repo-permissions     - Repo file ownership/permissions")
	fmt.Println("\nNote: the NATS Swarm Event-Bus, distributed locks, and MetaCommander")
	fmt.Println("loop are parked under internal/_deferred/ (deferred Phase 3/4).")
}
