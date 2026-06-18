package commands

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

// RunCheckBootstrapPermissions verifies that all shell scripts in the bootstrap/ directory are executable.
func RunCheckBootstrapPermissions(args []string) bool {
	cmd := flag.NewFlagSet("check-bootstrap-permissions", flag.ContinueOnError)
	repoFlag := cmd.String("repo", "", "Target repository path")
	fix := cmd.Bool("fix", false, "Automatically repair missing execute permissions")
	if err := cmd.Parse(args); err != nil {
		return false
	}

	// Accept the target repo as a positional argument (the convention used
	// across the bash bootstrap suite), falling back to --repo then cwd.
	targetRepo := "."
	if cmd.NArg() > 0 {
		targetRepo = cmd.Arg(0)
	} else if *repoFlag != "" {
		targetRepo = *repoFlag
	}

	bootstrapDir := filepath.Join(targetRepo, "bootstrap")
	if _, err := os.Stat(bootstrapDir); os.IsNotExist(err) {
		fmt.Printf("bootstrap/ directory not found in %s\n", targetRepo)
		return false
	}

	issues := 0
	fixed := 0

	err := filepath.Walk(bootstrapDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		
		if !info.IsDir() && filepath.Ext(path) == ".sh" {
			relPath, _ := filepath.Rel(targetRepo, path)

			// Check if file is readable
			if info.Mode().Perm()&0400 == 0 {
				fmt.Printf("[fail] %s: not readable\n", relPath)
				issues++
				return nil
			}

			// Check if file is executable
			if info.Mode().Perm()&0111 == 0 {
				if *fix {
					err := os.Chmod(path, info.Mode()|0111)
					if err != nil {
						fmt.Printf("[fail] %s: failed to fix execute permission: %v\n", relPath, err)
						issues++
					} else {
						fmt.Printf("[fixed] %s: added execute permission\n", relPath)
						fixed++
					}
				} else {
					fmt.Printf("[fail] %s: not executable (run with --fix to repair)\n", relPath)
					issues++
				}
			}
		}
		return nil
	})

	if err != nil {
		fmt.Printf("Error scanning bootstrap directory: %v\n", err)
		return false
	}

	if fixed > 0 {
		fmt.Printf("bootstrap_permissions_fixed count=%d\n", fixed)
	}

	if issues > 0 {
		fmt.Printf("bootstrap_permissions_issues count=%d\n", issues)
		return false
	}

	fmt.Println("bootstrap_permissions_ok")
	return true
}
