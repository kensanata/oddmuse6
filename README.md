# Oddmuse 6

This is Oddmuse based on Perl 5 and Cro instead of on Perl 5 and CGI
or Mojolicious.

To run it, you need to have Cro installed:

```
zef install --/test cro
zef install --depsonly .
cro run
```

This should start the wiki on port 20000.

You can also build and run a docker image while in the app root using:

```
docker build -t edit .
docker run --rm -p 10000:10000 edit
```
