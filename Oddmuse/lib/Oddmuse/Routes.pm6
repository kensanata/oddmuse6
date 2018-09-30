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
use Oddmuse::Changes;
use Oddmuse::Filter;
use Oddmuse::Diff;

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
        get -> 'view', $id {
            content 'text/html', view-page($id);
        }
        get -> 'view', $id, $n where /^\d+$/ {
            content 'text/html', view-page($id, $n.Int);
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
        get -> 'edit', $id {
            content 'text/html', edit-page($id);
        }
        post -> 'save' {
            request-body -> (:$id!, :$text!,
							 :$summary, :$minor,
							 :$author) {
				save-page(:$id, :$text, :$summary,
						  minor => $minor ?? True !! False,
						  :$author);
				content 'text/html', view-page($id);
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
        get -> {
            content 'text/html', view-page("Home");
        }
    }
}
