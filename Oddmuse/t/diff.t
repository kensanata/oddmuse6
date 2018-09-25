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
use Oddmuse::Diff;
use Test;

my $a = q{The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
};

my $b = q{The Tao that can be told of is not the eternal Tao;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The Named is the mother of all things.
Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
But after they are produced,
  they have different names.
};

my $d = q{<div class="diff">
<div class="change">
<p><strong>Changed:</strong></p>
<p class="delete">
The <del>Way</del> that can be told of is not the eternal <del>Way;</del>
</p>
<p><strong>to:</strong></p>
<p class="insert">
The <ins>Tao</ins> that can be told of is not the eternal <ins>Tao;</ins>
</p>
</div>
<div class="insert">
<p><strong>Added:</strong></p>
<p class="insert"><ins>
The Named is the mother of all things.
</ins></p>
</div>
<div class="delete">
<p><strong>Deleted:</strong></p>
<p class="delete"><del>
The two are the same,
</del></p>
</div>
</div>
};

is diff($a, $b), $d, "diffing two strings";

# write test data
my $root = get-random-wiki-directory;
mkdir "$root/keep";
"$root/keep/page.md.~1~".IO.spurt($a);
"$root/keep/page.md.~2~".IO.spurt($b);

is diff("page", 1, 2), $d, "diffing two revisions";

done-testing;
