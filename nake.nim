discard """
DO AS THOU WILST PUBLIC LICENSE

Whoever should stumble upon this document is henceforth and forever
entitled to DO AS THOU WILST with aforementioned document and the
contents thereof. 

As said in the Olde Country, `Keepe it Gangster'."""

import strutils, parseopt, tables, os

type
  PTask* = ref object
    desc*: string
    action*: TTaskFunction
  TTaskFunction* = proc() {.closure.}
var 
  tasks = initTable[string, PTask](32)

proc newTask(desc: string; action: TTaskFunction): PTask
proc runTask*(name: string) {.inline.}
proc shell*(cmd: varargs[string, `$`]): int {.discardable.}
proc cd*(dir: string) {.inline.}

template nakeImports*(): stmt {.immediate.} =
  ## Import required modules, if they need to be imported.
  ## This is no longer necessary as it's called from task()
  when not defined(tables): import tables
  when not defined(parseopt): import parseopt
  when not defined(strutils): import strutils
  when not defined(os): import os

template task*(name: string; description: string; body: stmt): stmt {.immediate.} =
  nakeImports()
  bind tasks
  tasks[name] = PTask(desc: description, action: proc() {.closure.} =
    body)

proc newTask (desc: string; action: TTaskFunction): PTask = PTask(
  desc: desc, action: action)
proc runTask (name: string) = tasks[name].action()

proc shell*(cmd: varargs[string, `$`]): int =
  result = execShellCmd(cmd.join(" "))
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
  ## maybe there should be some option to not rebuild the nakefile everytime? idk
  if not existsFile("nakefile.nim"):
    echo "No nakefile.nim found. Current working dir is ", getCurrentDir()
    quit 1
  var args = ""
  for i in 1..paramCount():
    args.add paramStr(i)
    args.add " "
  quit shell("nimrod", "c", "-r", "nakefile.nim", args)
else:
  addQuitProc proc {.noconv.} =
    var 
      task: string
      printTaskList: bool
    for kind, key, val in getOpt():
      case kind
      of cmdLongOption, cmdShortOption:
        case key.tolower
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
