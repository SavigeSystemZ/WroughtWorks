package commands

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func RunValidateInstructionLayer(args []string) bool {
	targetRepo := "."
	validatorRoot := ""

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

	// 1. Core script existence check
	scripts := []string{
		"bootstrap/generate-host-adapters.sh",
		"bootstrap/generate-operating-profile.sh",
		"bootstrap/detect-instruction-conflicts.sh",
		"bootstrap/aiast-cli",
		"bootstrap/check-host-ingestion.sh",
		"bootstrap/check-host-bundle.sh",
	}

	for _, script := range scripts {
		if _, err := os.Stat(filepath.Join(absValidator, script)); os.IsNotExist(err) {
			fmt.Printf("Validator root is missing required validation script: %s\n", script)
			return false
		}
	}

	// 2. Required files check
	requiredFiles := []string{
		"_system/INSTRUCTION_PRECEDENCE_CONTRACT.md",
		"_system/instruction-precedence.json",
		"_system/HOST_ADAPTER_POLICY.md",
		"_system/HOST_BUNDLE_CONTRACT.md",
		"_system/READ_BUNDLES.md",
		"_system/TEMPLATE_CHANGE_IMPACT_POLICY.md",
		"_system/SELF_HEALING_BOUNDARY.md",
		"_system/VERSION_SENSITIVE_RESEARCH_PROTOCOL.md",
		"_system/WORKSPACE_AUTHORITY_AND_CONTAINMENT_PROTOCOL.md",
		"_system/PROJECT_IDENTITY_AND_SCOPE_PROTOCOL.md",
		"_system/INSTRUCTION_DOMAIN_ALIGNMENT_PROTOCOL.md",
		"_system/PROJECT_DOMAIN_MANIFEST.json",
		"_system/PROJECT_DOMAIN_MANIFEST.template.json",
		"_system/schemas/project-domain-manifest.schema.json",
		"bootstrap/check-instruction-domain-alignment.sh",
		"_system/GLOBAL_REDIRECT_SHIM_POLICY.md",
		"_system/SCAVENGE_AND_DISCOVERY_AUTHORIZATION.md",
		"_system/SESSION_ENVIRONMENT_REPORT_CONTRACT.md",
		"_system/ORPHAN_META_SNAPSHOT_POLICY.md",
		"_system/host-adapter-manifest.json",
		"_system/INSTRUCTION_CONFLICT_PLAYBOOK.md",
		"_system/REPO_OPERATING_PROFILE.md",
		"_system/repo-operating-profile.json",
		"_system/PROMPT_EMISSION_CONTRACT.md",
		"_system/PROMPTS_INDEX.md",
		"_system/aiaast-capabilities.json",
		"bootstrap/generate-host-adapters.sh",
		"bootstrap/aiast-cli",
		"bootstrap/emit-host-prompt.sh",
		"bootstrap/check-host-ingestion.sh",
		"bootstrap/emit-host-bundle.sh",
		"bootstrap/check-host-bundle.sh",
		"bootstrap/check-working-directory-alignment.sh",
		"bootstrap/check-project-target-consistency.sh",
		"bootstrap/check-global-shim-alignment.sh",
		"bootstrap/emit-session-environment.sh",
		"bootstrap/snapshot-meta-to-orphan-branch.sh",
		"bootstrap/detect-instruction-conflicts.sh",
		"bootstrap/generate-operating-profile.sh",
	}

	for _, file := range requiredFiles {
		if _, err := os.Stat(filepath.Join(absTarget, file)); os.IsNotExist(err) {
			fmt.Printf("Missing required instruction-layer file: %s\n", file)
			return false
		}
	}

	// 3. Basic JSON checks
	jsonFiles := []string{
		"_system/host-adapter-manifest.json",
		"_system/instruction-precedence.json",
		"_system/repo-operating-profile.json",
		"_system/aiaast-capabilities.json",
	}

	for _, file := range jsonFiles {
		data, err := os.ReadFile(filepath.Join(absTarget, file))
		if err != nil {
			fmt.Printf("Cannot read JSON: %s\n", file)
			return false
		}
		var throwaway interface{}
		if err := json.Unmarshal(data, &throwaway); err != nil {
			fmt.Printf("Invalid JSON: %s\n", file)
			return false
		}
	}

	// 4. Validate repo-operating-profile.json required governance fields
	profData, _ := os.ReadFile(filepath.Join(absTarget, "_system", "repo-operating-profile.json"))
	var profile map[string]interface{}
	json.Unmarshal(profData, &profile)
	if _, ok := profile["read_bundles_contract_path"]; !ok {
		fmt.Printf("repo-operating-profile.json is missing required governance fields\n")
		return false
	}
	if _, ok := profile["change_impact_policy_path"]; !ok {
		fmt.Printf("repo-operating-profile.json is missing required governance fields\n")
		return false
	}
	if _, ok := profile["self_healing_boundary_path"]; !ok {
		fmt.Printf("repo-operating-profile.json is missing required governance fields\n")
		return false
	}
	if _, ok := profile["version_sensitive_research_protocol_path"]; !ok {
		fmt.Printf("repo-operating-profile.json is missing required governance fields\n")
		return false
	}

	// 5. Run external validations
	commands := []struct {
		name string
		cmd  string
		args []string
	}{
		{"generate-host-adapters", "bash", []string{filepath.Join(absValidator, "bootstrap/generate-host-adapters.sh"), absTarget, "--check"}},
		{"generate-operating-profile", "bash", []string{filepath.Join(absValidator, "bootstrap/generate-operating-profile.sh"), absTarget, "--check"}},
		{"detect-instruction-conflicts", "bash", []string{filepath.Join(absValidator, "bootstrap/detect-instruction-conflicts.sh"), absTarget, "--strict"}},
		{"check-host-adapter-alignment", filepath.Join(absValidator, "bootstrap/aiast-cli"), []string{"check-alignment", absTarget, "--validator-root", absValidator}},
		{"check-host-ingestion", "bash", []string{filepath.Join(absValidator, "bootstrap/check-host-ingestion.sh"), absTarget}},
		{"check-host-bundle", "bash", []string{filepath.Join(absValidator, "bootstrap/check-host-bundle.sh"), absTarget, "--validator-root", absValidator}},
	}

	for _, step := range commands {
		cmd := exec.Command(step.cmd, step.args...)
		output, err := cmd.CombinedOutput()
		if err != nil {
			fmt.Printf("instruction_layer_validation_failed: %s\n", step.name)
			if len(output) > 0 {
				fmt.Printf("%s\n", string(output))
			}
			return false
		}
	}

	// 6. Required Mentions Scan
	issues := []string{}
	requiredMentions := map[string][]string{
		"AGENTS.md": {
			"_system/INSTRUCTION_PRECEDENCE_CONTRACT.md",
			"_system/REPO_OPERATING_PROFILE.md",
			"_system/READ_BUNDLES.md",
			"_system/TEMPLATE_CHANGE_IMPACT_POLICY.md",
			"_system/SELF_HEALING_BOUNDARY.md",
			"_system/VERSION_SENSITIVE_RESEARCH_PROTOCOL.md",
			"_system/INSTRUCTION_DOMAIN_ALIGNMENT_PROTOCOL.md",
		},
		"_system/CONTEXT_INDEX.md": {
			"INSTRUCTION_PRECEDENCE_CONTRACT.md",
			"REPO_OPERATING_PROFILE.md",
			"PROMPT_EMISSION_CONTRACT.md",
			"HOST_BUNDLE_CONTRACT.md",
			"READ_BUNDLES.md",
			"TEMPLATE_CHANGE_IMPACT_POLICY.md",
			"SELF_HEALING_BOUNDARY.md",
			"VERSION_SENSITIVE_RESEARCH_PROTOCOL.md",
			"WORKSPACE_AUTHORITY_AND_CONTAINMENT_PROTOCOL.md",
			"PROJECT_IDENTITY_AND_SCOPE_PROTOCOL.md",
			"INSTRUCTION_DOMAIN_ALIGNMENT_PROTOCOL.md",
			"PROJECT_DOMAIN_MANIFEST.json",
			"GLOBAL_REDIRECT_SHIM_POLICY.md",
			"SCAVENGE_AND_DISCOVERY_AUTHORIZATION.md",
			"SESSION_ENVIRONMENT_REPORT_CONTRACT.md",
			"ORPHAN_META_SNAPSHOT_POLICY.md",
		},
		"_system/LOAD_ORDER.md": {
			"_system/INSTRUCTION_PRECEDENCE_CONTRACT.md",
			"_system/REPO_OPERATING_PROFILE.md",
			"_system/READ_BUNDLES.md",
			"INSTRUCTION_DOMAIN_ALIGNMENT_PROTOCOL.md",
		},
		"_system/AGENT_DISCOVERY_MATRIX.md": {
			"_system/HOST_ADAPTER_POLICY.md",
			"bootstrap/generate-host-adapters.sh",
			"aiast-cli check-alignment",
			"_system/READ_BUNDLES.md",
			"_system/TEMPLATE_CHANGE_IMPACT_POLICY.md",
			"_system/SELF_HEALING_BOUNDARY.md",
			"_system/VERSION_SENSITIVE_RESEARCH_PROTOCOL.md",
		},
		"_system/MASTER_SYSTEM_PROMPT.md": {
			"_system/INSTRUCTION_PRECEDENCE_CONTRACT.md",
			"_system/REPO_OPERATING_PROFILE.md",
			"INSTRUCTION_DOMAIN_ALIGNMENT_PROTOCOL.md",
		},
		"_system/PROJECT_RULES.md": {
			"_system/INSTRUCTION_PRECEDENCE_CONTRACT.md",
		},
		"_system/TEMPLATE_NEUTRALITY_POLICY.md": {
			"PROMPT_EMISSION_CONTRACT.md",
		},
		"_system/HOST_ADAPTER_POLICY.md": {
			"host-adapter-manifest.json",
			"generate-host-adapters.sh",
			"aiast-cli check-alignment",
		},
		"_system/HOST_BUNDLE_CONTRACT.md": {
			"PROMPT_EMISSION_CONTRACT.md",
			"emit-host-bundle.sh",
			"check-host-bundle.sh",
			"_system/READ_BUNDLES.md",
		},
		"_system/PROMPTS_INDEX.md": {
			"_system/PROMPT_EMISSION_CONTRACT.md",
			"_system/HOST_BUNDLE_CONTRACT.md",
			"bootstrap/emit-host-prompt.sh",
			"bootstrap/emit-host-bundle.sh",
			"bootstrap/check-host-bundle.sh",
		},
		"bootstrap/README.md": {
			"detect-instruction-conflicts.sh",
			"generate-host-adapters.sh",
			"aiast-cli check-alignment",
			"generate-operating-profile.sh",
			"aiast-cli check-validate-layer",
			"emit-host-prompt.sh",
			"check-host-ingestion.sh",
			"emit-host-bundle.sh",
			"check-host-bundle.sh",
			"check-instruction-domain-alignment.sh",
			"INSTALLER_AND_UPGRADE_CONTRACT.md",
			"_system/READ_BUNDLES.md",
			"_system/TEMPLATE_CHANGE_IMPACT_POLICY.md",
			"_system/SELF_HEALING_BOUNDARY.md",
			"_system/VERSION_SENSITIVE_RESEARCH_PROTOCOL.md",
		},
	}

	for doc, needles := range requiredMentions {
		docPath := filepath.Join(absTarget, doc)
		if _, err := os.Stat(docPath); os.IsNotExist(err) {
			issues = append(issues, fmt.Sprintf("Missing required doc for instruction-layer mention check: %s", doc))
			continue
		}
		
		textBytes, _ := os.ReadFile(docPath)
		text := string(textBytes)
		
		for _, needle := range needles {
			// Skip old script check needles we deprecated, replace with new strings inline above
			if !strings.Contains(text, needle) {
				issues = append(issues, fmt.Sprintf("%s is missing required mention: %s", doc, needle))
			}
		}
	}

	// 7. Forbidden Markers Scan
	forbiddenMarkers := []string{
		"Savige Systems",
		"The Savage Architect",
		"Michael Todd Spaulding",
	}

	scanRoots := []string{
		"AGENTS.md",
		"CODEX.md",
		"CLAUDE.md",
		"GEMINI.md",
		"WINDSURF.md",
		".cursorrules",
		".windsurfrules",
		".github",
		"_system",
		"bootstrap",
	}

	for _, rootPath := range scanRoots {
		fullRoot := filepath.Join(absTarget, rootPath)
		info, err := os.Stat(fullRoot)
		if err != nil {
			continue
		}

		if !info.IsDir() {
			checkForbidden(fullRoot, rootPath, forbiddenMarkers, &issues)
		} else {
			filepath.WalkDir(fullRoot, func(path string, d fs.DirEntry, err error) error {
				if err != nil {
					return nil
				}
				if d.IsDir() {
					// Skip VCS internals and build-artifact dirs (e.g. the
					// on-demand aiast-cli binary under bootstrap/.bin/), which
					// can legitimately embed marker strings as compiled data.
					switch d.Name() {
					case ".git", ".bin", "node_modules", ".update_backups":
						return filepath.SkipDir
					}
					return nil
				}
				rel, _ := filepath.Rel(absTarget, path)
				if rel == "bootstrap/validate-instruction-layer.sh" || rel == "bootstrap/aiast-cli" {
					return nil
				}
				checkForbidden(path, rel, forbiddenMarkers, &issues)
				return nil
			})
		}
	}

	if len(issues) > 0 {
		fmt.Println("instruction_layer_validation_failed")
		for _, issue := range issues {
			fmt.Printf("- %s\n", issue)
		}
		return false
	}

	fmt.Println("instruction_layer_ok")
	return true
}

func checkForbidden(absPath, relPath string, forbidden []string, issues *[]string) {
	data, err := os.ReadFile(absPath)
	if err != nil {
		return
	}
	// Never scan binary files: compiled artifacts can legitimately embed the
	// marker strings as detection patterns. A NUL byte reliably signals binary.
	if bytes.IndexByte(data, 0) != -1 {
		return
	}
	text := string(data)
	for _, marker := range forbidden {
		if strings.Contains(text, marker) {
			*issues = append(*issues, fmt.Sprintf("Forbidden template-specific content leaked into instruction surfaces: %s [%s]", marker, relPath))
		}
	}
}
