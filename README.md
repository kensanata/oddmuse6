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

The `Makefile` has a `test` target.

## Deployment

If you look at the `.cro.yml` file you'll find a section with
environment variables with which to configure the wiki.

`storage` is the class handling your storage requirements. The default
is `Storage::File` which stores everything in plain text files.

`dir` is the location of your wiki, your data directory, if you are
using `Storage::File`.

## Translation

You should translate the Markdown files in the `pages` directory, and
you should translate the HTML files in the `templates` directory. The
templates use the [Mustache](https://mustache.github.io/) format.
