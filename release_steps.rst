==================
Nake release steps
==================

These are the steps to be performed for new stable releases of `nake
<https://github.com/fowlmouth/nake>`_. See the `README <README.rst>`_.

* Create new milestone with version number (``vXXX``) at
  https://github.com/fowlmouth/nake/milestones.
* Create new dummy issue `Release versionname` and assign to that milestone.
* ``git flow release start versionname`` (``versionname`` without ``v``).
* Run ``nake test`` to verify the test suite still works.
* Update version numbers:

  * Modify `README.rst <README.rst>`_ (s/development/stable/).
  * Modify `changes.rst <changes.rst>`_ with list of changes and
    version/number.
  * Modify `nake.nimble <nake.nimble>`_ with version and list of new files to
    install.

* ``git commit -av`` into the release branch the version number changes.
* ``git flow release finish versionname`` (the ``tagname`` is ``versionname``
  without ``v``).  When specifying the tag message, copy and paste a text
  version of the full changes log into the message. Add text ``*`` item
  markers.
* Move closed issues not assigned to any milestone to this release milestone.
* Move closed pull requests not assigned to any milestone to this release
  milestone.
* Increase version numbers, ``master`` branch gets +0.1.

  * Modify `README.rst <README.rst>`_.
  * Add to `changes.rst <changes.rst>`_ development version with unknown
    date.
  * Modify `nake.nimble <nake.nimble>`_ with development version.

* ``git commit -av`` into ``master`` with `Bumps version numbers for
  development version`.

* Regenerate static website. This requires having installed
  `gh_nimrod_doc_pages <https://github.com/gradha/gh_nimrod_doc_pages>`_ (you
  can do so through `Nimble <https://github.com/nim-lang/nimble>`_):

  * Make sure git doesn't show changes, then run ``nake web`` and review.
  * ``git add . && git commit``. Tag with
    `Regenerates website. Refs #release_issue`.
  * ``./nakefile postweb`` to return to the previous branch. This also updates
    submodules, so it is easier.

* ``git push origin master stable gh-pages --tags``.
* Close the dummy release issue.
* Close the milestone on github.
* Announce at http://forum.nim-lang.org/t/67.
