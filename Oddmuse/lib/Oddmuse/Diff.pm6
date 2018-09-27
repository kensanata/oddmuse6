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

need Algorithm::Diff;
use HTML::Escape;
use Oddmuse::Storage;
use Oddmuse::Layout;

=head1 Diff
=begin pod
The functions exported all concern themselves with the the C<diff>
template. The context for this template contains the following keys:

=item C<id> is the page name

=item C<revision> is the 'to' revision, or the current revision

=item C<hunks> is a list of hunks

Each hunk is a hash with the following keys:

=item <insert> is set to 1 if this is an insertion

=item <delete> is set to 1 if this is a deletion

=item <text> is the text that was inserted or deleted

=item <change> is set to 1 if this is a replacement

=item <from> is the old text

=item <to> is the new text

The values of C<from> and C<to> contain the HTML tags C<ins> and
C<del> to highlight particular words that were changed. The C<text>,
C<from> and C<to> are otherwise plain text.
=end pod

=head2 view-diff (Str $id, Int $to --> Str)
=begin pod
Return the diff of the page give for a revision and it's predecessor.
=end pod

multi view-diff (Str $id, Int $to --> Str) is export {
    my $storage = Oddmuse::Storage.new;
    my $rev = $to || $storage.get-current-revision($id);
    return view-diff($id, $rev-1, $rev);
}

=head2 view-diff (Str $id, Int $from, Int $to --> Str)
=begin pod
Return the diff of two revisions of a page.
=end pod

multi view-diff (Str $id, Int $from, Int $to --> Str) is export {
    my $storage = Oddmuse::Storage.new;
    my $template = $storage.get-template('diff');

    # Get id and diff.
    my %context = :$id, :$from, :$to, hunks => diff($id, $from, $to);

    return render($template, %context);
}

=head2 diff (Str $id, Int $from, Int $to --> Array)
=begin pod
Retrieve the texts of the two revisions and return a diff, if
available. If the a revision cannot be retrieved, then the current
revision is used. The actual diff is computed using the diff variant
that just takes two strings as input. The result is a list of hashes
suitable for the C<diff> template.
=end pod

multi diff (Str $id, Int $from, Int $to --> Array) is export {
    my $storage = Oddmuse::Storage.new;
    my $old = $storage.get-keep-page($id, $from).text;
    my $new = $storage.get-keep-page($id, $to).text;
    return diff($old, $new);
}

=head2 diff (Str $old, Str $new --> Array)
=begin pod
Return diff between two strings. The result is a list of hashes
suitable for the C<diff> template.
=end pod

multi diff (Str $old, Str $new --> Array) is export {
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
            when 2 { @hunks.push({ insert => 1,
                                   text => $diff.Items(2).join("\n")}); }
            when 1 { @hunks.push({ delete => 1,
                                   text => $diff.Items(1).join("\n")}); }
        }
    }
    return @hunks;
}

sub refine (Str $a, Str $b) {
    my @from, my @to;
    my $diff = Algorithm::Diff.new($a.split(/ <|w> /), $b.split(/ <|w> /));
    while $diff.Next {
        if $diff.Same {
            @from.append($diff.Items(1));
            @to.append($diff.Items(2));
        } else {
            @from.push('<del>' ~ $diff.Items(1) ~ '</del>') if $diff.Items(1);
            @to.push('<ins>' ~ $diff.Items(2) ~ '</ins>') if $diff.Items(2);
        }
    }
    return @from.join(''), @to.join('');
}
