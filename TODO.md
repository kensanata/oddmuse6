# Things to do for Oddmuse 6

Issues right now:

* Monit 5.20 (Debian stable) sends a HEAD request to check for web
 services and Oddmuse doesn't handle those. Time to get HTTP caching
 to work!

* "Your name" has to be a valid cookie value, i.e. it must only
 contain ASCII alpha numeric characters: no spaces. We should encode
 and decode the cookie value.

* No heading when crediting a page for the first time. Add this as a
  default to the text area.

* This wiki is behind a proxy and the environment variables aren't
  being juggled correctly so anonymous edits all end up with the same
  "code" -- the code for localhost.

* The codes should change with every request. We should salt the
  hashing used. In the old Oddmuse, the B hashing meant that the
  hashes would change with every process restart, which is great. We
  could salt the hashing with a timestamp, for example.

* Double HTML encoding when looking at the diff. Example: [diff between
  revisions 9 and 10](https://next.oddmuse.org/diff/Issues?to=10&from=9).

* Linking to local pages using [[double square brackets]] should work.
  Right now, only Markdown such as [Issues]﻿(/view/Issues) works. The
  Markdown parser used also doesn't seem to handle two sections in
  backticks correctly. I've had to break the markup for the Markdown
  link using a ZERO WITH NO-BREAKING SPACE for it to work. That sort
  of implies that going back to the old Oddmuse parser might not be
  such a bad idea.

* Actually we might simply need a new, Perl 6 grammar based, Common
  Mark implementation. We should steal the test setup from the Oddmuse
  common-mark branch. It uses the official JSON file with all the test
  definitions!

Code Review:

- use colon notation, e.g. @results.push($change) → @results.push: $change
- use $dir.add: 'rc.log' instead of "$dir/rc.log" and the like

Debt:

- change all the calls from Storage.new to Storage.get which return a
  singleton

Important stuff we need:

- a link to an administration page
- a way to list all the locked pages
- a protected page where administrators can put banned phrases.
- an error when people try to save pages containing banned phrases
- a way to list all the pages containing banned phrases

Here's what I'd like to see:

- preview button
- cancel button
- full text search
- page title match
- page tagging
- tag search
- tag cloud
- merge in case of conflicts

Interesting next steps:

- namespaces
- comments
- file uploads
- better HTML caching (measure it first?)
- better HTTP caching (Etags, 304)

Nice to have:

- a SQLite backend, once the storage API is stable
- an extension to provide an example of how this could be achieved
- expiration of old page revisions
- page passwords
- RSS feed
