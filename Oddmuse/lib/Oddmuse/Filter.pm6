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

class Oddmuse::Filter is rw {
    has Int $.n;      # limit to the last n items
    has Str $.name;   # limit to a specific page name
    has Str $.author; # limit to a specific author
    has Bool $.minor; # include minor changes
    has Bool $.all;   # just the last one

    method from-hash(%params!) {
        if %params<n> and %params<n> ~~ /^\d+$/ {
            $!n = Int(%params<n>);
        } else {
            $!n = 30;
        }
        $!minor = so %params<minor>;
        $!all = so %params<all>;
        $!name = %params<name> || '';
        $!author = %params<author> || '';
        return self;
    }
}

# If you add more filter attributes, be sure to change the following:
#
# 1. in Changes.pm6, in view-changes, make sure you convert the value
#    from %params into a Filter attribute
#
# 2. in the same file, at the end, make sure you add it back to the
#    %filter hash
#
# 3. in changes.sp6, add it to the #filter section
#
# 4. in the same file, add it to the form
