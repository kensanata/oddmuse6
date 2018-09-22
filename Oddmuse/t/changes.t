# Oddmuse is a wiki engine -*- perl6 -*-
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

"$root/rc.log".IO.spurt(qq :to 'EOF');
2018-09-18T15:36:38.000000+02:000About11285first
2018-09-18T15:36:38.000000+02:001About2Alexsecond
2018-09-18T15:36:39.000000+02:000About3Alexthird
2018-09-18T15:36:40.000000+02:001About4Alexfourth
2018-09-18T15:36:41.000000+02:000Help1Alexfifth
EOF

test-service routes(), {

    test-given '/view/Changes', {
        diag '/view/Changes is a synonym for /changes';
        test get(),
  	        status => 200,
	        content-type => 'text/html',
	        body => / '<h1>' Changes '</h1>' .* third .* fifth /;
        test get(), body => { $_ !~~ /« ( first | second | fourth ) »/ };
    }

    test-given '/changes', {
        diag 'default lists the last major change of every page';
        test get(),
  	            status => 200,
	            content-type => 'text/html',
	            body => / '<h1>' Changes '</h1>' .* third .* fifth /;
        test get(), body => { $_ !~~ /« ( first | second | fourth ) »/ };

        diag 'n=1 lists just the one last major change';
        test get('?n=1'),
            status => 200,
            content-type => 'text/html',
            body => / '<h1>' Changes '</h1>' .* fifth /;
        test get('?n=1'), body => { $_ !~~ /« ( first | second | third | fourth ) »/ };

        diag 'all=1 lists all the major changes';
        test get('?all=1'),
            status => 200,
            content-type => 'text/html',
            body => / '<h1>' Changes '</h1>' .* first .* third .* fifth /;
        test get('?all=1'), body => { $_ !~~ /« ( second | fourth ) »/ };

        diag 'all=1 & minor=1 lists all the changes';
        test get('?all=1&minor=1'),
            status => 200,
            content-type => 'text/html',
            body => / '<h1>' Changes '</h1>' .* first .* second .* third .* fourth .* fifth /;

        diag 'all=1 & minor=1 & author=Alex lists all the changes by Alex';
        test get('?all=1&minor=1&author=Alex'),
            status => 200,
            content-type => 'text/html',
            body => / '<h1>' Changes '</h1>' .* second .* third .* fourth .* fifth /;
        test get('?all=1&minor=1&author=Alex'), body => { $_ !~~ /« first »/ };
    }
}

done-testing;
