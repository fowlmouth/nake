====================================
What to do for a new public release?
====================================

* ``git flow release start versionname`` (versionname without v).
* Update version numbers:

  * Modify `README.rst <../README.rst>`_ (s/development/stable/).
  * Modify `changes.rst <changes.rst>`_ with list of changes and
    version/number.
  * Modify `nake.nimble <nake.nimble>`_ with version and list of new files to
    install.

* ``git commit -av`` into the release branch the version number changes.
* ``git flow release finish versionname`` (the tagname is versionname without
  ``v``).  When specifying the tag message, copy and paste a text version of
  the full changes log into the message. Add rst item markers.
* Push all to git: ``git push origin master stable --tags``.
* Increase version numbers, ``master`` branch gets +1.

  * Modify `README.rst <../README.rst>`_.
  * Add to `changes.rst <changes.rst>`_ development version with unknown
    date.
  * Modify `nake.nimble <nake.nimble>`_ with development version.

* ``git commit -av`` into ``master`` with *Bumps version numbers for
  development version*.
* ``git push origin master``.

* Announce at http://forum.nimrod-lang.org/t/67.
