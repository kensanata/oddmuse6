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
use Oddmuse::Storage;

=head1 Oddmuse::Layout

=begin pod

Function to render the given template with the given context. It also
adds the following key: C<pages>, an array of hashes, each hash with
just one key: C<id>. The value of this array is derived from the
environment variable C<pages>.

Given C<pages=Home, Changes, About> the value for the C<pages> key is:

    [{id => "Home"}, {id => "Changes"}, {id => "About"}]

It also adds the C<menu> partial. This uses the C<menu> template.

=end pod

#|{Render a template and context, adding some more stuff to the context.}
sub render(Str $template, %context --> Str) is export {

    my $storage = Oddmuse::Storage.new;

    # Get the pages for the main menu
    my $menu = %*ENV<menu> || "Home, Changes";
    my @pages = $menu.split(/ ',' \s* /);
    %context<pages> = [ map { id => $_ }, @pages ];
    my %partials = menu => $storage.get-template: 'menu';

    return Template::Mustache.render($template, %context, :from([%partials]));
}
