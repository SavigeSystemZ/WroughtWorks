package commands

import (
	"flag"
	"fmt"
	"os"
	"os/user"
	"path/filepath"
	"strconv"
	"syscall"
)

func RunCheckRepoPermissions(args []string) bool {
	fs := flag.NewFlagSet("check-repo-permissions", flag.ContinueOnError)
	fixModesPtr := fs.Bool("fix-modes", false, "Add user write permission back to user-owned files")
	
	fs.Usage = func() {
		fmt.Println("Usage: check-repo-permissions [target-repo] [--fix-modes]")
		fmt.Println("\nValidate that repo files outside .git are owned by the current user and group,")
		fmt.Println("and that they remain writable by the current user.")
		fmt.Println("\nOptions:")
		fmt.Println("  --fix-modes  Add user write permission back to user-owned files and")
		fmt.Println("               directories when mode drift is the only problem.")
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

	currentUser, err := user.Current()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to get current user: %v\n", err)
		return false
	}
	expectedUID, _ := strconv.Atoi(currentUser.Uid)
	expectedGID, _ := strconv.Atoi(currentUser.Gid)
	expectedUser := currentUser.Username
	
	currentGroup, err := user.LookupGroupId(currentUser.Gid)
	expectedGroup := currentUser.Gid
	if err == nil {
		expectedGroup = currentGroup.Name
	}

	var ownershipIssues []string
	var modeIssues []string
	var fixedCount int

	err = filepath.Walk(repo, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil
		}
		
		if info.IsDir() && info.Name() == ".git" {
			return filepath.SkipDir
		}

		rel, _ := filepath.Rel(repo, path)
		if rel == "." {
			return nil
		}

		stat, ok := info.Sys().(*syscall.Stat_t)
		if !ok {
			return nil
		}

		uid := int(stat.Uid)
		gid := int(stat.Gid)

		isOwnedByUser := uid == expectedUID && gid == expectedGID
		if !isOwnedByUser {
			modeStr := info.Mode().String()
			ownershipIssues = append(ownershipIssues, fmt.Sprintf("%s %d:%d %s", modeStr, uid, gid, rel))
		}

		mode := info.Mode()
		isWritable := (mode.Perm() & 0200) != 0

		if isOwnedByUser && !isWritable {
			if *fixModesPtr {
				newPerm := mode.Perm() | 0200
				if info.IsDir() {
					newPerm = mode.Perm() | 0700
				}
				os.Chmod(path, newPerm)
				fixedCount++
			} else {
				modeStr := info.Mode().String()
				modeIssues = append(modeIssues, fmt.Sprintf("%s %d:%d %s", modeStr, uid, gid, rel))
			}
		} else if !isOwnedByUser && !isWritable {
			modeStr := info.Mode().String()
			modeIssues = append(modeIssues, fmt.Sprintf("%s %d:%d %s", modeStr, uid, gid, rel))
		}

		return nil
	})

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error walking repo: %v\n", err)
		return false
	}

	if fixedCount > 0 {
		fmt.Printf("repo_permission_modes_fixed count=%d\n", fixedCount)
	}

	if len(ownershipIssues) == 0 && len(modeIssues) == 0 {
		fmt.Println("repo_permissions_ok")
		return true
	}

	fmt.Println("repo_permissions_issues_detected")

	if len(ownershipIssues) > 0 {
		fmt.Println("ownership_mismatch:")
		for _, issue := range ownershipIssues {
			fmt.Printf("  %s\n", issue)
		}
	}

	if len(modeIssues) > 0 {
		fmt.Println("not_writable_by_current_user:")
		for _, issue := range modeIssues {
			fmt.Printf("  %s\n", issue)
		}
	}

	fmt.Printf("expected_owner: %s:%s\n", expectedUser, expectedGroup)
	fmt.Println("suggested_repair:")
	fmt.Printf("  sudo chown -R <intended-user>:<intended-group> %s\n", repo)
	fmt.Printf("  find %s -type d -name .git -prune -o -type d ! -writable -exec chmod u+rwx {} +\n", repo)
	fmt.Printf("  find %s -type d -name .git -prune -o -type f ! -writable -exec chmod u+rw {} +\n", repo)

	return false
}
