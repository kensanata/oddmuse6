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

=begin pod

=head1 Oddmuse::Change

Instances of this class act as a container for various attributes but
the class doesn't actually define any methods.

The actual representation of the change log is determined by
L<Oddmuse::Storage>. By default, it's the C<rc.log> file in the data
directory. The storage class creates the instances for this class.

Instances of this class are processed by L<Oddmuse::Changes>.

=end pod

 #| An instance of this class represents a line from the change log.
 class Oddmuse::Change {
    has DateTime $.ts;
    has Bool $.minor;
    has Str $.id;
    has Int $.revision;
    has Str $.author;
    has Str $.code;
    has Str $.summary;
    has Bool $.kept is rw;
}
