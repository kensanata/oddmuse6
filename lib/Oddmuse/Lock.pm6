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

use Oddmuse::Password;
use Oddmuse::Storage;
use Oddmuse::View;

=begin pod

=head1 Oddmuse::Lock

=end pod

sub lock-with-pw(Str :$id!, Str :$pw = '') is export {
    with-pw($pw, { ask-for-pw($id, 'lock') }, { lock-page($id) });
}

sub lock-page(Str $id! --> Str) {
    my $storage = Oddmuse::Storage.new;
    $storage.lock-page($id);
    view-page($id, True); # we must be admins at this point
}

sub unlock-with-pw(Str :$id!, Str :$pw = '') is export {
    with-pw($pw, { ask-for-pw($id, 'unlock') }, { unlock-page($id) });
}

sub unlock-page(Str $id! --> Str) {
    my $storage = Oddmuse::Storage.new;
    $storage.unlock-page($id);
    view-page($id, True); # we must be admins at this point
}
