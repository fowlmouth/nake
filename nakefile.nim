import nake

task "install", "compile and install nake binary":
  direShell "nimrod", "c", "nake"
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
  
  moveFile "nake", path[index]/"nake"
  echo "Great success!"


