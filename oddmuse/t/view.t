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
use Routes;

# testing the default Home page
%*ENV<wiki> = '../wiki';
%*ENV<menu> = 'Home, About';

test-service routes(), {
    test get('/'),
        status => 200,
        content-type => 'text/html',
        body => / '<a href="/view/Home">Home</a>'
	          .* '<a href="/view/About">About</a>'
	          .* '<h1>Home</h1>'
     		  .* 'Welcome!' /;

    test get('/view/Home'),
        status => 200,
        content-type => 'text/html',
        body => / '<h1>Home</h1>'
	          .* 'Welcome!' /;

    test get('/view/About'),
        status => 200,
        content-type => 'text/html',
        body => / 'This page is empty' /;
}

done-testing;
