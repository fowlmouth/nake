import nake
import sequtils

proc mvFile(`from`,to: string) =
  moveFile(`from`,to)
  echo "Moved file"

when defined(Linux):
  proc symlinkFile (file, to: string) =
    removeFile(to)
    direShell("ln -s", file.expandFileName, to)
    echo "Symlinked file"


proc buildDocs() =
  for name in ["nake", "nakelib"]:
    let
      dest = name & ".html"
      src = name & ".nim"

    if dest.needsRefresh(src):
      direSilentShell(src & " -> " & dest,
        nimExe, "doc2", "--verbosity:0", "--index:on", src)

  for rstSrc in walkFiles("*.rst"):
    let rstDest = rstSrc.changeFileExt(".html")
    if not rstDest.needsRefresh(rstSrc): continue
    direSilentShell(rstSrc & " -> " & rstDest,
      nimExe & " rst2html --verbosity:0 --index:on -o:" &
        rstDest & " " & rstSrc)

  direSilentShell("Building theindex.html", nimExe, "buildIndex .")



proc runTests() =
  var testResults: seq[bool] = @[]

  withDir "tests":
    for nakeFile in walkFiles "*.nim":
      let nakeExe = nakeFile.changeFileExt(ExeExt)
      if not shell(nimExe, "c",
          "--noNimblePath --verbosity:0 -d:debug -r", nakeFile):
        testResults.add(false)
        continue
      # Repeat compilation in release mode.
      if not shell(nimExe, "c",
          "--noNimblePath --verbosity:0 -d:release -r", nakeFile):
        testResults.add(false)
        continue
      testResults.add(true)
      echo "" # prettify the output

  let
    total = testResults.len
    successes = filter(testResults, proc(x:bool): bool = x).len

  echo ("Tests Complete: ", total, " test files run, ",
        successes, " test files succeeded.")


proc installNake() =
  direSilentShell("Compiling nake...", nimExe, "c", "nake")

  var
    installMethod: proc(src,dest:string)# = mvFile

  when defined(Linux):
    echo "How to install the nake binary?\L",
      "  * [M]ove file\L",
      "    [S]ymlink file"
    case stdin.readLine.toLowerAscii
    of "m","move": installMethod = mvFile
    of "s","symlink": installMethod = symlinkFile
  else:
    installMethod = mvFile

  let path = getEnv("PATH").split(PathSep)
  echo "Your $PATH:"
  for index, dir in pairs(path):
    echo "  ", index, ". ", dir

  echo "Where to install nake binary? (quit with ^C or quit or exit)"
  let ans = stdin.readLine().toLowerAscii
  var index = 0
  case ans
  of "q", "quit", "x", "exit":
    quit 0
  else:
    index = parseInt(ans)

  if index notin 0 ..< path.len:
    echo "Invalid index."
    quit 1

  installMethod "nake", path[index]/"nake"


proc switchToGhPages(iniPathOrDir = ".") =
  ## Forces changing git branch to ``gh-pages`` and running
  ## ``gh_nimrod_doc_pages``.
  ##
  ## **This is a potentially destructive action!**. Pass the directory where
  ## the ``gh_nimrod_doc_pages.ini`` file lives, or the path to the specific
  ## file if you renamed it.
  assert(iniPathOrDir.len != 0)
  let
    ghExe = findExe("gh_nimrod_doc_pages")
    gitExe = findExe("git")

  if ghExe.len < 1:
    quit("""Could not find gh_nimrod_doc_pages binary in $PATH, aborting.
You may find it at https://github.com/gradha/gh_nimrod_doc_pages.
Or maybe run 'nimble install gh_nimrod_doc_pages'.
""")

  if gitExe.len < 1:
    quit("Could not find git binary in $PATH, aborting")

  echo "Changing branches to render gh-pages…"
  let
    nakeExe = "nakefile".addFileExt(ExeExt)
    ourselves = readFile(nakeExe)
  direShell gitExe & " checkout gh-pages"
  # Keep ingored files http://stackoverflow.com/a/3801554/172690.
  when defined(posix):
    shell "rm -Rf `git ls-files --others --exclude-standard`"
  removeDir("gh_docs")
  direShell ghExe & " -c " & iniPathOrDir
  writeFile(nakeExe, ourselves)
  direShell "chmod 775 nakefile"
  echo "All commands run, now check the output and commit to git."
  when defined(macosx):
    shell "open index.html"
  echo "Wen you are done come back with './" & nakeExe & " postweb'."


proc switchBackFromGhPages() =
  ## Counterpart of ``switchToGhPages``.
  let gitExe = findExe("git")
  if gitExe.len < 1:
    quit("Could not find git binary in $PATH, aborting")

  echo "Forcing changes back to master."
  direShell gitExe & " checkout -f @{-1}"
  echo "Updating submodules just in case."
  direShell gitExe & " submodule update"
  removeDir("gh_docs")


task "docs", "generate user documentation for nake API and local rst files":
  buildDocs()
  echo "Finished generating docs"

task "test", "runs any tests in the `./tests` directory":
  runTests()

task "install", "compile and install nake binary":
  installNake()
  echo "Great success!"

task "web", "switches to gh-pages branch and runs gh_nimrod_doc_pages":
  switchToGhPages("web.ini")
  echo "Now you can run 'git add .' if everything looks good."

task "postweb", "switches back from gh-pages":
  switchBackFromGhPages()
  echo "Back from gh-pages"
