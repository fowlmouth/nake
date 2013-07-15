discard """
DO AS THOU WILST PUBLIC LICENSE

Whoever should stumble upon this document is henceforth and forever
entitled to DO AS THOU WILST with aforementioned document and the
contents thereof. 

As said in the Olde Country, `Keepe it Gangster'."""

import strutils, parseopt, tables, os, rdstdin, times
export strutils, parseopt, tables, os, rdstdin

type
  PTask* = ref object
    desc*: string
    action*: TTaskFunction
  TTaskFunction* = proc() 
var 
  tasks = initTable[string, PTask](32)
  careful = false

proc newTask(desc: string; action: TTaskFunction): PTask
proc runTask*(name: string) {.inline.}
proc shell*(cmd: varargs[string, `$`]): bool {.discardable.}
proc cd*(dir: string) {.inline.}

discard """ template nakeImports*(): stmt {.immediate.} =
  ## Import required modules, if they need to be imported.
  ## This is no longer necessary as it's called from task()
  when not defined(tables): import tables
  when not defined(parseopt): import parseopt
  when not defined(strutils): import strutils
  when not defined(os): import os
 """


proc newTask (desc: string; action: TTaskFunction): PTask = PTask(
  desc: desc, action: action)
proc runTask (name: string) = tasks[name].action()

template task*(name: string; description: string; body: stmt): stmt {.immediate.} =
  bind tasks,newTask
  tasks[name] = newTask(description, proc() {.closure.} =
    body)

proc askShellCMD (cmd: string): bool =
  if careful:
    let ans = readLineFromSTDIN ("Run? `$#` [N/y]\L" % cmd).toLower
    if ans[0] in {'y','Y'}:
      result = execShellCMD(cmd) == 0
    else: return false
  else:
    result = execShellCMD(cmd) == 0

proc shell*(cmd: varargs[string, `$`]): bool =
  askShellCMD(cmd.join(" "))
proc direShell*(cmd: varargs[string, `$`]): bool {.discardable.} =
  ## like shell() but quit if the process does not return 0
  result = shell(cmd)
  if not result: quit 1

proc cd*(dir: string) = setCurrentDir(dir)
template withDir*(dir: string; body: stmt): stmt =
  ## temporary cd
  ## withDir "foo":
  ##   # inside foo
  ## #back to last dir
  var curDir = getCurrentDir()
  cd(dir)
  body
  cd(curDir)

when isMainModule:
  ## All the binary does is forward cli arguments to `nimrod c -r nakefile.nim $ARGS`
  if not existsFile("nakefile.nim"):
    echo "No nakefile.nim found. Current working dir is ", getCurrentDir()
    quit 1
  var args = ""
  for i in 1..paramCount():
    args.add paramStr(i)
    args.add " "

  # Detects if the nakefile binary is stale and should be rebuilt.
  try:
    if fpUserExec in getFilePermissions("nakefile"):
      let
        binaryTime = toSeconds(getLastModificationTime("nakefile"))
        nakefileTime = toSeconds(getLastModificationTime("nakefile.nim"))
      if binaryTime > nakefileTime:
        quit (if shell("." / "nakefile", args): 0 else: 1)
  except EOS:
    # Reached if for example nakefile doesn't exist, so permissions test fails.
    nil

  # Recompiles the nakefile and runs it.
  quit (if shell("nimrod", "c", "-r", "nakefile.nim", args): 0 else: 1)
else:
  addQuitProc proc {.noconv.} =
    var 
      task: string
      printTaskList: bool
    for kind, key, val in getOpt():
      case kind
      of cmdLongOption, cmdShortOption:
        case key.tolower
        of "careful", "c":
          careful = true
        of "tasks", "t":
          printTaskList = true
        else: 
          echo "Unknown option: ", key, ": ", val
      of cmdArgument:
        task = key
      else: nil
    if printTaskList or task.isNil or not(tasks.hasKey(task)):
      echo "Available tasks:"
      for name, task in pairs(tasks):
        echo name, " - ", task.desc
      quit 0
    runTask task
