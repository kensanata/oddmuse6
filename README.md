# Oddmuse 6

This file is for the people wanting to download and install Oddmuse 6.

If you're a developer, see the [to do list](TODO.md).

If you're curious, see the [feature list](FEATURES.md).

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Installation](#installation)
    - [Bugs](#bugs)
- [Docker](#docker)
- [Test](#test)
- [Configuration](#configuration)
    - [Changes](#changes)
    - [Resources](#resources)
    - [Images and CSS](#images-and-css)
    - [Templates](#templates)
    - [Wiki](#wiki)
    - [Changing the CSS](#changing-the-css)
    - [Spam Protection](#spam-protection)
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

Get sources:

```
git clone https://alexschroeder.ch/cgit/oddmuse6
```

To run it, you need to install the dependencies:

```
cd oddmuse6
zef install --depsonly ./Oddmuse
```

Then start the service:

```
cro run
```

This should start the wiki on http://localhost:20000/ and its data is
saved in the `wiki` directory.

### Bugs

🔥 When installing dependencies using `zef` as shown, you could be
running into an OpenSSL issue even if you have the correct development
libraries installed. On Debian, you need `libssl-dev` but apparently
versions 1.1.0f and 1.1.0g won't work. See
[issue #34](https://github.com/jnthn/p6-io-socket-async-ssl/issues/34).

🔥 When I ran into the error `Type check failed in binding $high;
expected Any but got Mu` when computing a `diff` I found
[issue #12](https://github.com/Takadonet/Algorithm--Diff/issues/12) for
`Algorithm::Diff`.
[Pull request #16](https://github.com/Takadonet/Algorithm--Diff/pull/16)
is supposed to fix this. Feel free to check out
[my fork](https://github.com/kensanata/Algorithm--Diff) and install it
with `zef install --force-install .` – hopefully that fixes it for
you.

🔥 Every now and then I run into the error `This type (NQPMu) does not
support associative operations` while I'm working on the code. As it
turns out, `rm -rf Oddmuse/lib/.precomp` solves this issue. You'll be
doing this a lot until
[issue #2294](https://github.com/rakudo/rakudo/issues/2294) gets fixed.


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

* `ODDMUSE_STORAGE` is the class handling your storage requirements.
  The default is `Storage::File` which stores everything in plain text
  files.

* `ODDMUSE_WIKI` is the location of your wiki, your data directory, if
  you are using `Storage::File`. The default is `../wiki`. That's the
  top directory where this `README.md` is.

* `ODDMUSE_MENU` is a comma separated list of pages for the main menu.
  The default is `Home, Changes, About`. That also means that none of
  the pages in the menu may contain a comma.

### Changes

One page name is special: viewing this page lists recent changes on
the wiki instead of the page itself. By default, this page is called
"Changes". It's name is stored in an environment variable:

- `ODDMUSE_CHANGES` is the page which acts as an alias for the
  `/changes` route. The default is `Changes`.

This means that you can add `Changes` to the main menu and it'll work.
This also means that you cannot edit the `Changes` page: it's content
is inaccessible.

Don't forget to change the `changes.sp6` template if you change the
name of this page.

Here's an example of how to have a page called "RecentChanges":

1. Set the `ODDMUSE_MENU` environment variable to `Home,
   RecentChanges, About`. This makes sure that "RecentChanges" shows
   up in the menu.

2. Set the `ODDMUSE_CHANGES` environment variable to `RecentChanges`.
   This makes sure that clicking on the link is the equivalent of
   visiting `/changes`.

3. Edit the `changes.sp6` template and replace occurences of "Changes"
   with "RecentChanges" in the `title` element and the `h1` element
   such that there is no mismatch between the link and the title.

### Resources

The following variables point to directories used to server resources.
More on that below.

- `ODDMUSE_IMAGES`
- `ODDMUSE_CSS`
- `ODDMUSE_TEMPLATES`
- `ODDMUSE_WIKI`

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

* `ODDMUSE_IMAGES` is where `logo.png` is. This is used for the
  `favicon.ico`. Files from this directory are served as-is. You could
  use the logo image in your templates, for example.

* `ODDMUSE_CSS` is there `default.css` is. This is used by the default
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
ODDMUSE_HOST=localhost ODDMUSE_PORT=8000 perl6 -I Oddmuse/lib Oddmuse/service.p6
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

### Spam Protection

There is currently a very simple protection scheme in place, using
three pieces of information in three environment variables:

1. `ODDMUSE_QUESTION` is a question
2. `ODDMUSE_ANSWER` are possible answers, comma separated
3. `ODDMUSE_SECRET` is a secret which can be stored in a cookie, which
   basically means you should only use alphanumeric ASCII characters:
   no spaces, nothing fancy

This is how it works: whenever somebody tries to save a page, we check
if they have answered the question. If they do, they'll have a cookie
holding the secret. If they don't we redirect them to a page where
they must answer the question. If they answer correctly, the cookie
with the secret is set and the page is saved.

As the secret is stored in the cookie, people have to answer the
question whenever they delete their cookies, or whenever they change
browsers.

An example setup might use the following settings, for examples:

```sh
ODDMUSE_QUESTION=Name a colour of the rainbow.
ODDMUSE_ANSWER=red, orange, yellow, green, blue, indigo, violet
ODDMUSE_SECRET=rainbow-unicorn
```

## Hosting Multiple Wikis

Create two empty wiki data directories:

```
mkdir wiki1 wiki2
```

Start the first wiki:

```
ODDMUSE_HOST=localhost ODDMUSE_PORT=9000 ODDMUSE_WIKI=wiki1 perl6 -IOddmuse/lib Oddmuse/service.p6
```

Start the second wiki:

```
ODDMUSE_HOST=localhost ODDMUSE_PORT=9001 ODDMUSE_WIKI=wiki2 perl6 -IOddmuse/lib Oddmuse/service.p6
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
  - name: ODDMUSE_MENU
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
