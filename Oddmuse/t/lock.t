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

use Oddmuse::Storage::File::Lock;
use File::Temp;
use Test;

my ($path, $fh) = tempfile;

with-locked-file $path, 3, {
  $fh.say("Test");
};

is($path.IO.slurp, "Test\n", "write file");

# open it again
$fh = open $path, :w;

my $ts = DateTime.now.Instant;

ok("$path.lock".IO.mkdir, "lock created");

with-locked-file $path, 3, {
  $fh.say("Done");
};

is($path.IO.slurp, "Done\n", "overwrite locked file");

my $duration = DateTime.now.Instant - $ts;

is($duration.round(0.2), 3, "duration is correct");

done-testing;
