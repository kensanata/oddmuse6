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

use Oddmuse::Storage::File::Test;
use Oddmuse::Routes;
use Cro::HTTP::Test;
use Test;

my $root = get-random-wiki-directory;

%*ENV<ODDMUSE_QUESTION> = 'Name a colour of the rainbow.';
%*ENV<ODDMUSE_ANSWER> = 'red, orange, yellow, green, blue, indigo, violet';
%*ENV<ODDMUSE_SECRET> = 'rainbow-unicorn';

test-service routes(), {
  test get('/edit/About'),
      status => 200,
      content-type => 'text/html',
      body => / '<h1>Edit About</h1>' .* 'form method="post"' .* '# About' /;

  test post('/save',
	    json => { :id('About'), :text('# Hallo'), :summary('testing'), :author(''), }),
      status => 200,
      content-type => 'text/html',
      body => / 'First time editor' .* "%*ENV<ODDMUSE_QUESTION>" /;

  test post('/save',
	    json => { :id('About'), :text('# Morning'), :summary('testing'), :author(''), :answer('red'), }),
      status => 200,
      content-type => 'text/html',
      body => / '<h1>Morning</h1>' /;

  test post('/save', cookies => { secret => %*ENV<ODDMUSE_SECRET>, },
	    json => { :id('About'), :text('# Hallo'), :summary('testing'), :author(''), }),
      status => 200,
      content-type => 'text/html',
      body => / '<h1>Hallo</h1>' /;
}

ok "$root/page/About.md".IO.e, 'page name correct';
is "$root/page/About.md".IO.slurp, '# Hallo', 'page content saved';

ok "$root/rc.log".IO.e, 'changes correct';
my @data = "$root/rc.log".IO.slurp.split(/\x1e/);
like @data[0], / \d\d\d\d '-' \d\d '-' \d\d /, "year";
like @data[0], / \d\d : \d\d : \d\d /, "time";
is @data[1], 0, "major change";
is @data[2], "About", "page name";
is @data[3], "0", "revision";
# author is empty
like @data[5], / \d\d\d\d /, "code";
like @data[6], /testing/, "summary";

# make sure checkbox is handled correctly
test-service routes(), {
  test post('/save', cookies => { secret => %*ENV<ODDMUSE_SECRET>, },
	    json => { :id('About'), :text('Hullo'), :summary('typo'), :author('Alex'), :minor('on')}),
      status => 200,
      content-type => 'text/html',
      body => / '<p>Hullo</p>' /;
}

# last log file entry
@data = "$root/rc.log".IO.slurp.split(/\n/)[2].split(/\x1e/);
like @data[0], / \d\d\d\d '-' \d\d '-' \d\d /, "year";
like @data[0], / \d\d : \d\d : \d\d /, "time";
is @data[1], 1, "minor change";
is @data[2], "About", "page name";
is @data[3], "2", "revision";
like @data[4], /Alex/, "author";
# code is empty
like @data[6], /typo/, "summary";

done-testing;
