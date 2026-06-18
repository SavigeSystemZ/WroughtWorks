package commands

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func RunCheckAgentOrchestration(args []string) bool {
	fs := flag.NewFlagSet("check-agent-orchestration", flag.ContinueOnError)
	fs.Usage = func() {
		fmt.Println("Usage: check-agent-orchestration [target-repo]")
		fmt.Println("\nVerify that the shared role catalog, multi-agent docs, prompt packs, and Cursor")
		fmt.Println("role overlays stay aligned.")
	}

	if err := fs.Parse(args); err != nil {
		return false
	}

	var targetRepo string
	if fs.NArg() > 0 {
		targetRepo = fs.Arg(0)
	} else {
		// Default to parent of bootstrap directory, or current dir. We'll use cwd as default fallback if we don't know bootstrap path, but the scripts were run from bootstrap.
		// Wait, original says: TARGET_REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
		// Since we run from anywhere, we assume current dir if not provided, or `..` if in bootstrap? Let's use `.` as default since usually run from repo root.
		// Actually, in Go, the CLI will probably be run from the repo root if no args are provided.
		// Wait, let's just resolve `.` 
		targetRepo = "."
	}

	repo, err := filepath.Abs(targetRepo)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to resolve target repo: %v\n", err)
		return false
	}

	info, err := os.Stat(repo)
	if err != nil || !info.IsDir() {
		fmt.Fprintf(os.Stderr, "Target repo does not exist: %s\n", repo)
		return false
	}

	issues := []string{}

	requiredFiles := []string{
		"_system/AGENT_ROLE_CATALOG.md",
		"_system/MULTI_AGENT_COORDINATION.md",
		"_system/AGENT_DISCOVERY_MATRIX.md",
		"_system/prompt-packs/M1_FEATURE_DELIVERY.md",
		"_system/prompt-packs/M9_MULTI_AGENT_CONTINUITY.md",
		"_system/prompt-packs/M10_GREENFIELD_BOOTSTRAP.md",
		".cursor/agents/README.md",
		".cursor/agents/orchestrator.md",
		".cursor/agents/implementation-worker.md",
		".cursor/agents/validator.md",
		".cursor/agents/context-curator.md",
	}

	for _, relPath := range requiredFiles {
		fullPath := filepath.Join(repo, filepath.FromSlash(relPath))
		if _, err := os.Stat(fullPath); os.IsNotExist(err) {
			issues = append(issues, fmt.Sprintf("Missing orchestration surface: %s", relPath))
		}
	}

	checks := map[string][]string{
		"AGENTS.md": {"_system/AGENT_ROLE_CATALOG.md"},
		"_system/MULTI_AGENT_COORDINATION.md": {"_system/AGENT_ROLE_CATALOG.md", "## delegation rules"},
		"_system/AGENT_DISCOVERY_MATRIX.md": {"_system/AGENT_ROLE_CATALOG.md"},
		"_system/prompt-packs/M1_FEATURE_DELIVERY.md": {"role", "write ownership"},
		"_system/prompt-packs/M9_MULTI_AGENT_CONTINUITY.md": {
			"_system/AGENT_ROLE_CATALOG.md",
			"_system/sub_agent_host_delegation.md",
		},
		"_system/prompt-packs/M10_GREENFIELD_BOOTSTRAP.md": {"persisted blueprint recommendation", "explicitly apply"},
		".cursor/agents/README.md": {"_system/AGENT_ROLE_CATALOG.md"},
		".cursor/agents/orchestrator.md": {"_system/AGENT_ROLE_CATALOG.md"},
		".cursor/agents/implementation-worker.md": {"_system/AGENT_ROLE_CATALOG.md"},
		".cursor/agents/validator.md": {"_system/AGENT_ROLE_CATALOG.md"},
		".cursor/agents/context-curator.md": {"_system/AGENT_ROLE_CATALOG.md"},
	}

	for relPath, markers := range checks {
		fullPath := filepath.Join(repo, filepath.FromSlash(relPath))
		content, err := os.ReadFile(fullPath)
		if err != nil {
			continue // skip if file doesn't exist
		}
		
		text := strings.ToLower(string(content))
		for _, marker := range markers {
			lowerMarker := strings.ToLower(marker)
			if !strings.Contains(text, lowerMarker) {
				issues = append(issues, fmt.Sprintf("%s is missing orchestration marker: %s", relPath, marker))
			}
		}
	}

	if len(issues) > 0 {
		fmt.Println("agent_orchestration_issues_detected")
		for _, issue := range issues {
			fmt.Printf("- %s\n", issue)
		}
		return false
	}

	fmt.Println("agent_orchestration_ok")
	return true
}
