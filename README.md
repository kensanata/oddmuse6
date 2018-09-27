# Oddmuse 6

This file is for the people wanting to download and install Oddmuse 6.

If you're a developer, see the [to do list](TODO.md).

If you're curious, see the [feature list](FEATURES.md).

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Installation](#installation)
- [Docker](#docker)
- [Test](#test)
- [Configuration](#configuration)
    - [Images and CSS](#images-and-css)
    - [Templates](#templates)
    - [Wiki](#wiki)
    - [Changing the CSS](#changing-the-css)
- [Hosting Multiple Wikis](#hosting-multiple-wikis)
- [Using it as a module](#using-it-as-a-module)

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

This should start the wiki on http://localhost:20000/ and its data is
saved in the `wiki` directory.

### Bugs

When I ran into the error `Type check failed in binding $high;
expected Any but got Mu` when computing a `diff` I found [issue
#12](https://github.com/Takadonet/Algorithm--Diff/issues/12) for
`Algorithm::Diff`. [Pull request
#16](https://github.com/Takadonet/Algorithm--Diff/pull/16) is supposed
to fix this. Feel free to check out [my
fork](https://github.com/kensanata/Algorithm--Diff) and install it
with `zef install --force-install .` – hopefully that fixes it for
you.

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
  using `Storage::File`. The default is `../wiki`. That's the top
  directory where this `README.md` is.

* `menu` is a comma separated list of pages for the main menu. The
  default is `Home, Changes, About`. That also means that none of the
  pages in the menu may contain a comma.

* `changes` is the page which acts as an alias for the `/changes`
  route. The default is `Changes`. This means that you can add
  `Changes` to the main menu and it'll work. This also means that you
  cannot edit the `Changes` page: it's content is inaccessible.

These variables point to directories used to server resources. More on
that below.

- `images`
- `css`
- `templates`
- `wiki`

For images, css files and templates, this is how lookup works:

1. If an environment variable with the correct name exists, it's value
   is used as the directory. Since the `Oddmuse/.cro.yml` file does
   that, you can simply run `cro run` and it should find all the
   files.

2. If no environment variable exists, the current working dir is
   checked for directories with the right names. If they exist, they
   are used.

3. If none of the above, the copies in the `resources` folder of the
   module itself are used.

As for the wiki directory: it is created if it doesn't exist. At that
point the `Home.md` page from the module's `resources` folder is
copied so that your wiki comes with at least one page.

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

### Changing the CSS

Here's a simple change to make:

```
mkdir css
cp Oddmuse/resources/css/default.css css/
cat - << EOF >> css/default.css
body {
  background: black;
  color: green;
}
EOF
ODDMUSE_HOST=localhost ODDMUSE_PORT=8000 -I Oddmuse/lib Oddmuse/service.p6
```

This works because now we're not using `cro` to launch the process and
thus `Oddmuse/.cro.yml` isn't being used and thus the environment
defined in that file isn't being used. That's why we had to provide
our own host and port, and that's why the modified `default.css` from
the local `css` directory is being used.

Taking it from here should be easy: the `templates` directory and the
`images` directory work just the same.

If you want these changes to take effect and you still want to `cro
run`, you need to make changes to the `.cro.yml` file.

## Hosting Multiple Wikis

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

## Using it as a module

Here's what you can do if you installed `Oddmuse::Routes` as a module
and now you want to write your own [Cro](https://cro.services/)
application.

Start with a stub and accept all the defaults:

```
cro stub http test test
```

This creates a service called "test" in a directory called `test`. If
you accept all the defaults, you'll get a service doing HTTP 1.1. Good
enough for us!

Now edit `test/services.p6` and replace `use Routes` with `use
Oddmuse::Routes`.

You can delete the `test/lib/Routes.pm6` which `cro stub` generated
for you.

Run it:

```
cro run
```

Check it out by visiting `http://localhost:20000`. Your wiki directory
is `test/wiki`.

Replace the empty environment section in `test/.cro.yml` with the
following:

```
env:
  - name: menu
    value: Home, Changes, About
```

And now you have a link to the *About* page. Follow the link and click
the *create it* link. Write the following into the text area and click
the *Save* button:

```
# About

This is my page.
```

Your first edit! 🎉
