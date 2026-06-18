package commands

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func RunCheckIntegrity(args []string) bool {
	targetRepo := "."
	if len(args) > 0 {
		targetRepo = args[0]
	}

	absTarget, err := filepath.Abs(targetRepo)
	if err != nil {
		fmt.Printf("Error resolving target repo: %v\n", err)
		return false
	}

	// 1. Load managed files from registry
	registryPath := filepath.Join(absTarget, "_system", "SYSTEM_REGISTRY.json")
	registryData, err := os.ReadFile(registryPath)
	if err != nil {
		fmt.Printf("Cannot read registry: %v\n", err)
		return false
	}

	var registry struct {
		Entries []struct {
			Path string `json:"path"`
		} `json:"entries"`
	}

	if err := json.Unmarshal(registryData, &registry); err != nil {
		fmt.Printf("Invalid JSON: %s\n", registryPath)
		return false
	}

	managedFiles := make(map[string]bool)
	for _, entry := range registry.Entries {
		managedFiles[entry.Path] = true
	}

	// 2. Load manifest
	manifestPath := filepath.Join(absTarget, "_system", "host-adapter-manifest.json")
	if _, err := os.Stat(manifestPath); os.IsNotExist(err) {
		fmt.Println("agent_surface_integrity_failed")
		fmt.Println("- missing _system/host-adapter-manifest.json")
		return false
	}

	manifestData, err := os.ReadFile(manifestPath)
	if err != nil {
		fmt.Println("agent_surface_integrity_failed")
		fmt.Println("- could not read _system/host-adapter-manifest.json")
		return false
	}

	var manifest map[string]interface{}
	if err := json.Unmarshal(manifestData, &manifest); err != nil {
		fmt.Println("agent_surface_integrity_failed")
		fmt.Println("- invalid json in _system/host-adapter-manifest.json")
		return false
	}

	issues := []string{}

	// 3. Required docs
	requiredDocs := []string{
		"_system/AGENT_SURFACE_TAXONOMY.md",
		"_system/AGENT_INIT_CONVERGENCE.md",
		"_system/OPERATOR_PROMPTING_PLAYBOOK.md",
	}

	for _, rel := range requiredDocs {
		if _, err := os.Stat(filepath.Join(absTarget, rel)); os.IsNotExist(err) {
			issues = append(issues, fmt.Sprintf("missing required contract doc: %s", rel))
		}
	}

	// 4. Required placeholders
	if placeholders, ok := manifest["required_placeholder_files"].([]interface{}); ok {
		for _, pRaw := range placeholders {
			if p, ok := pRaw.(string); ok {
				if _, err := os.Stat(filepath.Join(absTarget, p)); os.IsNotExist(err) {
					issues = append(issues, fmt.Sprintf("missing required placeholder adapter: %s", p))
				} else if !managedFiles[p] {
					issues = append(issues, fmt.Sprintf("required placeholder adapter not registered as managed file: %s (add to aiaast_print_managed_files in bootstrap/lib/aiaast-lib.sh)", p))
				}
			}
		}
	}

	// 5. Deprecated aliases
	if aliasesRaw, exists := manifest["deprecated_aliases"]; exists {
		if aliases, ok := aliasesRaw.(map[string]interface{}); !ok {
			issues = append(issues, "deprecated_aliases must be an object in host-adapter-manifest.json")
		} else {
			for alias, entryRaw := range aliases {
				if strings.TrimSpace(alias) == "" {
					issues = append(issues, "deprecated_aliases contains empty key")
				}
				
				if entryStr, ok := entryRaw.(string); ok {
					if strings.TrimSpace(entryStr) == "" {
						issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' has empty target", alias))
					}
					continue
				}
				
				entry, ok := entryRaw.(map[string]interface{})
				if !ok {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' must be string or object", alias))
					continue
				}

				for _, reqKey := range []string{"target", "deprecated_since", "remove_after", "migration_doc"} {
					val, _ := entry[reqKey].(string)
					if strings.TrimSpace(val) == "" {
						issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' missing required key: %s", alias, reqKey))
					}
				}
			}
		}
	}

	if len(issues) > 0 {
		fmt.Println("agent_surface_integrity_failed")
		for _, issue := range issues {
			fmt.Printf("- %s\n", issue)
		}
		return false
	}

	fmt.Println("agent_surface_integrity_ok")
	return true
}
