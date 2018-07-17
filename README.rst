===========
Nake readme
===========

Describe your `Nim <http://nim-lang.org>`_ builds as tasks. Example
``nakefile.nim``:

.. code:: nim

    import nake

    const
      ExeName = "my_app"
      BleedingEdgeFeatures = "-d:testFeature1 -d:testFeature2"

    task "debug-build", "Build with unproven features":
      if shell(nimExe, "c", BleedingEdgeFeatures, "-d:debug", ExeName):
        ## zip up files or do something useful here?

    task "run-tests":
      # ...

Now you can run tasks from the ``nakefile.nim``:

.. code:: bash

    $ nake debug-build


License
=======

`MIT license <LICENSE.rst>`_.


Installation
============

Stable version
--------------

Use `Nim's Nimble package manager <https://github.com/nim-lang/nimble>`_ to
install the package and ``nake`` binary:

.. code:: bash

    $ nimble update
    $ nimble install nake

If a new version of ``nake`` is released, you can update to it by running
those commands again. You can figure out the version you have installed by
running ``nimble path nake``.


Development version
-------------------

Use `Nim's Nimble package manager <https://github.com/nim-lang/nimble>`_ to
install locally the GitHub checkout:

.. code:: bash

    $ git clone https://github.com/fowlmouth/nake
    $ cd nake
    $ nimble install

If you don't mind downloading the Git repository every time, you can also tell
`Nimble <https://github.com/nim-lang/nimble>`_ to install the latest
development version directly from Git:

.. code:: bash

    $ nimble update
    $ nimble install -y nake@#head


Usage
=====

Nake has its own nakefile, it will build nake as a binary. The ``nake`` binary
is just a shortcut for ``nim c -r nakefile $ARGS``:

.. code:: bash

    $ cd ~/.nimble/libs/nake
    $ nim c -r nakefile install
    ## boring ^
    $ cd ~/my-project
    $ nake debug-build
    ## wow look at the convenience (!!)

Once the nakefile is built, you can run it manually with ``./nakefile``, but you
can also run ``nake`` again. If nake detects that the source file is newer than
the binary, the nakefile will be rebuilt again, otherwise it just runs the
nakefile binary directly. Running ``nake`` in such case has an advantage of the
nakefile being looked up in parent directories recirsively. You can always
remove the ``nakefile`` and the ``nimcache`` directories if you need to force a
rebuild.

Most nakefiles will involve running some commands in a shell. To verify what
the shell invocations do you can pass the ``-c`` or ``--careful`` switch to a
``nake`` binary and then it will ask you to confirm each command being run:

.. code:: bash

    $ nake --careful install
    Run? `nim c nake` [N/y]

Note that this parameter only applies to nake's convenience `shell()
<http://fowlmouth.github.io/nake/gh_docs/master/nakelib.html#shell>`_ and
`direShell()
<http://fowlmouth.github.io/nake/gh_docs/master/nakelib.html#direShell>`_
procs, *malicious* nakefile authors will likely implement their own shell
spawning process.

If you run the nakefile without parameters or with the ``-t`` or ``--tasks``
switch it will report the available tasks.  But if you run a nakefile with a
specific task and this task doesn't exist, nake will report an error, list the
available tasks and exit with a non zero status.

In your nakefiles you can define the `defaultTask
<http://fowlmouth.github.io/nake/gh_docs/master/nakelib.html#defaultTask>`_
task.  This is a task which will be executed if the user runs ``nake`` without
specifying a task. Example:

.. code:: nim

    task defaultTask, "Compiles binary":
      if binaryRequiresRebuilding():
        doStuffToCompileProgram()
      else:
        echo "Binary is fresh, anything else?"
        listTasks()


Documentation
=============

The documentation of ``nake`` can be found online at
`http://fowlmouth.github.io/nake/ <http://fowlmouth.github.io/nake/>`_, but you
can run the **docs** task of the included `nakefile.nim <nakefile.nim>`_ to
generate the user API HTML documentation into a `nake.html file
<http://fowlmouth.github.io/nake/gh_docs/master/nake.html>`_.  This
documentation explains what symbols you can use other than the obvious `task()
template <http://fowlmouth.github.io/nake/gh_docs/master/nakelib.html#task>`_
to define tasks. If you installed using `Nimble
<https://github.com/nim-lang/nimble>`_, you first need to go to your local
`Nimble <https://github.com/nim-lang/nimble>`_ directory. UNIX example:

.. code:: bash

    $ cd `nimble path nake`
    $ nim c -r nake docs
    $ open nake.html

The **docs** task will also generate HTML versions of all local RST files,
which are indexed from the generated `theindex.html
<http://fowlmouth.github.io/nake/gh_docs/master/theindex.html>`_.


Changes
=======

The changes are listed on the
`releases page <https://github.com/fowlmouth/nake/releases>`_.
