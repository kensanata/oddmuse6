# Things to do for Oddmuse 6

Open issues

- No rollback button for locked pages

Code Review:

- use colon notation, e.g. @results.push($change) → @results.push: $change
- use $dir.add: 'rc.log' instead of "$dir/rc.log" and the like

Debt:

- change all the calls from Storage.new to Storage.get which return a
  singleton

Here's what it still needs before it can deployed on the Intranet:

- a link to an administration page
- a way for administrators to lock the site for non-administrators
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
