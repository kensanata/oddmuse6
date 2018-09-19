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

=head1 Storage
=begin pod
This module delegates all storage issues to a role as specified by the
environment variable C<storage>. By default, that would be
<Storage::File>.

The role must implement the following methods:

=defn get-page
Get a C<Page> given an id.
=defn keep-page
Save a backup of the page C<id>.
=defn put-page
Save a C<Page>.
=defn get-template
Get a the text for a template. The template should be HTML and must use
Template::Mustache markup.
=defn put-change
Save a C<Change>.
=defn get-changes
Get a list of C<Change> objects.
=end pod

class Storage {
    my $class = %*ENV<storage> || 'Storage::File';
    require ::($class);
    has $!delegate handles <
		get-page keep-page put-page get-template put-change get-changes
	> = ::($class).new;
}
