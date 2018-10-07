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

use Oddmuse::Storage;
use Oddmuse::Layout;

=begin pod

=head1 Oddmuse::Edit

The function used for the edit page, i.e. the user interface people
see before they save their edits. The C<edit> template has the
following keys you need to set in the context:

=item C<id> is the page name

=item C<text> is the raw text

=end pod

#| Shows the edit form for a given page.
sub edit-page(Str:D $id, Str:D $author --> Str) is export {
    my %context = :$id, :$author;
    my $storage = Oddmuse::Storage.new;
    my $template = $storage.get-template('edit');
    my $page = $storage.get-page($id);
    %context<text> = $page.text if $page.exists;
    return render($template, %context);
}
