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

This module delegates most storage issues to a role as specified by
the environment variable C<storage>. By default, that would be
C<Oddmuse::Storage::File>.

The role must implement the following methods:

=defn get-page
Get a C<Page> given an id.

=defn put-page
Save a C<Page>.

=defn get-keep-page
Save a C<Page> given an id and a revision number.
saved (an integer).

=defn put-keep-page
Save a backup of the page C<id>. Return the latest revision thus
saved (an integer).

=defn put-keep-page
Save a backup of the page C<id>. Return the latest revision thus
saved (an integer).

=defn put-change
Save a C<Change>.

=defn get-changes
Get a list of C<Change> objects.

The following methods are implemented by C<Storage> itself:

=defn get-template
Get a the text for a template. The template should be HTML and must use
C<Template::Mustache> markup.

=end pod

class Oddmuse::Storage {
    my $class = %*ENV<storage> || 'Oddmuse::Storage::File';
    require ::($class);
    has $!delegate handles <
		get-page put-page get-keep-page put-keep-page
		put-change get-changes
		> = ::($class).new;

	=head4 get-template
	=begin pod
	Pages are files in the C<templates> subdirectory with the <sp6> extension.
	=end pod

	method get-template (Str $id!) is export {
		my $dir =  %*ENV<templates> || 'templates';
		my $path = "$dir/$id.sp6";
        if !$path.IO.e {
            $path = %?RESOURCES{"templates/$id.sp6"};
        }
		my $fh = open $path, :enc('UTF-8');
		return $fh.slurp;
	}
}
