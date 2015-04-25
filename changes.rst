================
Nake changes log
================

Changes for `nake <https://github.com/fowlmouth/nake>`_.

v1.5, ????-??-??
----------------

* `Silences compilation warnings <https://github.com/fowlmouth/nake/pull/22>`_.
  This change requires Nim 0.10.2 or better.
* `Fixed broken documentation links, added website with generated docs
  <https://github.com/fowlmouth/nake/issues/27>`_.
* `Added test suite <https://github.com/fowlmouth/nake/pull/26>`_.
* `Moved nake procs and macros to nakelib module which can be imported without
  turning the importer into a nakefile
  <https://github.com/fowlmouth/nake/issues/19>`_.
* `Removed prefix letter from types
  <https://github.com/fowlmouth/nake/issues/29>`_.
* `Reduced nake verbosity, added silent shell procs
  <https://github.com/fowlmouth/nake/issues/20>`_.
* `Adds nake's timestamp to nakefile rebuild dependency list
  <https://github.com/fowlmouth/nake/issues/23>`_.
* `DATWPL license was changed to MIT
  <https://github.com/fowlmouth/nake/pull/37>`_.

v1.4, 2014-12-30
----------------

* `Updated for Nimrod -> Nim transition
  <https://github.com/fowlmouth/nake/pull/10>`_.
* `Now uses an ordered table to store tasks
  <https://github.com/fowlmouth/nake/commit/8748926dbfb51740ad09d06d3bc14856185c7a80>`_.
* `Added the ability to change the default task-listing implementation
  <https://github.com/fowlmouth/nake/commit/0110a989f52bee05c716734fd5e6818522ac8a98>`_.
* `Updated to use nimble instead of babel
  <https://github.com/fowlmouth/nake/issues/13>`_.
* `Improved documentation <https://github.com/fowlmouth/nake/issues/15>`_.

v1.2, 2014-02-22
----------------

* Nake now reports an error to the OS for unknown tasks.
* Added some documentation, changed to rst format for local generation.
* Added ``defaultTask`` to run when no options are specified.
* Added convenience ``needsRefresh`` proc to do work only when timestamps
  change.

v1.1, 2013-11-09
----------------

* Added some documentation.
* Avoided recompilation of nakefile based on timestamps.
* Added binary for babel installations.
* Corrected license, see `LICENSE.rst <LICENSE.rst>`_.

v1.0, 2013-06-30
----------------

* Availability on babel.
* Added *careful* mode with ``-c`` toggle.
