================
Nake changes log
================

Changes for `nake <https://github.com/fowlmouth/nake>`_.

v1.3, ????-??-??
----------------

* Updates for Nimrod -> Nim transition
* Now uses an ordered table to store tasks
* Add the ability to change the default task-listing implementation

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
