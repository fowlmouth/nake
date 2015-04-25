[Package]
name = "nake"
version = "1.5"
author = "fowl"
description = "make-like for Nim. Describe your builds as tasks!"
license = "MIT"
InstallFiles = """

LICENSE.rst
README.rst
changes.rst
nake.nim
nakefile.nim
nakelib.nim
release_steps.rst

"""
bin = "nake"

[Deps]
Requires: """

nim >= 0.10.2

"""
