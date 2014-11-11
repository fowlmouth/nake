import nake

when findExe("nim") == "":
  const nimExe = "nim"
else: # assume at the very least nimrod exists.  I mean, how did you get this far otherwise?
  const nimExe = "nimrod"

proc mvFile(`from`,to: string) = 
  moveFile(`from`,to)
  echo "Moved file"

when defined(Linux):
  proc symlinkFile (file, to: string) =
    removeFile(to)
    direShell("ln -s", file.expandFileName, to)
    echo "Symlinked file"


task "docs", "generate user documentation for nake API and local rst files":
  if "nake.html".needsRefresh("nake.nim"):
    echo "nake.nim -> nake.html"
    direShell nimExe, "doc2", "--verbosity:0", "nake.nim"

  for rstSrc in walkFiles("*.rst"):
    let rstDest = rstSrc.changeFileExt(".html")
    if not rstDest.needsRefresh(rstSrc): continue
    if not shell(nimExe & " rst2html --verbosity:0 -o:" & rstDest & " " & rstSrc):
      quit("Could not generate html doc for " & rstSrc)
    else:
      echo rstSrc, " -> ", rstDest
  echo "Finished generating docs"

task "install", "compile and install nake binary":
  direShell nimExe, "c", "nake"
  
  var 
    installMethod: proc(src,dest:string)# = mvFile
  
  when defined(Linux):
    echo "How to install the nake binary?\L",
      "  * [M]ove file\L",
      "    [S]ymlink file"
    case stdin.readLine.toLower
    of "m","move": installMethod = mvFile
    of "s","symlink": installMethod = symlinkFile
  else:
    installMethod = mvFile
  
  let path = getEnv("PATH").split(PathSep)
  echo "Your $PATH:"
  for index, dir in pairs(path):
    echo "  ", index, ". ", dir

  echo "Where to install nake binary? (quit with ^C or quit or exit)"
  let ans = stdin.readLine().toLower
  var index = 0
  case ans
  of "q", "quit", "x", "exit":
    quit 0
  else:
    index = parseInt(ans)

  if index notin 0 .. <path.len:
    echo "Invalid index."
    quit 1

  installMethod "nake", path[index]/"nake"
  echo "Great success!"

