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

'rc.log'.IO.spurt(qq :to 'EOF');
2018-09-18T15:36:38.000000+02:000About11285one
2018-09-18T15:36:38.000000+02:001About2Alextwo
2018-09-18T15:36:39.000000+02:000About3Alexthree
EOF

test-service routes(), {

	for '/view/Changes', '/changes' {
		my $page = get($_);

		test $page,
			status => 200,
			content-type => 'text/html',
			body => / '<h1>' Changes '</h1>' .* one .* three /;

		test $page, body => !/ two /;
	}

	my $page = get('/changes?n=1');

    test $page,
		status => 200,
		content-type => 'text/html',
		body => / '<h1>' Changes '</h1>' .* one /;

    test $page, body => !/ two | three /;

}

done-testing;
