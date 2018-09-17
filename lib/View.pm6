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

use Text::Markdown;
use Template::Mustache;
use Storage;

=head1 View

=head2 view-page($id)

=begin pod

The page $id is read and used as the text item for the 'view.sp6'
template, which is rendered to HTML.

If the page $id does not exist, the special 'empty.sp6' template is
used.

=end pod

sub view-page (Str $id) is export {
    # FIXME: translation
    my %params =
    id => $id,
    pages => [ { id => 'Home' },
	       { id => 'About' } ];
    my $storage = Storage.new;
    my $template;
    my $page = $storage.get-page($id);
    if $page.exists {
	$template = $storage.get-template('view');
	%params<text> = parse-markdown($page.text).to-html;
    } else {
	$template = $storage.get-template('empty');
    }
    return Template::Mustache.render($template, %params);
}
