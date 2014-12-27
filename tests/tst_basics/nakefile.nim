import nake

task "default", "Default task":
  echo "nakefile default worked"

task "testcmd", "Testing task":
  echo "nakefile testcmd worked"

task "list", "Lists all commands":
  listTasks()
