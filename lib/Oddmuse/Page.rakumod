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

=head1 Oddmuse::Page

Instances of this class act as a container for various attributes but
the class doesn't actually define any methods.

Instances of this class are processed by L<Oddmuse::Save>.

=end pod

#| An instance of this class represents a wiki page.
class Oddmuse::Page {
    has Str $.id;
    has Str $.text;
    has Bool $.locked;
    has Int $.revision;
}
