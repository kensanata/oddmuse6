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

# When running tests from this directory, get the static stuff from
# the parent directory.
export templates	?= ../templates
export css		?= ../css
export images		?= ../images

# How many jobs to run in parallel when testing
jobs ?= 4

test:
	prove6 -l -j=$(jobs) t

# use make t/view without the .t suffix
t/%:
	perl6 -Ilib $@.t
