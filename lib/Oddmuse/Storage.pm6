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

use Oddmuse::Storage::Delegate;

=begin pod

=head1 Oddmuse::Storage

This module delegates most storage issues to a role as specified by
the environment variable C<storage>. By default, that would be
C<Oddmuse::Storage::File>.

The role must implement the following methods:

=defn get-page
Get a L<Oddmuse::Page> given an id.

=defn put-page
Save a L<Oddmuse::Page>.

=defn get-keep-page
Save a L<Oddmuse::Page> given an id and a revision number.
saved (an integer).

=defn put-keep-page
Save a backup of the page C<id>. Return the latest revision thus
saved (an integer).

=defn put-keep-page
Save a backup of the page C<id>. Return the latest revision thus
saved (an integer).

=defn put-change
Save a L<Oddmuse::Change>.

=defn get-changes
Get a list of L<Oddmuse::Change> objects.

=defn lock-page
Locks page C<id>.

=defn unlock-page
Unlocks page C<id>.

=defn is-locked
Return true if page C<id> is locked.

The following methods are implemented by L<Oddmuse::Storage> itself:

=defn get-template
Get a the text for a template. The template should be HTML and must
use L<Template::Mustache> markup. Templates are files in the
C<templates> subdirectory with the <sp6> extension.

=end pod

#| The front end which use a backend to delegate many function calls.
class Oddmuse::Storage {
    my $class = %*ENV<ODDMUSE_STORAGE> || 'Oddmuse::Storage::File';
    require ::($class);
    has Oddmuse::Storage::Delegate $!delegate handles <
        get-page put-page get-keep-page put-keep-page
        put-change get-changes get-current-revision
        lock-page unlock-page is-locked
        > = ::($class).new;

    #| Get a the text for a template.
    method get-template(Str $id!) is export {
        my $dir =  %*ENV<ODDMUSE_TEMPLATES> || 'templates';
        my $path = "$dir/$id.sp6";
        $path = %?RESOURCES{"templates/$id.sp6"} unless $path.IO.e;
        return $path.IO.slurp;
    }
}
