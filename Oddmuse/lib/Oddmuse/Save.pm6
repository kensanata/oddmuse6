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
use Oddmuse::Storage;

=begin pod

=head1 Oddmuse::Save

This is the convenience function used to save pages. It's the
front-end to the various L<Oddmuse::Storage> functions:

=item save a "keep" page
=item save the new page
=item record the change

Keep files are old, numbered revisions of the page.

=end pod

#| Save a page. Compute the code for anonymous users.
sub save-page (Str :$id!, Str :$text!,
			   Str :$summary = '', Bool :$minor = False,
			   Str :$author = '') is export {

    # Use djb2 to generate octal numbers for pseudoanonymity based on
    # the IP number. X-Forwarded-For is the header available behind an
    # Apache Proxy (where REMOTE_ADDR will always be the IP number of
    # the host where Apache runs).
    my $code= "";
    if !$author {
		my $ip = %*ENV<HTTP_X_FORWARDED_FOR> || %*ENV<REMOTE_ADDR> || "";
		# FIXME: double check djb2 implementation
		# Also check https://stackoverflow.com/questions/1579721/why-are-5381-and-33-so-important-in-the-djb2-algorithm
		my $hash = [5381, |$ip.ords].reduce(* * 33 +^ *) mod 8**4;
		$code = $hash.Str;
    }

    my $storage = Oddmuse::Storage.new;

    my $page = Oddmuse::Page.new(name => $id, text => $text);
    my $revision = $storage.put-keep-page($id);
    $storage.put-page($page);

    my $change = Oddmuse::Change.new(
        ts => DateTime.now,
		:$minor,
		name => $id,
		:$revision,
		author => $author,
		code => $code,
		:$summary);

    $storage.put-change($change);
}
