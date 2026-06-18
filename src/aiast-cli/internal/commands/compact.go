package commands

import (
	"archive/tar"
	"compress/gzip"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"
)

func RunCompact(args []string) {
	compactCmd := flag.NewFlagSet("compact", flag.ExitOnError)
	targetRepo := compactCmd.String("repo", ".", "Target repository path")
	daysOld := compactCmd.Int("days", 14, "Threshold in days for stale context files")
	compactCmd.Parse(args)

	contextDir := filepath.Join(*targetRepo, "_system", "context")
	if _, err := os.Stat(contextDir); os.IsNotExist(err) {
		fmt.Printf("No context directory found in %s\n", *targetRepo)
		os.Exit(0)
	}

	coldStorage := filepath.Join(contextDir, "cold-storage")
	os.MkdirAll(coldStorage, 0755)

	staleThreshold := time.Now().AddDate(0, 0, -(*daysOld))
	var staleFiles []string

	// Read _system/context/
	entries, err := os.ReadDir(contextDir)
	if err != nil {
		fmt.Printf("Error reading context directory: %v\n", err)
		os.Exit(1)
	}

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}

		name := entry.Name()
		if filepath.Ext(name) != ".md" {
			continue
		}

		// Keep essential files
		if name == "VALIDATION_EVIDENCE.md" || name == "CURRENT_STATUS.md" || name == "ARCHIVE_SUMMARY.md" {
			continue
		}

		info, err := entry.Info()
		if err != nil {
			continue
		}

		if info.ModTime().Before(staleThreshold) {
			staleFiles = append(staleFiles, filepath.Join(contextDir, name))
		}
	}

	if len(staleFiles) == 0 {
		fmt.Printf("No stale context files older than %d days found.\n", *daysOld)
		os.Exit(0)
	}

	archiveName := fmt.Sprintf("archive_%s.tar.gz", time.Now().Format("20060102_150405"))
	archivePath := filepath.Join(coldStorage, archiveName)

	fmt.Println("Compacting the following stale context files:")
	err = createTarGz(archivePath, staleFiles)
	if err != nil {
		fmt.Printf("Error creating archive: %v\n", err)
		os.Exit(1)
	}

	for _, file := range staleFiles {
		fmt.Printf(" - %s\n", filepath.Base(file))
		os.Remove(file)
	}

	fmt.Println("\n================================================================")
	fmt.Println("SUCCESS: Stale context files have been zipped into cold storage:")
	fmt.Printf(" -> %s\n", archivePath)
	fmt.Println("================================================================")
	fmt.Println("ACTION REQUIRED BY AGENT:")
	fmt.Println("1. If those files contained important long-term architectural decisions,")
	fmt.Println("   you must read the archive and summarize them into _system/context/ARCHIVE_SUMMARY.md")
	fmt.Println("2. Otherwise, no further action is needed. Context bloat has been resolved.")
	fmt.Println("================================================================")
}

func createTarGz(archivePath string, files []string) error {
	out, err := os.Create(archivePath)
	if err != nil {
		return err
	}
	defer out.Close()

	gw := gzip.NewWriter(out)
	defer gw.Close()

	tw := tar.NewWriter(gw)
	defer tw.Close()

	for _, file := range files {
		info, err := os.Stat(file)
		if err != nil {
			return err
		}

		header, err := tar.FileInfoHeader(info, info.Name())
		if err != nil {
			return err
		}

		header.Name = filepath.Base(file)

		if err := tw.WriteHeader(header); err != nil {
			return err
		}

		f, err := os.Open(file)
		if err != nil {
			return err
		}

		if _, err := io.Copy(tw, f); err != nil {
			f.Close()
			return err
		}
		f.Close()
	}

	return nil
}
