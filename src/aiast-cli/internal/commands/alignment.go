package commands

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
)

func RunCheckAlignment(args []string) bool {
	targetRepo := "."
	validatorRoot := ""

	// Simple flag parsing for the Go implementation
	for i := 0; i < len(args); i++ {
		if args[i] == "--validator-root" && i+1 < len(args) {
			validatorRoot = args[i+1]
			i++
		} else if !strings.HasPrefix(args[i], "--") {
			targetRepo = args[i]
		}
	}

	absTarget, err := filepath.Abs(targetRepo)
	if err != nil {
		fmt.Printf("Error resolving target repo: %v\n", err)
		return false
	}

	if validatorRoot == "" {
		validatorRoot = filepath.Dir(filepath.Join(absTarget, "bootstrap"))
	}
	absValidator, err := filepath.Abs(validatorRoot)
	if err != nil {
		fmt.Printf("Error resolving validator root: %v\n", err)
		return false
	}

	// 1. Basic required files check
	requiredFiles := []string{
		"_system/HOST_ADAPTER_POLICY.md",
		"_system/AGENT_SURFACE_TAXONOMY.md",
		"_system/AGENT_INIT_CONVERGENCE.md",
		"_system/host-adapter-manifest.json",
		"_system/SESSION_ENVIRONMENT_REPORT_CONTRACT.md",
		"_system/WORKSPACE_AUTHORITY_AND_CONTAINMENT_PROTOCOL.md",
		"_system/PROJECT_IDENTITY_AND_SCOPE_PROTOCOL.md",
		"bootstrap/generate-host-adapters.sh",
		"bootstrap/check-host-adapter-alignment.sh",
		"bootstrap/emit-session-environment.sh",
	}

	for _, rel := range requiredFiles {
		// We use Stat to ensure they exist. Note: For Phase 2, we tolerate check-host-adapter-alignment.sh being missing if it's the script we are replacing, but we'll stick to the exact legacy contract for now, except we won't strictly fail if the legacy bash script itself is missing (since we're deleting it).
		if rel == "bootstrap/check-host-adapter-alignment.sh" {
			continue
		}
		if _, err := os.Stat(filepath.Join(absTarget, rel)); os.IsNotExist(err) {
			fmt.Printf("Missing required host-adapter file: %s\n", rel)
			return false
		}
	}

	// 2. Validate JSON
	manifestPath := filepath.Join(absTarget, "_system", "host-adapter-manifest.json")
	manifestData, err := os.ReadFile(manifestPath)
	if err != nil {
		fmt.Printf("Cannot read manifest: %v\n", err)
		return false
	}

	var manifest map[string]interface{}
	if err := json.Unmarshal(manifestData, &manifest); err != nil {
		fmt.Printf("Invalid JSON: _system/host-adapter-manifest.json\n")
		return false
	}

	// 3. Run generate-host-adapters.sh --check
	genScript := filepath.Join(absValidator, "bootstrap", "generate-host-adapters.sh")
	if _, err := os.Stat(genScript); err == nil {
		cmd := exec.Command("bash", genScript, absTarget, "--check")
		if err := cmd.Run(); err != nil {
			fmt.Printf("generate-host-adapters.sh --check failed\n")
			return false
		}
	}

	issues := []string{}

	// 4. Docs to scan for required needles
	docsToScan := map[string][]string{
		"AGENTS.md": {
			"_system/HOST_ADAPTER_POLICY.md",
			"_system/AGENT_SURFACE_TAXONOMY.md",
			"_system/AGENT_INIT_CONVERGENCE.md",
			"bootstrap/generate-host-adapters.sh",
			"bootstrap/check-host-adapter-alignment.sh",
		},
		"_system/AGENT_DISCOVERY_MATRIX.md": {
			"_system/HOST_ADAPTER_POLICY.md",
			"_system/AGENT_SURFACE_TAXONOMY.md",
			"_system/AGENT_INIT_CONVERGENCE.md",
			"bootstrap/generate-host-adapters.sh",
			"bootstrap/check-host-adapter-alignment.sh",
		},
		"_system/CONTEXT_INDEX.md": {
			"HOST_ADAPTER_POLICY.md",
			"host-adapter-manifest.json",
			"generate-host-adapters.sh",
			"check-host-adapter-alignment.sh",
		},
		"_system/SYSTEM_EVOLUTION_POLICY.md": {
			"HOST_ADAPTER_POLICY.md",
			"generate-host-adapters.sh",
		},
		"bootstrap/README.md": {
			"generate-host-adapters.sh",
			"check-host-adapter-alignment.sh",
		},
	}

	for doc, needles := range docsToScan {
		docPath := filepath.Join(absTarget, doc)
		if _, err := os.Stat(docPath); os.IsNotExist(err) {
			issues = append(issues, fmt.Sprintf("Missing doc for host-adapter scan: %s", doc))
			continue
		}
		
		textBytes, _ := os.ReadFile(docPath)
		text := string(textBytes)
		
		for _, needle := range needles {
			// Skip the check-host-adapter-alignment.sh needle since we are deprecating it.
			if needle == "check-host-adapter-alignment.sh" || needle == "bootstrap/check-host-adapter-alignment.sh" {
				continue
			}
			if !strings.Contains(text, needle) {
				issues = append(issues, fmt.Sprintf("%s is missing required mention: %s", doc, needle))
			}
		}
	}

	// 5. Generated adapters
	if generated, ok := manifest["generated_adapters"].(map[string]interface{}); ok {
		for _, specRaw := range generated {
			if spec, ok := specRaw.(map[string]interface{}); ok {
				if path, ok := spec["path"].(string); ok {
					if _, err := os.Stat(filepath.Join(absTarget, path)); os.IsNotExist(err) {
						issues = append(issues, fmt.Sprintf("Manifest references missing generated host adapter: %s", path))
					}
				}
			}
		}
	}

	// 6. Required placeholders
	if placeholders, ok := manifest["required_placeholder_files"].([]interface{}); ok {
		for _, p := range placeholders {
			if path, ok := p.(string); ok {
				if _, err := os.Stat(filepath.Join(absTarget, path)); os.IsNotExist(err) {
					issues = append(issues, fmt.Sprintf("Missing required placeholder adapter: %s", path))
				}
			}
		}
	}

	// 7. Deprecated aliases logic
	templateVersion := ""
	versionPath := filepath.Join(absTarget, "_system", ".template-version")
	if v, err := os.ReadFile(versionPath); err == nil {
		templateVersion = strings.TrimSpace(string(v))
	}
	templateVersionTuple := parseVersion(templateVersion)

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
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' must be a string or object", alias))
					continue
				}

				target, _ := entry["target"].(string)
				deprecatedSince, _ := entry["deprecated_since"].(string)
				removeAfter, _ := entry["remove_after"].(string)
				migrationDoc, _ := entry["migration_doc"].(string)

				if strings.TrimSpace(target) == "" {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' is missing target", alias))
				}
				if strings.TrimSpace(deprecatedSince) == "" {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' is missing deprecated_since", alias))
				}
				if strings.TrimSpace(removeAfter) == "" {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' is missing remove_after", alias))
				}
				if strings.TrimSpace(migrationDoc) == "" {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' is missing migration_doc", alias))
				} else if _, err := os.Stat(filepath.Join(absTarget, migrationDoc)); os.IsNotExist(err) {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' migration_doc does not exist: %s", alias, migrationDoc))
				}

				depTuple := parseVersion(deprecatedSince)
				remTuple := parseVersion(removeAfter)

				if deprecatedSince != "" && len(depTuple) == 0 {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' has invalid deprecated_since: %s", alias, deprecatedSince))
				}
				if removeAfter != "" && len(remTuple) == 0 {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' has invalid remove_after: %s", alias, removeAfter))
				}

				if len(depTuple) > 0 && len(remTuple) > 0 && compareVersions(remTuple, depTuple) <= 0 {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' remove_after must be greater than deprecated_since", alias))
				}

				if len(templateVersionTuple) > 0 && len(remTuple) > 0 && compareVersions(templateVersionTuple, remTuple) >= 0 {
					issues = append(issues, fmt.Sprintf("deprecated_aliases entry '%s' expired at %s; remove alias or extend window", alias, removeAfter))
				}
			}
		}
	}

	// 8. Operating profile check
	profileJSONPath := filepath.Join(absTarget, "_system", "repo-operating-profile.json")
	if profileData, err := os.ReadFile(profileJSONPath); err == nil {
		var profile map[string]interface{}
		if json.Unmarshal(profileData, &profile) == nil {
			if hostIngestion, ok := profile["host_ingestion"].(map[string]interface{}); ok {
				keys := []string{"host_adapter_generator", "host_adapter_validator", "host_adapter_manifest"}
				for _, k := range keys {
					val, ok := hostIngestion[k].(string)
					if !ok || strings.TrimSpace(val) == "" {
						issues = append(issues, fmt.Sprintf("repo-operating-profile.json host_ingestion is missing %s", k))
					}
				}
			}
		}
	}

	if len(issues) > 0 {
		fmt.Println("host_adapter_alignment_failed")
		for _, issue := range issues {
			fmt.Printf("- %s\n", issue)
		}
		return false
	}

	fmt.Println("host_adapter_alignment_ok")
	return true
}

func parseVersion(v string) []int {
	v = strings.TrimSpace(strings.TrimPrefix(strings.TrimPrefix(v, "v"), "V"))
	if v == "" {
		return nil
	}
	parts := strings.Split(v, ".")
	var out []int
	for _, p := range parts {
		num, err := strconv.Atoi(p)
		if err != nil {
			return nil
		}
		out = append(out, num)
	}
	return out
}

func compareVersions(v1, v2 []int) int {
	maxLen := len(v1)
	if len(v2) > maxLen {
		maxLen = len(v2)
	}
	for i := 0; i < maxLen; i++ {
		p1 := 0
		if i < len(v1) {
			p1 = v1[i]
		}
		p2 := 0
		if i < len(v2) {
			p2 = v2[i]
		}
		if p1 < p2 {
			return -1
		} else if p1 > p2 {
			return 1
		}
	}
	return 0
}
