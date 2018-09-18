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

use Page;
use Change;

=head1 Storage::File
==begin pod
This module implements the C<Storage> layer using plain text files.
==end pod

class Storage::File {

    my $SEP = "\x1e"; # ASCII UNIT SEPARATOR

    =head2 get-page
    =begin pod
    Pages are files in the C<page> subdirectory with the C<md> extension.
    =end pod

    method get-page (Str $id) is export {
	my $dir = %*ENV<dir>;
	my $path = "$dir/page/$id.md";
	return Page.new(exists => False) unless $path.IO.e;
	my $fh = open $path, :enc('UTF-8');
	return Page.new(exists => True, text => $fh.slurp);
    }

    =head3 put-page
    =begin pod
    Pages are saved in the C<page> subdirectory with the <md> extension.
    =end pod

    method put-page (Page $page) is export {
	my $dir = %*ENV<dir>;
	my $path = "$dir/page/$($page.name).md";
	spurt $path, $page.text, :enc('UTF-8');
    }

    =head4 get-template
    =begin pod
    Pages are files in the C<templates> subdirectory with the <sp6> extension.
    =end pod

    method get-template (Str $id) is export {
	my $dir = %*ENV<dir>;
	my $path = "$dir/templates/$id.sp6";
	my $fh = open $path, :enc('UTF-8');
	return $fh.slurp;
    }

    =head4 put-change
    =begin pod
    The log of all changes is C<rc.log> in the data directory.
    =end pod

    method put-change (Change $change) is export {
	my $dir = %*ENV<dir>;
	my $path = "$dir/rc.log";
	my $fh = open $path, :a, :enc('UTF-8');
	$fh.say(($change.ts, $change.minor ?? 1 !! 0,
		 $change.name, $change.author, $change.code,
		 $change.summary).join($SEP));
    }

    =head4 get-changes
    =begin pod
    The log of all changes is C<rc.log> in the data directory.
    =end pod

    # FIXME add filter support
    method get-changes () is export {
	my $dir = %*ENV<dir>;
	my $path = "$dir/rc.log";
	my $fh = open $path, :enc('UTF-8');
	my @lines = $fh.lines.tail(30);
	my @changes = map { line-to-change $_ }, @lines;
	return @changes;
    }

    sub line-to-change (Str $line) {
	my ($ts, $minor, $name, $author, $code, $summary) = $line.split(/$SEP/);
	my $change = Change.new(
	    ts		=> DateTime.new($ts),
	    minor	=> Bool.new($minor),
	    name	=> $name,
	    author	=> $author,
	    code	=> $code,
	    summary	=> $summary,
	);
	return $change;
    }
}
