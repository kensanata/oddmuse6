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

use Template::Mustache;
need Algorithm::Diff;
use HTML::Escape;
use Oddmuse::Storage;

=head2 diff (Str $id, Int $from, Int $to --> Str) is export
=begin pod
This retrieves the texts of the two revisions and returns a diff, if
available. If the two revisions cannot be retrieved, then a warning is
returned. In either case, the return value is an HTML string. The
actual diff is computed using the diff variant that just takes two
strings as input.
=end pod
multi diff (Str $id, Int $from, Int $to --> Str) is export {
    my $storage = Oddmuse::Storage.new;
    my $old = $storage.get-keep-page($id, $from).text;
    my $new = $storage.get-keep-page($id, $to).text;
    return diff($old, $new);
}


=head2 diff (Str $old, $new --> Str) is export
=begin pod
This is the code that does the actual diff between two strings. The
return value is generated using the C<diff> template.
=end pod
multi diff (Str $old, $new) is export {
    my @hunks;
    my $diff = Algorithm::Diff.new(escape-html($old).lines,
                                   escape-html($new).lines);
    while $diff.Next {
        given $diff.Diff {
            when 3 {
                my ($from, $to) = refine($diff.Items(1).join("\n"),
                                         $diff.Items(2).join("\n"));
                @hunks.push({ change => 1, :$from, :$to});
            }
            when 2 { @hunks.push({ insert => 1, text => $diff.Items(2).join("\n")}); }
            when 1 { @hunks.push({ delete => 1, text => $diff.Items(1).join("\n")}); }
        }
    }
    my $storage = Oddmuse::Storage.new;
    my %context = :@hunks;
    my $template = $storage.get-template('diff');
    return Template::Mustache.render($template, %context);
}

sub refine (Str $a, Str $b) {
    my @from, my @to;
    my $diff = Algorithm::Diff.new($a.words, $b.words);
    while $diff.Next {
        if $diff.Same {
            @from.push($diff.Items(1));
            @to.push($diff.Items(2));
        } else {
            @from.push('<del>' ~ $diff.Items(1) ~ '</del>') if $diff.Items(1);
            @to.push('<ins>' ~ $diff.Items(2) ~ '</ins>') if $diff.Items(2);
        }
    }
    return @from.join(' '), @to.join(' ');
}
