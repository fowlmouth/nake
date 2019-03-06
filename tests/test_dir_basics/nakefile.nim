import "../../nake" # use this because then we don't need
                    # to install just to be able to test

task "default", "Default task":
  echo "nakefile default worked"

task "testcmd", "Testing task":
  echo "nakefile testcmd worked"

task "test-careful", "Runs a shell command":
  shell("echo 'nake' 'rules'")

task "list", "Lists all commands":
  listTasks()

task "needsRefresh", "Tests needsRefresh":
  try:
    writeFile("file1.txt", "")
    sleep(1001)
    writeFile("file2.txt", "")
    if "file1.txt".needsRefresh("file2.txt"):
      echo "file1 older than file2"
    if needsRefresh(["file1.txt"], ["file2.txt"]):
      echo "[file1] older than [file2]"
  finally:
    removeFile("file1.txt")
    removeFile("file2.txt")