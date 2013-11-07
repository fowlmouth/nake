import nake

proc mvFile(`from`,to: string) = 
  moveFile(`from`,to)
  echo "Moved file"

when defined(Linux):
  proc symlinkFile (file, to: string) =
    removeFile(to)
    direShell("ln -s", file.expandFileName, to)
    echo "Symlinked file"



task "docs", "generate user documentation for nake API":
  echo "Generating nake.html"
  direShell "nimrod", "doc2", "nake.nim"

task "install", "compile and install nake binary":
  direShell "nimrod", "c", "nake"
  
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

