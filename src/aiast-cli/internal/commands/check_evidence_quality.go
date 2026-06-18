package commands

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

func RunCheckEvidenceQuality(args []string) bool {
	fs := flag.NewFlagSet("check-evidence-quality", flag.ContinueOnError)
	strictPtr := fs.Bool("strict", false, "Strict mode")
	
	fs.Usage = func() {
		fmt.Println("Usage: check-evidence-quality [target-repo] [--strict]")
		fmt.Println("\nScan WHERE_LEFT_OFF.md and _system/context/CURRENT_STATUS.md for grounded")
		fmt.Println("evidence: validation commands with results, concrete file lists, and specific")
		fmt.Println("next steps. Flags ungrounded claims that could mislead the next agent.")
		fmt.Println("\nExit codes:")
		fmt.Println("  0  evidence quality acceptable")
		fmt.Println("  1  evidence quality issues detected (strict mode)")
		fmt.Println("  2  warnings detected (non-strict mode)")
	}

	if err := fs.Parse(args); err != nil {
		return false
	}

	var targetRepo string
	if fs.NArg() > 0 {
		targetRepo = fs.Arg(0)
	} else {
		exe, err := os.Executable()
		if err == nil {
			targetRepo = filepath.Dir(filepath.Dir(exe))
		} else {
			targetRepo = "."
		}
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

	warnings := []string{}

	type Pattern struct {
		regex   *regexp.Regexp
		message string
	}

	ungroundedPatterns := []Pattern{
		{regexp.MustCompile(`(?i)\ball tests pass\b`), "Claim 'all tests pass' without command/count evidence"},
		{regexp.MustCompile(`(?i)\bbuild succeeds?\b`), "Claim 'build succeeds' without command evidence"},
		{regexp.MustCompile(`(?i)\bfully (tested|validated|verified)\b`), "Claim 'fully tested/validated' without scope"},
		{regexp.MustCompile(`(?i)\bno (issues|problems|errors)\b`), "Claim 'no issues' without validation evidence"},
		{regexp.MustCompile(`(?i)\beverything (works|passes|is green)\b`), "Vague 'everything works' claim"},
		{regexp.MustCompile(`(?i)\bshould (work|be fine|pass)\b`), "Speculative 'should work' instead of evidence"},
	}

	evidenceIndicators := []*regexp.Regexp{
		regexp.MustCompile(`(?i)→\s*(system_ok|pass|ok|success)`),
		regexp.MustCompile(`(?i)exit\s*(code\s*)?0`),
		regexp.MustCompile(`(?i)\d+\s*(tests?|specs?)\s*(pass|green)`),
		regexp.MustCompile(`(?i)command:`),
		regexp.MustCompile(`(?i)result:`),
		regexp.MustCompile(`(?i)` + "`[^`]+`" + `\s*→`),
		regexp.MustCompile(`(?i)output:`),
	}

	checkFile := func(rel string, path string) {
		content, err := os.ReadFile(path)
		if err != nil {
			return
		}
		text := string(content)

		if strings.Contains(text, "not set yet") {
			return
		}

		for _, pat := range ungroundedPatterns {
			matches := pat.regex.FindAllStringIndex(text, -1)
			for _, match := range matches {
				start := strings.LastIndex(text[:match[0]], "\n")
				if start == -1 {
					start = 0
				}
				for i := 0; i < 200 && start > 0; i++ {
					start = strings.LastIndex(text[:start], "\n")
					if start == -1 {
						start = 0
						break
					}
				}

				end := match[1]
				newlineCount := 0
				for end < len(text) {
					if text[end] == '\n' {
						newlineCount++
						if newlineCount >= 200 { // fallback logic, just use character bounds as approximate to 200 chars or lines?
							break
						}
					}
					end++
				}
				
				// Let's implement the logic closer to python: 
				// max(0, text.rfind("\n", 0, match.start() - 200)) -> find last newline before match.start() - 200
				searchStart := match[0] - 200
				if searchStart < 0 { searchStart = 0 }
				actStart := strings.LastIndex(text[:searchStart], "\n")
				if actStart == -1 { actStart = 0 }

				searchEnd := match[1] + 200
				if searchEnd > len(text) { searchEnd = len(text) }
				actEnd := strings.Index(text[searchEnd:], "\n")
				if actEnd != -1 {
					actEnd += searchEnd
				} else {
					actEnd = len(text)
				}

				context := text[actStart:actEnd]

				hasEvidence := false
				for _, ep := range evidenceIndicators {
					if ep.MatchString(context) {
						hasEvidence = true
						break
					}
				}

				if !hasEvidence {
					lineNum := strings.Count(text[:match[0]], "\n") + 1
					warnings = append(warnings, fmt.Sprintf("%s:%d: %s", rel, lineNum, pat.message))
				}
			}
		}
	}

	checkFile("WHERE_LEFT_OFF.md", filepath.Join(repo, "WHERE_LEFT_OFF.md"))
	checkFile("_system/context/CURRENT_STATUS.md", filepath.Join(repo, "_system/context/CURRENT_STATUS.md"))
	checkFile("RELEASE_NOTES.md", filepath.Join(repo, "RELEASE_NOTES.md"))
	checkFile("TEST_STRATEGY.md", filepath.Join(repo, "TEST_STRATEGY.md"))

	wloPath := filepath.Join(repo, "WHERE_LEFT_OFF.md")
	wloContent, err := os.ReadFile(wloPath)
	if err == nil {
		wloText := string(wloContent)
		if !strings.Contains(wloText, "not set yet") {
			// Go's regexp engine (RE2) has no lookahead, so we extract the
			// "## Handoff Packet" section by locating its header and slicing up
			// to the next "## " heading (or end of file) explicitly.
			headerRe := regexp.MustCompile(`(?m)^##\s*Handoff Packet\s*$`)
			if loc := headerRe.FindStringIndex(wloText); loc != nil {
				rest := wloText[loc[1]:]
				if nextLoc := regexp.MustCompile(`(?m)^##`).FindStringIndex(rest); nextLoc != nil {
					rest = rest[:nextLoc[0]]
				}
				packet := strings.TrimSpace(rest)
				requiredFields := []struct{ field, msg string }{
					{"Agent:", "Handoff Packet is missing Agent"},
					{"Timestamp:", "Handoff Packet is missing Timestamp"},
					{"Objective:", "Handoff Packet is missing Objective"},
					{"Next best step:", "Handoff Packet is missing Next best step"},
				}
				for _, rf := range requiredFields {
					fieldRegex := regexp.MustCompile(`(?m)^-\s*\*?\*?` + regexp.QuoteMeta(rf.field) + `\*?\*?\s*(.*)$`)
					fieldMatch := fieldRegex.FindStringSubmatch(packet)
					if len(fieldMatch) < 2 || strings.TrimSpace(fieldMatch[1]) == "" {
						warnings = append(warnings, fmt.Sprintf("WHERE_LEFT_OFF.md: %s", rf.msg))
					}
				}
			}
		}
	}

	if len(warnings) > 0 {
		fmt.Println("evidence_quality_issues")
		for _, w := range warnings {
			fmt.Printf("  - %s\n", w)
		}
		if *strictPtr {
			os.Exit(1)
		} else {
			os.Exit(2)
		}
	}

	fmt.Println("evidence_quality_ok")
	return true
}
