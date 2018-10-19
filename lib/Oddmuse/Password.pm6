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

use Oddmuse::Storage;
use Oddmuse::Layout;
use Oddmuse::Cookie;

=begin pod

=head1 Oddmuse::Password

C<with-pw> is how you wrap C<lock-page> from L<Oddmuse::Lock>.
Depending on whether the admin password is known, the C<ok> or the
C<not-ok> code is called. The C<not-ok> code should probably call
C<ask-for-pw> so that users can provide the missing password.

C<ask-for-pw> uses the C<password> template which takes the following
keys:

=item C<id> for the page name
=item C<action> for what to do with the page: C<lock> or C<unlock>

The C<password> is compared with the C<ODDMUSE_PASSWORD> environment
variable. The comparison is case-sensitive.

One way to set this up, for example:

    ODDMUSE_PASSWORD=UX@s8R-hNegM

=end pod

#| Run either the ok or the not-ok code depending on whether the user has the password.
sub with-pw(Str $pw, &not-ok, &ok --> Str) is export {
    if $pw && $pw eq %*ENV<ODDMUSE_PASSWORD> {
        # If a password was provided and it matches what we have, the
        # code gets called. Note that without a configured password,
        # this code must not be called.
        save-to-cookie 'pw', $pw;
        &ok();
    } else {
        # Otherwise ask for the password.
        &not-ok();
    }
}

#| Show the page asking for the password, or the page explaining that no password was configured.
sub ask-for-pw(Str $id!, Str $action! --> Str) is export {
    my $pw = %*ENV<ODDMUSE_PASSWORD>;
    my %context = :$id, :$action;
    my $storage = Oddmuse::Storage.new;
    my $template = $storage.get-template($pw ?? 'password' !! 'no-password');
    return render($template, %context);
}
