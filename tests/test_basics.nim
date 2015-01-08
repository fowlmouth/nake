import os
import re
{. push hints:off warnings:off .}
import osproc
{. pop .}

## Tests the basic operations that nake should perform

const
  nakeFile = "nakefile".changeFileExt("nim")
  nakeExe = "nakefile".changeFileExt(ExeExt)
  basicsDir = "test_dir_basics"
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

echo "# test_basics.nim"
echo ""

echo "- Test that nakefile compiles"
output = execCmdEx(nimExe & " --verbosity:0 c " & joinPath(basicsDir, nakeFile))
assert output.exitCode == 0, output.output

echo "- Test nakefile default command"
output = execCmdEx(nakePathExe)
assert output.exitCode == 0, output.output
assert output.output.match(getRe("nakefile default worked")), output.output

echo "- Test nakefile non-default command"
output = execCmdEx(nakePathExe & " testcmd")
assert output.exitCode == 0, output.output
assert output.output.match(getRe("nakefile testcmd worked")), output.output

echo "- Test list commands from c-l"
output = execCmdEx(nakePathExe & " -t")
assert output.exitCode == 0, output.output
assert output.output.match(getRe("default"))
assert output.output.match(getRe("list"))
assert output.output.match(getRe("testcmd"))

echo "- Test list commands from 'list' command"
output = execCmdEx(nakePathExe & " list")
assert output.exitCode == 0, output.output
assert output.output.match(getRe("default"))
assert output.output.match(getRe("list"))
assert output.output.match(getRe("testcmd"))

echo "- Test commands listed in order given"
output = execCmdEx(nakePathExe & " -t")
assert output.exitCode == 0, output.output
assert output.output.match(getRe("default", "testcmd", "list"))

# For future reference if this is added?
#echo "- Test multiple commands can be given"
#output = execCmdEx(nakePathExe & " default testcmd")
#assert output.exitCode == 0, output.output
#assert output.output.match(getRe("nakefile default worked", "nakefile testcmd worked")), output.output
