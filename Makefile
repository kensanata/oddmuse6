# Oddmuse is a wiki engine
# Copyright (C) 2018  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
# for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

VERSION=$(shell perl6 -M JSON::Fast -e 'from-json("META6.json".IO.slurp)<version>.say')

# How many jobs to run in parallel when testing
jobs ?= 4

test: clean
	prove6 -l -j=$(jobs) t

clean:
	rm -rf test-* lib/.precomp

dist:
	git archive --prefix=Oddmuse-$(VERSION)/ -o Oddmuse-$(VERSION).tar.gz $(VERSION)

upload:
	cpan-upload Oddmuse-$(VERSION).tar.gz

without-cro:
	ODDMUSE_HOST=localhost ODDMUSE_PORT=20000 ODDMUSE_PASSWORD=mu perl6 -Ilib service.p6

.PHONY: unit-test
t/%.t: unit-test
	perl6 -Ilib $@
