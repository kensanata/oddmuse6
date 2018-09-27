# Things to do for Oddmuse 6

Debt:

- abstract the layout using a standard header and footer
- change all the calls from Storage.new to Storage.get which return a
  singleton

Missing features:

- unified layout
- merge in case of conflicts
- expiration of old page revisions
- admin passwords
- page passwords
- locking the site
- locking pages
- banning regular expressions
- question asking for first time posters
- rolling back changes
- RSS feed
- tags
- search
- comments
- image upload
- better HTML caching
- better HTTP caching (Etags, 304)

Missing big ideas:

- a plugin system
- markup rules which users can add, ideally by merging grammars (this
  enables us to have rules that protect text from further processing,
  such as code blocks; this requires the notion of rule precedence)
- a backend implementation using SQLite
