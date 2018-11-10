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
use Oddmuse::View;
use Oddmuse::Edit;
use Oddmuse::Save;
use Oddmuse::Diff;
use Oddmuse::Lock;
use Oddmuse::Cookie;
use Oddmuse::Filter;
use Oddmuse::Changes;
use Oddmuse::Password;
use URI::Encode;

=begin pod

=head1 Oddmuse::Routes

This is the most important code used by C<Cro>. See the C<README> for
more information.

=end pod

#| Define the various routes the wiki handles.
sub routes() is export {
    my $changes = %*ENV<ODDMUSE_CHANGES> || 'Changes';
    route {
        get -> 'view', $id where / $changes / {
            content 'text/html', view-changes(Oddmuse::Filter.new(n => 30));
        }
        http 'HEAD', -> 'view', $id {
            content 'text/html', '';
        }
        get -> 'view', $id, :$pw is cookie is copy {
            $pw = uri_decode_component($pw || '');
            content 'text/html', view-page($id, is-admin($pw));
        }
        get -> 'view', $id, $n where /^\d+$/, :$pw is cookie is copy {
            $pw = uri_decode_component($pw || '');
            content 'text/html', view-page($id, $n.Int, is-admin($pw));
        }
        get -> 'changes', :%params {
            content 'text/html', view-changes($%params);
        }
        get -> 'history', $id {
            content 'text/html', view-changes(Oddmuse::Filter.new(:$id, :minor, :all));
        }
        get -> 'diff', $id, :%params {
            my $a = $%params<from>.Int;
            my $b = $%params<to>.Int;
            content 'text/html', view-diff($id, min($a, $b), max($a, $b));
        }
        get -> 'diff', $id, $n where /^\d+$/ {
            content 'text/html', view-diff($id, $n.Int);
        }
        get -> 'edit', $id, :$author is cookie is copy {
            $author = uri_decode_component($author || '');
            content 'text/html', edit-page($id, $author);
        }
        post -> 'save', :$secret is cookie is copy, :$pw is cookie is copy {
            $secret = uri_decode_component($secret || '');
            # pw in the cookie is the default; we're going to look at
            # the pw in the request, too
            my $default = uri_decode_component($pw || '');
            request-body -> (:$id!, :$text!,
                             :$summary = '', :$minor = False,
                             :$author = '', :$answer = '', :$pw = $default) {
                save-to-cookie('author', $author);
                # In order to avoid «Type check failed in binding to
                # parameter '$id'; expected Str but got
                # Cro::HTTP::Body::MultiPartFormData::Part
                # (Cro::HTTP::Body::MultiPartFormData::Part.new(headers
                # => Array...)» we're converting to Str explicitly.
                content 'text/html', save-with-secret(
                    id => $id.Str, text => $text.Str, summary => $summary.Str,
                    author => $author.Str, answer => $answer.Str,
                    minor => $minor ?? True !! False,
                    secret => $secret,
                    :$pw,
                );
            }
        }
        post -> 'rollback', $id, $revision where /^\d+$/, :$author is cookie is copy, :$secret is cookie is copy, :$pw is cookie is copy {
            $author = uri_decode_component($pw || '');
            $secret = uri_decode_component($secret || '');
            $pw = uri_decode_component($pw || '');
            request-body -> (:$summary!, *%) {
                content 'text/html', rollback-with-secret(
                    :$id, revision => $revision.Int, :$summary, :$author,
                    :$secret, :$pw);
            }
        }
        post -> 'lock', $id, :$pw is cookie is copy {
            $pw = uri_decode_component($pw || '');
            my $default = $pw; # the pw in the cookie is the default
            request-body -> (:$pw) {
                content 'text/html', lock-with-pw(:$id, pw => $pw || $default);
            }
        }
        post -> 'unlock', $id, :$pw is cookie is copy {
            $pw = uri_decode_component($pw || '');
            my $default = $pw; # the pw in the cookie is the default
            request-body -> (:$pw) {
                content 'text/html', unlock-with-pw(:$id, pw => $pw || $default);
            }
        }
        get -> 'css', *@path {
            my $dir = %*ENV<ODDMUSE_CSS> || 'css';
            if $dir.IO.e {
                static $dir, @path;
            } else {
                static %?RESOURCES<css/default.css>
            }
        }
        get -> 'images', *@path {
            my $dir = %*ENV<ODDMUSE_IMAGES> || %?RESOURCES<images> || 'images';
            if $dir.IO.e {
                static $dir, @path;
            } else {
                static %?RESOURCES<images/logo.png>
            }
        }
        get -> 'favicon.ico' {
            my $dir = %*ENV<ODDMUSE_IMAGES> || %?RESOURCES<images> || 'images';
            if $dir.IO.e {
                static $dir, 'logo.png';
            } else {
                static %?RESOURCES<images/logo.png>
            }
        }
        get -> :$pw is cookie is copy {
            $pw = uri_decode_component($pw || '');
            content 'text/html', view-page("Home", is-admin($pw));
        }
    }
}
