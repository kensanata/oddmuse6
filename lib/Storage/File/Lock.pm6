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

=head1 Storage::File::Lock
=begin pod
This module provides the function C<with-locked-file-handle>. Provide
it with an opened file handle, the max time to wait in seconds, and a
code block. Inside the code block, the file handle is "locked".

When some other code attempts to do something with the same file, the
code will wait for up to the max time before overwriting the locked
file. It will check the lock once a second.
=end pod

sub with-locked-file(Str $path, Int $max-delay, &code) is export {
    react {
		my $lock = "$path.lock";
		whenever Supply.interval(1) {
			if $_ >= $max-delay {
				$lock.IO.rmdir;
			}
			if !$lock.IO.d {
				$lock.IO.mkdir;
				&code();
				$lock.IO.rmdir;
				done;
			}
		}
    }
}

# FIXME this doesn't work?
sub with-locked-file-handle(IO::Handle $fh, Int $max-delay, &code) is export {
    react {
		whenever Supply.interval(1) {
			if $fh.lock(non-blocking => True) {
				&code();
				$fh.unlock;
				done;
			}
			if $_ > $max-delay {
				$fh.unlock;
			}
		}
    }
}
