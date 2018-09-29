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

=head1 Oddmuse::Storage::File::Lock

This module provides the function C<with-locked-file>. Provide it with
a path, the max time to wait in seconds, and a code block. Inside the
code block, the file is temporarily "locked". This obviously only
works if all code uses the same function to protect access.

When some other code attempts to do something with the same file, the
code will wait for up to the max time before overwriting the locked
file.

We can't use L<IO::Handle.lock> because this defaults to C<fcntl>
which means they are I<per process>.
=end pod

#| Execute code only if the path isn't locked. Remove the lock after
#| bit, however.
sub with-locked-file(Str $path, Int $max-delay, &code) is export {
    react {
		my $lock = "$path.lock";
        whenever Promise.in($max-delay) {
            $lock.IO.rmdir;
        }
		whenever Supply.interval(0.2) {
			if !$lock.IO.e {
				$lock.IO.mkdir;
				&code();
				$lock.IO.rmdir;
				done;
			}
		}
    }
}
