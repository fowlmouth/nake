version = "1.9.4"
author = "fowl"
description = "make-like for Nim. Describe your builds as tasks!"
license = "MIT"

installFiles = @[
    "LICENSE.rst",
    "README.rst",
    "nake.nim",
    "nakefile.nim",
    "nakelib.nim"
    ]

bin = @["nake"]

# Deps
requires "nim >= 0.10.2"
