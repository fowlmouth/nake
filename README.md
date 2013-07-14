nake
====

Describe your Nimrod builds as tasks

Install with `babel install nake`

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
```sh
nimrod c -r nakefile test-build
## or if you already compiled the nakefile
./nakefile test-build
```

Nake has its own nakefile, it will build nake as a binary is just a shortcut for `nimrod c -r nakefile $ARGS`
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
