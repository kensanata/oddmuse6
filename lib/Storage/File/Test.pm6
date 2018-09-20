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

=head1 Storage::File::Test
=begin pod
C<get-random-wiki-directory> creates a directory with a random name
and returns it. It also sets the C<wiki> environment variable such
that any subsequent code will use it.
=end pod

sub get-random-wiki-directory is export {
	my $dir;
	repeat {
		my $n = (1..^10000).rand.floor;
		$dir = sprintf("test-%4d", $n);
	} while ($dir.IO.e);
	say "Using $dir";
	%*ENV<wiki> = $dir;
	return mkdir $dir;
}
