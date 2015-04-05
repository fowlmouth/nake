import os
import re
{. push hints:off warnings:off .}
import osproc
{. pop .}

## Tests the basic operations that nake should perform

const
  testDir = "test_dir_basics"

var nimExe = findExe("nim")
if nimExe.len < 1:
  nimExe = findExe("nimrod")

proc cd(dir: string) = setCurrentDir(dir)
template withDir(dir: string; body: stmt): stmt =
  ## Changes the current directory temporarily.
  ##
  ## If you need a permanent change, use the `cd() <#cd>`_ proc. Usage example:
  ##
  ## .. code-block:: nimrod
  ##   withDir "foo":
  ##     # inside foo
  ##   #back to last dir
  var curDir = getCurrentDir()
  cd(dir)
  body
  cd(curDir)

{. push hints:off .}
proc getRe(phrases: varargs[string]): Regex =
  var s = ".*"
  for phrase in phrases:
    s.add(phrase)
    s.add(".*")

  return re(s, {reDotAll, reIgnoreCase})
{. pop .}

var output: tuple[output: TaintedString, exitCode: int]

echo "# test_binary.nim"
echo ""

echo "- Test nakefile binary default command"
withDir testDir:
  output = execCmdEx("nake")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("nakefile default worked"))

echo "- Test nakefile binary additional command"
withDir testDir:
  output = execCmdEx("nake testcmd")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("nakefile testcmd worked"))

echo "- Test -t option on binary"
withDir testDir:
  output = execCmdEx("nake -t")
doAssert output.exitCode == 0, output.output
doAssert output.output.match(getRe("default", "testcmd",  "list")), output.output
