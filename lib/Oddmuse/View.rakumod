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

=head1 Oddmuse::View

These functions display pages to the user. If the page exists, its
content is rendered to HTML and the C<view> template is used to
display it. The context keys of interest are the following:

=item C<id> is the page name

=item C<html> is the rendered page content

=item C<revision> is the revision shown, if any

=item C<diff> is set if the revision is bigger than 1 (since that
allows us to generate a diff)

Note that a revision of 0 is the same as the current revision. Pages
and templates are retrieved via L<Oddmuse::Storage>.

If the page does not exist, the special C<empty> template is used. In
this case, only the C<id> key of the context is used.

The class used to render the wiki text to HTML is configurable using
the environment variable C<ODDMUSE_MARKUP>. By default, it's
C<Text::Markdown>. But you could also use C<Text::Markdown::Discount>.
The important part is the API C<$class.new($text).render>.

To test whether your class works, try this:

    export ODDMUSE_MARKUP=Text::Markdown::Discount
    make t/view.t

Make sure you change the C<resources/wiki/page/Home.md> file if your
class doesn't render Markdown. 🙂

=end pod

my $parser = BEGIN {
    my $class = %*ENV<ODDMUSE_MARKUP> || 'Text::Markdown';
    require ::($class);
    ::($class);
}

#| Show a page.
multi view-page(Str $id, Bool $is-admin) is export {
    view-page($id, 0, $is-admin);
}

#| Show a particular revision of a page.
multi view-page(Str $id, Int $n, Bool $is-admin) is export {

    my %context = :$id;

    # Get page data.
    my $storage = Oddmuse::Storage.new;
    my $page;
    if $n {
        $page = $storage.get-keep-page($id, $n);
    } else {
        $page = $storage.get-page($id, $is-admin);
    }

    # Get template and render page data.
    my $template;
    if $page {
        $template = $storage.get-template('view');
        %context<html> = $parser.new($page.text).render;
        %context<revision> = $page.revision;
        %context<locked> = $page.locked;
        %context<diff> = $n > 1;
    } else {
        $template = $storage.get-template('empty');
    }

    return render($template, %context);
}
