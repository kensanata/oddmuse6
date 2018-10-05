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
use Oddmuse::Storage;
use Oddmuse::Filter;
use Oddmuse::Save;
use Test;

my $root = get-random-wiki-directory;

save-page(id => "About", text => "one");
save-page(id => "About", text => "two");
save-page(id => "About", text => "three");

my $storage = Oddmuse::Storage.new;

my $filter = Oddmuse::Filter.new(id => 'About', :all, :minor);
my @changes = $storage.get-changes($filter);
is @changes.elems, 3, "three changes in history";

# This is the change from revision 2 to the current page
is @changes[0].kept, False, "the latest change is not kept";

# This is the change from revision 1 to revision 2
is @changes[1].kept, True, "revision 2 is kept";

# This is the change from revision 0 to revision 1
is @changes[2].kept, True, "revision 1 is kept";

# There is no need to roll back to the current page, but there is always the
# option of rolling everything back, i.e. to revision 0: delete it all.

done-testing;
