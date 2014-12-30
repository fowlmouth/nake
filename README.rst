===========
Nake readme
===========

Describe your `Nim <http://nim-lang.org>`_ builds as tasks. Example
``nakefile.nim``::

    import nake

    const
      ExeName = "my_app"
      BleedingEdgeFeatures = "-d:testFeature1 -d:testFeature2"

    task "debug-build", "Build with unproven features":
      if shell(nimExe, "c", BleedingEdgeFeatures, "-d:debug", ExeName):
        ## zip up files or do something useful here?

    task "run-tests":
      # ...

Now you can compile this ``nakefile.nim`` file into a binary and run it::

    $ nim c -r nakefile test-build
    ## or if you already compiled the nakefile
    $ ./nakefile test-build


License
=======

`DATWPL license <LICENSE.rst>`_.


Installation
============

Stable version
--------------

Use `Nim's Nimble package manager <https://github.com/nim-lang/nimble>`_ to
install the package and ``nake`` binary::

    $ nimble update
    $ nimble install nake


Development version
-------------------

Use `Nim's Nimble package manager <https://github.com/nim-lang/nimble>`_ to
install locally the github checkout::

    $ git clone https://github.com/fowlmouth/nake
    $ cd nake
    $ nimble install

If you don't mind downloading the git repository every time, you can also tell
Nimble to install the latest development version directly from git::

    $ nimble update
    $ nimble install -y nake@#head


Usage
=====

Nake has its own nakefile, it will build nake as a binary. The ``nake`` binary
is just a shortcut for ``nim c -r nakefile $ARGS``::

    $ cd ~/.nimble/libs/nake
    $ nim c -r nakefile install
    ## boring ^
    $ cd ~/my-project
    $ nake debug-build
    ## wow look at the convenience (!!)

Once the nakefile is built you can run it manually with ``./nakefile``, but you
can also run ``nake`` again. If nake detects that the source file is newer than
the binary, the nakefile will be rebuilt again, otherwise it just runs the
nakefile binary directly. You can always remove the ``nakefile`` and the
``nimcache`` directories if you need to force a rebuild.

Most nakefiles will involve running some commands in a shell. To verify what
the shell invocations do you can pass the ``-c`` or ``--careful`` switch to a
``nake`` binary and then it will ask you to confirm each command being run::

    $ nake --careful install
    Run? `nim c nake` [N/y]

Note that this parameter only applies to nake's convenience ``shell`` and
``direShell`` procs, a *malicious* nakefile author will likely implement his
own shell spawning process.

If you run the nakefile without parameters or with the ``-t`` or ``--tasks``
switch it will report the available tasks.  But if you run a nakefile with a
specific task and this task doesn't exist, nake will report an error, list the
available tasks and exit with a non zero status.

In your nakefiles you can define the ``defaultTask`` task. This is a task which
will be executed if the user runs ``nake`` without specifying a task. Example::

    task defaultTask, "Compiles binary":
      if binaryRequiresRebuilding():
        doStuffToCompileProgram()
      else:
        echo "Binary is fresh, anything else?"
        listTasks()


Documentation
=============

Run the **docs** task of the included `nakefile.nim <nakefile.nim>`_ to
generate the user API HTML documentation in the `nake.html file <nake.html>`_.
This documentation explains what symbols you can use other than the obvious
``task`` to define tasks. If you installed from nimble you first need to go to
your nimble directory. Unix example::

    $ cd `nimble path nake`
    $ nim c -r nake docs
    $ open nake.html

The **docs** task will also generate HTML versions of all local rst files,
which are indexed from `docindex.rst <docindex.rst>`_.


Changes
=======

This is development version 1.3. Read the changes log in the `changes.rst file
<changes.rst>`_.
