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
Running nake in such a way is maybe slower than running the ``./nakefile``
directly since nake will call the nimrod compiler for each run to recompile the
nakefile. If you are using bash you can add this function definition to your
initialization files to avoid the recompile based on file timestamps:

```sh
function nake {
	# Make NAKEBIN a full path to avoid recursion from the shell.
	NAKEBIN=~/bin/nake
	if [[ nakefile.nim -nt nakefile ]]; then
		"${NAKEBIN}" "$@"
	else
		./nakefile "$@"
	fi
}
```
