# Oddmuse 6

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Installation](#installation)
- [Docker](#docker)
- [Test](#test)
- [Configuration](#configuration)
    - [Images and CSS](#images-and-css)
    - [Templates](#templates)
    - [Wiki](#wiki)
    - [Hosting Multiple Wikis](#hosting-multiple-wikis)
- [Translation](#translation)

<!-- markdown-toc end -->

## Installation

This is Oddmuse based on Perl 6 and Cro. The current stable version of
[Oddmuse](https://oddmuse.org/) is based on Perl 5 and `CGI.pm`,
optionally using `Mojolicious` and `Mojolicious::Plugin::CGI`. I
wanted to start a rewrite in order to get rid of the CGI module, and
then I asked myself: why not go all the way‽ I might as well give Perl
6 a try.

To run it, you need to install the dependencies:

```
zef install --depsonly ./oddmuse
```

Then start the service:

```
cro run
```

This should start the wiki on port 20000.

## Docker

I'm not sure how you would go about building the docker image. Any
help is appreciated.

```
docker build -t edit .
docker run --rm -p 10000:10000 edit
```

## Test

The `Makefile` has a `test` target. Use the `jobs` environment
variable to control how many jobs run in parallel. The default is 4.

```
jobs=1 make test
```

Running tests create test data directories (`test-nnnn`). To clean
these up:

```
make clean
```

To run just one suite of tests:

```
cd oddmuse
make t/keep
```

This also shows you the data directory it uses:

```
Using ../test-1288
```

## Configuration

If you look at the `oddmuse/.cro.yml` file you'll find a section with
environment variables with which to configure the wiki.

* `storage` is the class handling your storage requirements. The
  default is `Storage::File` which stores everything in plain text
  files.

* `wiki` is the location of your wiki, your data directory, if you are
  using `Storage::File`. The default is `../wiki`.

* `menu` is a comma separated list of pages for the main menu. The
  default is `Home, Changes, About`. That also means that none of the
  pages in the menu may contain a comma.

* `changes` is the page which acts as an alias for the `/changes`
  route. The default is `Changes`. This means that you can add
  `Changes` to the main menu and it'll work. This also means that you
  cannot edit the `Changes` page: it's content is inaccessible.

These variables point to directories of the same name in the parent
directory. More on these below.

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

### Hosting Multiple Wikis

Create two empty wiki data directories:

```
mkdir wiki1 wiki2
```

Start the first wiki:

```
ODDMUSE_HOST=localhost ODDMUSE_PORT=9000 wiki=wiki1 perl6 -Ioddmuse/lib oddmuse/service.p6
```

Start the second wiki:

```
ODDMUSE_HOST=localhost ODDMUSE_PORT=9001 wiki=wiki2 perl6 -Ioddmuse/lib oddmuse/service.p6
```

Now you can visit both `http://localhost:9000/` and
`http://localhost:9001/` and you'll find two independent wikis.

## Translation

You should translate the Markdown files in the `data/pages` directory,
and you should translate the HTML files in the `data/templates`
directory. 
