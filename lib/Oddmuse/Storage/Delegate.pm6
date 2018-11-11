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

use Oddmuse::Page;
use Oddmuse::Change;
use Oddmuse::Filter;

=begin pod

=head1 Oddmuse::Storage::Delegate

Any module implementing the L<Oddmuse::Storage> layer must "do" this
role.

=end pod

#| Storage layer role
role Oddmuse::Storage::Delegate {

    #| Return a new Page.
    multi method get-page(Str $id!, Bool $is-admin --> Oddmuse::Page) is export { ... }

    #| Return a new Page, assume no admin permissions
    multi method get-page(Str $id! --> Oddmuse::Page) { ... }

    #| Save a Page.
    method put-page(Oddmuse::Page $page! --> Nil) is export { ... }

    #| Get an old revision, or the current page if it doesn't exist.
    method get-keep-page(Str $id!, Int $n! --> Oddmuse::Page) is export { ... }

    #| Save new revision of a page and return the revision number.
    method put-keep-page(Str $id! --> Int) is export { ... }

    #| Add a Change to the log.
    method put-change(Oddmuse::Change $change! --> Nil) is export { ... }

    #| Get the changes matching a filter from the log file.
    method get-changes(Oddmuse::Filter $filter! --> List) is export { ... }

    #| Get the current revision for a page.
    method get-current-revision(Str $id! --> Int) is export { ... }

    #| Lock a page.
    method lock-page(Str $id! --> Nil) is export { ... }

    #| Unlock a page.
    method unlock-page(Str $id! --> Nil) is export { ... }

    #| Is this page locked?
    method is-locked(Str $id! --> Bool) is export { ... }
}
