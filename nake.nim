discard """
DO AS THOU WILST PUBLIC LICENSE

Whoever should stumble upon this document is henceforth and forever
entitled to DO AS THOU WILST with aforementioned document and the
contents thereof.

As said in the Olde Country, `Keepe it Gangster'."""

## Documentation for the `nake module <https://github.com/fowlmouth/nake>`_.
##
## This module imports and exports all of `nakelib <nakelib.html>`_, which
## contains the procs and macros you can use to define and run tasks in your
## nakefiles.
##
## On top of these procs and macros, this module contains special code with an
## `isMainModule <http://nim-lang.org/system.html#isMainModule>`_ static
## compilation branch. If the ``nake`` module is being run as a stand alone
## executable, it will check for an existing ``nakefile.nim`` file and attempt
## to run or compile it. On the other hand if the ``nake`` module is being
## imported, it will `register a quit procedure
## <http://nim-lang.org/system.html#addQuitProc>`_ to turn the the program into
## a runnable nakefile.
##
## See the docstring of the `runTask() <nakelib.html#runTask>`_ proc for an
## example of a simple nakefile


import strutils, parseopt2, tables, os, rdstdin, times, nakelib
export strutils, parseopt2, tables, os, rdstdin, nakelib


when isMainModule:
  proc mainExecution() =
    ## Entry point when this module is run as an executable.
    ##
    ## All the binary does is forward cli arguments to `nim c -r nakefile.nim
    ## $ARGS`
    let nakeSource = "nakefile.nim"
    if not existsFile(nakeSource):
      echo "No ", nakeSource, " found. Current working dir is ", getCurrentDir()
      quit 1

    let
      nakeExe = "nakefile".addFileExt(ExeExt)
      nakeSelf = getApplicationFilename()

    var
      args = join(commandLineParams(), " ")
      dependencies = @[nakeSource]

    if nakeSelf.len > 0:
      dependencies.add(nakeSelf)

    if nakeExe.needsRefresh(dependencies):
      # Recompiles the nakefile before running it.
      direSilentShell("Compiling nakefile...", nimExe, "c", nakeSource)

    quit (if shell("." / nakeExe, args): 0 else: 1)

  mainExecution()
else:
  proc moduleHook() {.noconv.} =
    ## Hook registered when the module is imported by someone else.
    var
      task: string
      printTaskList: bool
    for kind, key, val in getOpt():
      case kind
      of cmdLongOption, cmdShortOption:
        case key.tolower
        of "careful", "c":
          validateShellCommands = true
        of "tasks", "t":
          printTaskList = true
        else:
          echo "Unknown option: ", key, ": ", val
      of cmdArgument:
        task = key
      else: discard
    # If the user specified a task but it doesn't exist, abort.
    let badTask = (not task.isNil and (not tasks.hasKey(task)))
    if task.isNil and tasks.hasKey(defaultTask):
      echo "No task specified, running default task defined by nakefile."
      task = defaultTask
    if printTaskList or task.isNil or badTask:
      if badTask: echo "Task '" & task & "' not found."
      listTasks()
      quit(if badTask: 1 else: 0)
    runTask task

  addQuitProc moduleHook
