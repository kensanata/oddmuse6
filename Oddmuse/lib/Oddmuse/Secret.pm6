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

=begin pod

=head1 Oddmuse::Secret

This function is an alternative for L<Oddmuse::Save> which is called
by L<Oddmuse::Route> when the user doesn't have the secret cookie set.

If the page does not exist, the C<secret> template is used.

=end pod

#| Show the page asking for the secret.
sub ask-for-secret(:$id!, :$text!,
                   :$summary, :$minor,
                   :$author) is export {
    my $question = %*ENV<ODDMUSE_QUESTION>;
    my %context = :$id, :$text, :$summary, :$minor, :$author, :$question;
    my $storage = Oddmuse::Storage.new;
    my $template = $storage.get-template('secret');
    return render($template, %context);
}

#| Verify the answer given to the secret question
sub verify-answer(Str $answer! --> Bool) is export {
    return True unless %*ENV<ODDMUSE_ANSWER>;
    my @answers = %*ENV<ODDMUSE_ANSWER>.split(/ ',' \s* /);
    return @answers.grep($answer).Bool;
}
