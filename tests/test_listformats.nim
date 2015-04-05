import os
import re
{. push hints:off warnings:off .}
import osproc
{. pop .}

## Tests the basic operations that nake should perform

const
  nakeFile = "nakefile".changeFileExt("nim")
  nakeExe = "nakefile".changeFileExt(ExeExt)
  basicsDir = "test_dir_otherformat"
  nakePathExe = joinPath(basicsDir, nakeExe)

var nimExe = findExe("nim")
if nimExe.len < 1:
  nimExe = findExe("nimrod")

proc getRe(phrases: varargs[string]): Regex =
  var s = ".*"
  for phrase in phrases:
    s.add(phrase)
    s.add(".*")

  return re(s, {reDotAll, reIgnoreCase})

var output: tuple[output: TaintedString, exitCode: int]

echo "# test_listformats.nim"
echo ""

echo "- Test that nakefile compiles"
output = execCmdEx(nimExe & " --verbosity:0 c " & joinPath(basicsDir, nakeFile))
doAssert output.exitCode == 0, output.output

echo "- Test command format can change"
output = execCmdEx(nakePathExe & " -t")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("default, testcmd, test-blacklist, list"))

echo "- Test command format can change (list command)"
output = execCmdEx(nakePathExe & " list")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("default, testcmd, test-blacklist, list"))

echo "- Test format change for individual tasks"
output = execCmdEx(nakePathExe & " test-blacklist")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("default", "test-blacklist", "list")), output.output
doAssert (not output.output.match(getRe("testcmd")))
