# Oddmuse 6 Features

Oddmuse is a simple wiki, based on Markdown and Mustache templates.
What does that mean?

These are the features it supports:

- pages are stored as plain text files
- when viewing pages, the text is rendered as Markdown
- old revisions are also stored as plain text files
- the change log is also a text file
- every page can be edited; click the *Edit* link at the bottom
- page edits are protected from bots by a question defined via an
  environment variable; multiple correct answers are also defined via
  an environment variable; when people edit a page for the first time,
  they have to answer this question correctly before their edit is
  accepted
- there's a page history available for review; click the *History*
  link at the bottom
- there's a wiki history available for review; click the *Changes*
  link at the top
- from the *Changes* page you can get the page *History*
- from both the *Changes* page and the *History* pages you can see
  *diffs*
- by default, a *diff* shows you the changes made from the previous
  revision
- from the *History* pages, you can compare arbitrary revisions
- the *Changes* page and the *History* pages provide for filtering of
  the changes shown
- by default, *minor* changes are not shown
- when editing a page, you can click a checkbox to set this flag in
  order to reduce the "noise" on the Changes page
- if you're interested in reviewing all the changes made, you should
  definitely use the *all* checkbox to include minor changes
- from the *History* pages, you can rollback to older revisions of a
  page, if and only if the old revision has been "kept", i.e. the
  "keep" file still exists
