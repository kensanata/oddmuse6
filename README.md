# Oddmuse 6

## Installation

This is Oddmuse based on Perl 6 and Cro. The current stable version of
[Oddmuse](https://oddmuse.org/) is based on Perl 5 and `CGI.pm`,
optionally using `Mojolicious` and `Mojolicious::Plugin::CGI`. I
wanted to start a rewrite in order to get rid of the CGI module, and
then I asked myself: why not go all the way‽ I might as well give Perl
6 a try.

To run it, you need to have [Cro](https://cro.services/) and some
dependencies installed

```
zef install Text::Markdown
zef install Template::Mustache
zef install --/test cro
zef install --depsonly .
```

Once you do, just start the service defined in `service.p6`:

```
cro run
```

This should start the wiki on port 20000.

You can also build and run a docker image while in the app root using:

```
docker build -t edit .
docker run --rm -p 10000:10000 edit
```

## Test

The `Makefile` has a `test` target. Use the `jobs` environment
variable to control how many jobs run in parallel. The default is 4.

```
prove6 -l -j=1 t
```

## Configuration

If you look at the `.cro.yml` file you'll find a section with
environment variables with which to configure the wiki.

* `storage` is the class handling your storage requirements. The
  default is `Storage::File` which stores everything in plain text
  files.

* `wiki` is the location of your wiki, your data directory, if you are
  using `Storage::File`. The default is `wiki`.

* `menu` is a comma separated list of pages for the main menu. The
  default is `Home, Changes, About`. That also means that none of the
  pages in the menu may contain a comma.

* `changes` is the page which acts as an alias for the `/changes`
  route. The default is `Changes`. This means that you can add
  `Changes` to the main menu and it'll work. This also means that you
  cannot edit the `Changes` page: it's content is inaccessible.

These variables point to directories of the same name. More on these
below.

- `images`
- `css`
- `templates`
- `wiki`

### Images and CSS

Your website needs two directories for the static files:

* `images` is where `logo.png` is. This is used for the `favicon.ico`.
  Files from this directory are served as-is. You could use the logo
  image in your templates, for example.
   
* `css` is there `default.css` is. This is used by the default
  templates.

These directories can be shared between various instances of the wiki.

### Templates

This is where the templates are. The templates use the
[Mustache](https://mustache.github.io/) format. They cannot be changed
via the web interface.

### Wiki

This is where the dynamic content of your wiki is. If you use the
`Storage::File` back end, it contains the following:

* `page` is where the current pages are saved
* `keep` is where older revisions of pages are kept
* `rc.log` is the log file

## Translation

You should translate the Markdown files in the `data/pages` directory,
and you should translate the HTML files in the `data/templates`
directory. 
