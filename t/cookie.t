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
use URI::Encode;
use Test;

my $root = get-random-wiki-directory;

my $author = 'Alex Schröder';
my $cookie;

my $encoded-author = uri_encode_component($author);
test-service routes(), {
    test post('/save',
	          json => { :id('About'), :text('Hallo'), :summary('testing'), :author($author), }),
        status => 200,
        content-type => 'text/html',
        body => / 'Hallo' /,
        headers => {
            # Make a copy of the cookie.
            Set-Cookie => { $cookie = $_; $_ ~~ / $encoded-author / },
        };

    test get('/edit/About', cookies => { author => $encoded-author }),
        status => 200,
        content-type => 'text/html',
        body => / $author /;

}

done-testing;
