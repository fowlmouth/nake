nake
====

Describe your [Nimrod](http://nimrod-code.org) builds as tasks. Example
``nakefile.nim``:

```nimrod
import nake

const
  ExeName = "my_app"
  BleedingEdgeFeatures = "-d:testFeature1 -d:testFeature2"

task "debug-build", "Build with unproven features":
  if shell("nimrod c", BleedingEdgeFeatures, "-d:debug", ExeName):
    ## zip up files or do something useful here?

task "run-tests":
  # ...
```

Now you can compile this ``nakefile.nim`` file into a binary and run it:

```sh
nimrod c -r nakefile test-build
## or if you already compiled the nakefile
./nakefile test-build
```


License
=======

[DATWPL license](LICENSE.md).


Installation
============

Stable version
--------------

Use [Nimrod's babel package manager](https://github.com/nimrod-code/babel) to
install the package and ``nake`` binary:

```sh
$ babel update
$ babel install nake
```

Development version
-------------------

Use [Nimrod's babel package manager](https://github.com/nimrod-code/babel) to
install locally the github checkout:

```sh
$ git clone https://github.com/fowlmouth/nake
$ cd nake
$ babel install
```


Usage
=====

Nake has its own nakefile, it will build nake as a binary is just a shortcut
for `nimrod c -r nakefile $ARGS`
```sh
cd ~/.babel/libs/nake
nimrod c -r nakefile install
## boring ^
cd ~/my-project
nake debug-build
## wow look at the convenience (!!)
```

Once the nakefile is built you can run it manually with ``./nakefile``, but you
can also run ``nake`` again. If nake detects that the source file is newer than
the binary, the nakefile will be rebuilt again, otherwise it just runs the
nakefile binary directly. You can always remove the ``nakefile`` and the
``nimcache`` directories if you need to force a rebuild.


Documentation
=============

Run the `docs` task of the included [nakefile](nakefile.nim) to generate the
user API HTML documentation. This documentation explains what symbols you can
use other than the obvious `task` to define tasks. If you installed from babel
you first need to go to your babel directory. Unix example:

```sh
$ cd ~/.babel/pkgs/nake-x.y
$ nimrod c -r nake docs
$ open nake.html
```
