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

use Cro::HTTP::Test;
use Test;
use Routes;

if ('page/About.md'.IO.e) {
  'page/About.md'.IO.unlink;
}

if ('rc.log'.IO.e) {
  'rc.log'.IO.unlink;
}

test-service routes(), {
    test get('/edit/About'),
        status => 200,
        content-type => 'text/html',
        body => / 'Editing About' /,
	body => / 'form method="post"' /;

    test-given '/save', {
      test post(json => { :id('About'), :text('Hallo'), :summary('testing'),
			  :author(''), }),
	  status => 200,
	  content-type => 'text/html',
	  body => / 'Hallo' /;
    }
}

ok 'page/About.md'.IO.e, 'page name correct';
is 'page/About.md'.IO.slurp, 'Hallo', 'page content saved';

ok 'rc.log'.IO.e, 'changes correct';
my @data = 'rc.log'.IO.slurp.split(/\x1e/);
like @data[0], / \d\d\d\d '-' \d\d '-' \d\d /, "year";
like @data[0], / \d\d : \d\d : \d\d /, "time";
is @data[1], 0, "major change";
is @data[2], "About", "page name";
# author is empty
like @data[4], / \d\d\d\d /, "code";
like @data[5], /testing/, "summary";

# make sure checkbox is handled correctly
test-service routes(), {
    test-given '/save', {
      test post(json => { :id('About'), :text('Hullo'), :summary('typo'),
			  :author('Alex'), :minor('on'), }),
	  status => 200,
	  content-type => 'text/html',
	  body => / 'Hullo' /;
    }
}

@data = 'rc.log'.IO.slurp.split(/\n/)[1].split(/\x1e/);
like @data[0], / \d\d\d\d '-' \d\d '-' \d\d /, "year";
like @data[0], / \d\d : \d\d : \d\d /, "time";
is @data[1], 1, "minor change";
is @data[2], "About", "page name";
like @data[3], /Alex/, "author";
# code is empty
like @data[5], /typo/, "summary";

done-testing;
