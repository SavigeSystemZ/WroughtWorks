package commands

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

// RunCheckInstallBoundary verifies that no maintainer-only or foreign product layers exist in the repo.
func RunCheckInstallBoundary(args []string) bool {
	cmd := flag.NewFlagSet("check-install-boundary", flag.ContinueOnError)
	repoFlag := cmd.String("repo", "", "Target repository path")
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

	absTarget, err := filepath.Abs(targetRepo)
	if err != nil {
		fmt.Printf("Error resolving target path: %v\n", err)
		return false
	}

	forbidden := []string{
		"_META_AGENT_SYSTEM",
		"_TEMPLATE_FACTORY",
		"_MOS_TEMPLATE_FACTORY",
		"MOS_TEMPLATE",
		"MOS_SOURCE_LIBRARY",
		filepath.Join("_META_AGENT_SYSTEM", ".meta-only"),
		filepath.Join("_TEMPLATE_FACTORY", ".factory-only"),
		filepath.Join("_MOS_TEMPLATE_FACTORY", ".factory-only"),
		filepath.Join("MOS_SOURCE_LIBRARY", ".source-library-only"),
		filepath.Join("MOS_TEMPLATE", ".installable-product-root"),
	}

	var issues []string
	for _, item := range forbidden {
		checkPath := filepath.Join(absTarget, item)
		if _, err := os.Stat(checkPath); !os.IsNotExist(err) {
			issues = append(issues, item)
		}
	}

	if len(issues) > 0 {
		fmt.Println("install_boundary_failed")
		for _, item := range issues {
			fmt.Printf("- unexpected maintainer-only or foreign product path present: %s\n", item)
		}
		return false
	}

	fmt.Println("install_boundary_ok")
	return true
}
