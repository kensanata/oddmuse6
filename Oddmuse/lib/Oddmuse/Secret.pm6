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

=head1 Oddmuse::Secret

C<with-secret> is how you wrap C<save-page> from L<Oddmuse::Save>.
Depending on whether the secret is known, or whether a correct answer
was given, the C<ok> or the C<not-ok> code is called. The C<not-ok>
code should probably call C<ask-for-secret> so that users can provide
an answer.

C<ask-for-secret> uses the C<secret> template which takes the same
context keys as when saving a page:

=item C<id> for the page name
=item C<text> for the new text
=item C<summary> for the optional change summary
=item C<minor> for the optional marking as a minor change
=item C<author> for the optional author name
=item C<question> for the question

The C<question> is set from the C<ODDMUSE_QUESTION> environment
variable. The answer provided is then compared with the solutions
presented in the C<ODDMUSE_ANSWER> environment variable. This variable
contains the comma-separated correct answers. The comparison is
case-insensitive.

One way to set these up, for example:

    ODDMUSE_QUESTION=Name a colour of the rainbow.
    ODDMUSE_ANSWER=red, orange, yellow, green, blue, indigo, violet

=end pod

#| Run either the ok or the not-ok code depending on whether the user has the secret cookie.
sub with-secret($secret, $answer, &not-ok, &ok --> Str) is export {
    if !%*ENV<ODDMUSE_SECRET> || $secret && $secret eq %*ENV<ODDMUSE_SECRET> {
        # If no secret is configured, or if a secret was provided and
        # it matches what we have, the code gets called.
        &ok();
    } elsif $answer && verify-answer $answer {
        # If the correct answer was given, let them know the secret,
        # and call the code.
        save-to-cookie 'secret', %*ENV<ODDMUSE_SECRET>;
        &ok();
    } else {
        # Otherwise ask the question and see whether they can answer
        # it.
        &not-ok();
    }
}

#| Show the page asking for the secret.
sub ask-for-secret(:$id!, :$text!, :$summary, :$minor, :$author --> Str) is export {
    my $question = %*ENV<ODDMUSE_QUESTION>;
    my %context = :$id, :$text, :$summary, :$minor, :$author, :$question;
    my $storage = Oddmuse::Storage.new;
    my $template = $storage.get-template('secret');
    return render($template, %context);
}

#| Verify the answer given to the secret question
sub verify-answer(Str $answer! --> Bool) {
    return True unless %*ENV<ODDMUSE_ANSWER>;
    return False unless $answer;
    my @answers = %*ENV<ODDMUSE_ANSWER>.split(/ ',' \s* /).map: { .fc };
    return @answers.grep($answer.fc).Bool;
}
