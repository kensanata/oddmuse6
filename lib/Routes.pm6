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
use View;
use Edit;
use Save;

sub routes() is export {
    route {
        get -> 'edit', $id {
            content 'text/html', edit-page($id);
        }
        get -> 'view', $id {
            content 'text/html', view-page($id);
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
	    static 'css', @path;
	}
        get -> {
            content 'text/html', view-page("Home");
        }
    }
}
