# Oddmuse 6

## Installation

This is Oddmuse based on Perl 6 and Cro instead of on Perl 5 and CGI
or Mojolicious.

To run it, you need to have Cro and some dependencies installed

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

## Translation

You should translate the Markdown files in the `pages` directory, and
you should translate the HTML files in the `templates` directory. The
templates use the [Mustache](https://mustache.github.io/) format.
