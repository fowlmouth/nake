discard """
DO AS THOU WILST PUBLIC LICENSE

Whoever should stumble upon this document is henceforth and forever
entitled to DO AS THOU WILST with aforementioned document and the
contents thereof.

As said in the Olde Country, `Keepe it Gangster'."""

## Reusable module for the `nake module <https://github.com/fowlmouth/nake>`_.
##
## This ``nakelib`` module implements all of `nake <nake.html>`_'s
## functionality except some *magic* code at the end of the `nake <nake.html>`_
## module which `registers a quit procedure
## <http://nim-lang.org/system.html#addQuitProc>`_ when imported to turn the
## program into a runnable nakefile.
##
## Import this module instead of `nake <nake.html>`_ if you want to use any of
## its procs without affecting your program execution.

import strutils, parseopt2, tables, os, rdstdin, times
export strutils, parseopt2, tables, os, rdstdin


type
  PTask* = ref object ## Defines a task with a description and action.
    desc*: string
    action*: TTaskFunction

  TTaskFunction* = proc() ## \
  ## Type for the actions associated with a task name.
  ##
  ## Used in `PTask <#PTask>`_ objects.

  TTaskLister* = proc() ## \
  ## Type for the ``proc`` which prints out the list of available tasks.
  ##
  ## Assigned to the `listTasks <#listTasks>`_ global.


var
  tasks* = initOrderedTable[string, PTask](32) ## \
  ## Holds the list of defined tasks.
  ##
  ## Use the `task() <#task>`_ template to add elements to this variable.

  careful* = false ## \
  ## Set this global to ``true`` if you want the `shell() <#shell>`_ and
  ## `direShell() <#direShell>`_ procs to ask the user for confirmation before
  ## executing a command.

  nimExe*: string ## \
  ## Full path to the Nim compiler binary.
  ##
  ## You can use this in your code to avoid having to hardcode the path to the
  ## compiler. The path is obtained at runtime. First the ``nim`` binary is
  ## probed, and if that fails, the older ``nimrod`` is searched for backwards
  ## compatibility. Example:
  ##
  ## .. code-block:: nimrod
  ##   if "nake.html".needsRefresh("nake.nim"):
  ##     echo "nake.nim -> nake.html"
  ##     direShell nimExe, "doc2", "--verbosity:0", "--index:on", "nake.nim"


const
  defaultTask* = "default" ## \
  ## String with the name of the default task nake will run `if you define it
  ## and the user doesn't specify any task <#listTasks>`_.


nimExe = findExe("nim")
if nimExe.len < 1:
  nimExe = findExe("nimrod")


proc askShellCMD (cmd: string): bool =
  if careful:
    let ans = readLineFromSTDIN ("Run? `$#` [N/y]\L" % cmd).toLower
    if ans[0] in {'y','Y'}:
      result = execShellCMD(cmd) == 0
    else:
      return false
  else:
    result = execShellCMD(cmd) == 0


proc shell*(cmd: varargs[string, `$`]): bool {.discardable.} =
  ## Invokes an external command.
  ##
  ## The proc will return ``false`` if the command exits with a non zero code,
  ## ``true`` otherwise.
  ##
  ## This proc respects the value of the `careful global <#careful>`_.
  result = askShellCMD(cmd.join(" "))


proc direShell*(cmd: varargs[string, `$`]): bool {.discardable.} =
  ## Wrapper around the `shell() <#shell>`_ proc.
  ##
  ## Instead of returning a non zero value like `shell() <#shell>`_,
  ## ``direShell()`` `quits <http://nim-lang.org/system.html#quit>`_ if the
  ## process does not return 0.
  result = shell(cmd)
  if not result: quit 1


proc cd*(dir: string) {.inline.} =
  ## Changes the current directory.
  ##
  ## The change is permanent for the rest of the execution, since this is just
  ## a shortcut for `os.setCurrentDir()
  ## <http://nim-lang.org/os.html#setCurrentDir,string>`_ . Use the `withDir()
  ## <#withDir>`_ template if you want to perform a temporary change only.
  setCurrentDir(dir)


template withDir*(dir: string; body: stmt): stmt =
  ## Changes the current directory temporarily.
  ##
  ## If you need a permanent change, use the `cd() <#cd>`_ proc. Usage example:
  ##
  ## .. code-block:: nimrod
  ##   withDir "foo":
  ##     # inside foo
  ##   #back to last dir
  var curDir = getCurrentDir()
  cd(dir)
  body
  cd(curDir)


proc needsRefresh*(target: string, src: varargs[string]): bool =
  ## Returns true if target is missing or src has newer modification date.
  ##
  ## This is a convenience proc you can use in your tasks to verify if
  ## compilation for a binary should happen. The proc will return true if
  ## ``target`` doesn't exists or any of the file paths in ``src`` have a more
  ## recent last modification timestamp. All paths in ``src`` must be reachable
  ## or else the proc will raise an exception. Example:
  ##
  ## .. code-block:: nimrod
  ##   import nake, os
  ##
  ##   let
  ##     src = "prog.nim"
  ##     exe = src.changeFileExt(exeExt)
  ##   if exe.needsRefresh(src):
  ##     direShell nimExe, "c", src
  ##   else:
  ##     echo "All done!"
  assert len(src) > 0, "Pass some parameters to check for"
  var targetTime: float
  try:
    targetTime = toSeconds(getLastModificationTime(target))
  except OSError:
    return true

  for s in src:
    let srcTime = toSeconds(getLastModificationTime(s))
    if srcTime > targetTime:
      return true


proc newTask (desc: string; action: TTaskFunction): PTask =
  result = PTask(desc: desc, action: action)


proc runTask*(name: string) {.inline.} = ## \
  ## Runs the specified task.
  ##
  ## You can call this proc to *chain* other tasks for the current task and
  ## avoid repeating code. Example:
  ##
  ## .. code-block:: nimrod
  ##   import nake, os
  ##
  ##   ...
  ##
  ##   task "docs", "generates docs for module":
  ##     echo "Generating " & moduleHtml
  ##     direShell nimExe, "doc", moduleNim
  ##
  ##   task "install_docs", "copies docs to " & docInstallDir:
  ##     runTask("docs")
  ##     echo "Copying documentation to " & docInstallDir
  ##     copyFile(moduleHtml, docInstallDir / moduleHtml)
  tasks[name].action()


template task*(name: string; description: string; body: stmt): stmt {.immediate.} =
  ## Defines a task for nake.
  ##
  ## Pass the name of the task, the description that will be displayed to the
  ## user when `nake` is invoked, and the body of the task. Example:
  ##
  ## .. code-block:: nimrod
  ##   import nake
  ##
  ##   task "bin", "compiles all binaries":
  ##     for binName in binaries:
  ##       echo "Generating " & binName
  ##       direShell nimExe, "c", binName
  bind tasks,newTask
  tasks[name] = newTask(description, proc() {.closure.} =
    body)

proc listTasksImpl*() =
  ## Default implementation for listing tasks to stdout.
  ##
  ## This implementation will print out each task and it's description to the
  ## command line. You can change the value of the `listTasks <#listTasks>`_
  ## global if you don't like it.
  assert tasks.len > 0
  echo "Available tasks:"
  for name, task in pairs(tasks):
    echo name, " - ", task.desc


var listTasks*: TTaskLister = listTasksImpl ## \
## Holds the proc that is used by default to list available tasks to the user.
##
## You can call the proc held here inside your `defaultTask <#defaultTask>`_
## task to tell the user about available options if your default task doesn't
## have anything to do.  You can assign to this var to provide another
## implementation, the default is `listTasksImpl() <#listTasksImpl>`_.
## Example:
##
## .. code-block:: nimrod
##   import nake, sequtils
##
##   nake.listTasks = proc() =
##     ## only lists the task names, no descriptions
##     echo "Available tasks: ", toSeq(nake.tasks.keys).join(", ")
##
##   task defaultTask, "lists all tasks":
##     listTasks()
##
## Here is an alternative version which blacklists tasks to end users.
## They may not be interested or capable of running some of them due to extra
## development dependencies:
##
## .. code-block:: nimrod
##   const privateTasks = ["dist", defaultTask, "testRemote", "upload"]
##
##   nake.listTasks = proc() =
##     echo "Available tasks:"
##     for taskKey in nake.tasks.keys:
##       # Show only public tasks.
##       if taskKey in privateTasks:
##         continue
##       echo "\t", taskKey
