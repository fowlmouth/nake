import "../../nake" # use this because then we don't need
                    # to install just to be able to test
import sequtils

nake.listTasks = proc() =
  echo "Available tasks: ", toSeq(nake.tasks.keys).join(", ")

task "default", "Default task":
  echo "nakefile default worked"

task "testcmd", "Testing task":
  echo "nakefile testcmd worked"

const privateTasks = ["testcmd"]

task "test-blacklist", "Test another way of listing commands":
  nake.listTasks = proc() =
    echo "Available tasks:"
    for taskKey in nake.tasks.keys:
      # Show only public tasks.
      if taskKey in privateTasks:
        continue
      echo "\t", taskKey

  listTasks()

task "list", "Lists all commands":
  listTasks()
