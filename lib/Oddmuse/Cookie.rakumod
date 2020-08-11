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

use Cro::HTTP::Router;
use Cro::HTTP::Cookie;
use URI::Encode;

=begin pod

=head1 Oddmuse::Cookie

C<save-to-cookie> is the convenience function used to store values in
a cookie. The name of the cookie and it's value are type checked
appropriately. If you get an error saying "expected CookieName" or
"expected CookieValue" and "got Str instead" then that's the compiler
telling you that the values you are passing don't satisfy the
constraints on cookies.

=end pod

#| Save a value to a cookie.
sub save-to-cookie(CookieName $key, Str $value --> Nil) is export {
    if $value {
        my $encoded-value = uri_encode_component($value);
        set-cookie $key, $encoded-value,
            expires => DateTime.now.later(years => 1);
    }
}
