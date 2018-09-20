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

use Test;
use Save;
use Storage::File::Test;

my $root = get-random-wiki-directory;
my $dir = "$root/keep".IO;

save-page(id => 'test', text => 'Original');

my @keep = $dir.dir(test => /^ 'test.md.~' \d+ '~' $/);
is(@keep.elems, 0, "no keep file written for first save");

save-page(id => 'test', text => 'Copy');

@keep = $dir.dir(test => /^ 'test.md.~' \d+ '~' $/);
is(@keep.elems, 1, "first keep file written for second save");

save-page(id => 'test', text => 'Another copy');

@keep = $dir.dir(test => /^ 'test.md.~' \d+ '~' $/);
is(@keep.elems, 2, "second keep file written for third save");

is("$dir/test.md.~1~".IO.slurp, "Original", "original saved");

is("$dir/test.md.~2~".IO.slurp, "Copy", "copy saved");

done-testing;
