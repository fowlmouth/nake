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
doAssert output.exitCode == 0, output.output

echo "- Test nakefile default command"
output = execCmdEx(nakePathExe)
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("nakefile default worked")), output.output

echo "- Test nakefile non-default command"
output = execCmdEx(nakePathExe & " testcmd")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("nakefile testcmd worked")), output.output

echo "- Test nonexistant command"
output = execCmdEx(nakePathExe & " nonexistant")
doAssert output.exitCode == 1, output.output
doAssert output.output.match(getRe("Task 'nonexistant' not found")), output.output

echo "- Test failure lists commands"
output = execCmdEx(nakePathExe & " nonexistant")
doAssert output.exitCode == 1, output.output
doAssert output.output.match(getRe("default"))
doAssert output.output.match(getRe("list"))
doAssert output.output.match(getRe("testcmd"))

echo "- Test list commands from c-l"
output = execCmdEx(nakePathExe & " -t")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("default"))
doAssert output.output.match(getRe("list"))
doAssert output.output.match(getRe("test-careful"))
doAssert output.output.match(getRe("testcmd"))

echo "- Test list commands from 'list' command"
output = execCmdEx(nakePathExe & " list")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("default"))
doAssert output.output.match(getRe("list"))
doAssert output.output.match(getRe("test-careful"))
doAssert output.output.match(getRe("testcmd"))

echo "- Test commands listed in order given"
output = execCmdEx(nakePathExe & " -t")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("default", "testcmd", "test-careful", "list"))

echo "- Test -c (careful) option (yes)"
output = execCmdEx("echo 'y' | " & nakePathExe & " test-careful -c")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("nake rules"))

echo "- Test -c (careful) option (no)"
output = execCmdEx("echo 'n' | " & nakePathExe & " test-careful -c")
doAssert output.exitCode == 0, output.output
doAssert (not output.output.match(getRe("nake rules")))

# For future reference if this is added?
#echo "- Test multiple commands can be given"
#output = execCmdEx(nakePathExe & " default testcmd")
#doAssert output.exitCode == 0, output.output
#doAssert output.output.match(getRe("nakefile default worked", "nakefile testcmd worked")), output.output
