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
use Oddmuse::Filter;
use Oddmuse::Storage::File::Lock;

=head1 Oddmuse::Storage::File
==begin pod
This module implements the C<Storage> layer using plain text files.
==end pod

class Oddmuse::Storage::File {

    my $SEP = "\x1e"; # ASCII UNIT SEPARATOR

    =head2 get-page
    =begin pod
    Pages are files in the C<page> subdirectory with the C<md> extension.
    =end pod

    method get-page (Str $id!) is export {
		my $dir = make-directory('page');
		my $path = "$dir/$id.md";
		return Oddmuse::Page.new(exists => False) unless $path.IO.e;
		my $fh = open $path, :enc('UTF-8');
		return Oddmuse::Page.new(exists => True, text => $fh.slurp);
    }

    =head3 put-page
    =begin pod
    Pages are saved in the C<page> subdirectory with the <md> extension.
    =end pod

    method put-page (Oddmuse::Page $page!) is export {
		my $dir = make-directory('page');
		my $path = "$dir/{$page.name}.md";
		with-locked-file $path, 2, {
			spurt $path, $page.text, :enc('UTF-8');
		};
	}
    =head3 get-keep-page
    =begin pod
    Backup pages are saved in the C<keep> subdirectory with the
    <md.~n~> extension, where C<n> is an integer. These are the
    numbered backups supported by Emacs and C<cp --backup=numbered>,
    and maybe others.
    =end pod

    method get-keep-page (Str $id!, Int $n!) is export {
		my $dir   = make-directory('keep');
		my $path = "$dir/$id.md.~$n~";
		if $path.IO.e {
			my $fh = open $path, :enc('UTF-8');
			return Oddmuse::Page.new(
				exists		=> True,
				revision	=> $n,
				text		=> $fh.slurp);
		}
		return $.get-page($id);
	}

    =head3 put-keep-page
    =begin pod
    Backup pages are saved in the C<keep> subdirectory with the
    <md.~n~> extension, where C<n> is an integer. These are the
    numbered backups supported by Emacs and C<cp --backup=numbered>,
    and maybe others.
    =end pod

    method put-keep-page (Str $id!) is export {
		my $from-dir = make-directory('page');
		my $to-dir   = make-directory('keep');

		# lock the source file!
		my $path = "$from-dir/$id.md";
		return 0 unless $path.IO.e;

		my $n = 1;
		with-locked-file $path, 2, {

			# find the highest n + 1
			my @keep-pages = $to-dir.IO.dir(test => /^ $id '.md.~' \d+ '~' $/);
			for @keep-pages {
				$n = $0 +1 if $_ ~~ / "~" (\d+) "~" $/ and $0 >= $n;
			}

			copy "$from-dir/$id.md", "$to-dir/$id.md.~$n~";
		};
		return $n;
	}

	=head4 put-change
	=begin pod
	The log of all changes is C<rc.log> in the data directory.
	=end pod

	method put-change (Oddmuse::Change $change!) is export {
		my $dir = make-directory('');
		my $path = "$dir/rc.log";
		with-locked-file $path, 2, {
			my $fh = open $path, :a, :enc('UTF-8');
			$fh.say(($change.ts, $change.minor ?? 1 !! 0,
					 $change.name, $change.revision, $change.author,
					 $change.code, $change.summary).join($SEP));
		};
	}

	=head4 get-changes
	=begin pod
	The log of all changes is C<rc.log> in the data directory.
	=end pod

	method get-changes (Oddmuse::Filter $filter!) is export {
		my $dir = make-directory('');
		my $path = "$dir/rc.log";
		return () unless $path.IO.e;
		my $fh = open $path, :enc('UTF-8');
		my @lines = $fh.lines;
		my @changes = map { line-to-change $_ }, @lines;
		@changes = grep {$_.name eq $filter.name}, @changes if $filter.name;
		@changes = grep {$_.author eq $filter.author}, @changes if $filter.author;
		@changes = grep {!$_.minor}, @changes unless $filter.minor;
		@lines = @lines.tail($filter.tail) if $filter.tail;
		return @changes;
	}

	sub line-to-change (Str $line!) {
		my ($ts, $minor, $name, $revision, $author, $code, $summary) = $line.split(/$SEP/);
		my $change = Oddmuse::Change.new(
			ts			=> DateTime.new($ts),
			minor		=> Bool.new($minor),
			name		=> $name,
			revision	=> $revision.Int,
			author		=> $author,
			code		=> $code,
			summary		=> $summary,
		);
		return $change;
	}

	sub make-directory(Str $subdir!) {
		my $dir = %*ENV<wiki> || 'wiki';
		$dir ~= "/$subdir" if $subdir;
        if (!$dir.IO.e) {
		    mkdir($dir);
            if $subdir eq 'page' {
                my $welcome = %?RESOURCES<wiki/page/Home.md>
                	|| 'resources/wiki/page/Home.md';
                copy $welcome, "$dir/Home.md" if $welcome.IO.e;
            }
        }
		return $dir;
	}
}
