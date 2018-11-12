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
use Oddmuse::Storage::Delegate;
use Oddmuse::Storage::File::Lock;

=begin pod

=head1 Oddmuse::Storage::File

This module implements the L<Oddmuse::Storage> layer using plain text files.

Pages are saved in the C<page> subdirectory with the <md> extension.

Old revisions are saved in the C<keep> subdirectory with the <md>
extension, as numbered backups. Thus, the filenames have names such as
C<foo.md.~1~> and C<foo.md.~2~>. These are the numbered backups
supported by Emacs and C<cp --backup=numbered>, and maybe others. The
backup number is the revision. It starts at 1.

The log of all changes is C<rc.log> in the data directory.

Pages are locked using a lock I<directory>. It's name is the name of
the page and the suffix C<.locked>. Note that the suffix C<.lock> is
different: that's the short lived temporary lock created by
C<Oddmuse::Storage::File::Lock>.

=end pod

#| Implement storage layer using files.
class Oddmuse::Storage::File does Oddmuse::Storage::Delegate {

    my $SEP = "\x1e"; # ASCII UNIT SEPARATOR

    #| Return a new Page.
    multi method get-page(Str $id!, Bool $is-admin --> Oddmuse::Page) {
        my $dir = make-directory 'page';
        my $path = "$dir/$id.md";
        return Oddmuse::Page unless $path.IO.e;
        return Oddmuse::Page.new(
            text => $path.IO.slurp,
            locked => !$is-admin && self.is-locked($id),
        );
    }

    #| Return a new Page, assume no admin permissions
    multi method get-page(Str $id! --> Oddmuse::Page) {
        return self.get-page($id, False);
    }

    #| Save a Page.
    method put-page(Oddmuse::Page $page!) {
        my $dir = make-directory 'page';
        my $path = "$dir/{$page.id}.md";
        with-locked-file $path, 2, {
            $path.IO.spurt: $page.text;
        };
    }

    #| Get an old revision, or the current page if it doesn't exist.
    method get-keep-page(Str $id!, Int $n! --> Oddmuse::Page) {
        my $dir = make-directory 'keep';
        my $path = "$dir/$id.md.~$n~";
        return $.get-page($id) unless $path.IO.e;
        return Oddmuse::Page.new(
            revision => $n,
            text     => $path.IO.slurp);
    }

    #| Save new revision of a page and return the revision number.
    method put-keep-page(Str $id!) {
        my $from-dir = make-directory 'page';
        my $to-dir = make-directory 'keep';

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

    #| Add a Change to the log.
    method put-change(Oddmuse::Change $change!) {
        my $dir = make-directory '';
        my $path = "$dir/rc.log";
        with-locked-file $path, 2, {
            $path.IO.spurt(($change.ts, $change.minor ?? 1 !! 0,
                            $change.id, $change.revision, $change.author,
                            $change.code, $change.summary).join($SEP) ~ "\n",
                           :append);
        }
    }

    #| Get the changes matching a filter from the log file.
    method get-changes(Oddmuse::Filter $filter!) {
        my $dir = make-directory '';
        my $path = "$dir/rc.log";
        return () unless $path.IO.e;
        my %revisions = existing-revisions $filter;
        my @lines = $path.IO.lines.reverse;
        my @changes = @lines.map: { line-to-change $_, %revisions };
        @changes = @changes.grep: {$_.id eq $filter.id} if $filter.id;
        @changes = @changes.grep: {$_.author eq $filter.author} if $filter.author;
        @changes = @changes.grep: {!$_.minor} unless $filter.minor;
        @changes = latest-changes @changes unless $filter.all;
        @changes = @changes.head: $filter.n if $filter.n;
        return @changes;
    }

    #| Helper to turn a log line into a Change.
    sub line-to-change(Str $line!, %revisions --> Oddmuse::Change) {
        my ($ts, $minor, $id, $revision, $author, $code, $summary) = $line.split(/$SEP/);
        my $change = Oddmuse::Change.new(
            ts => DateTime.new($ts),
            minor => Bool.new($minor),
            :$id,
            revision => $revision.Int,
            :$author,
            :$code,
            :$summary,
            kept => so %revisions{$revision.Int + 1},
        );
        return $change;
    }

    #| Helper to hide previous changes to the same page.
    sub latest-changes(@changes) {
        my @results;
        my %seen;
        for @changes -> $change {
            next if %seen{$change.id};
            %seen{$change.id} = True;
            @results.push: $change;
        }
        return @results;
    }

    #| Helper to get the existing revisions
    sub existing-revisions(Oddmuse::Filter $filter --> Hash) {
        return {} unless $filter.id and $filter.all;
        my Str $id = $filter.id;
        my $dir = make-directory 'keep';
        my @keep-pages = $dir.IO.dir(test => /^ $id '.md.~' \d+ '~' $/);
        my %h;
        for @keep-pages {
            %h{$0} = True if $_ ~~ / "~" (\d+) "~" $/;
        }
        return %h;
    }

    #| Create appropriate subdirectory, if it doesn't exist. Copy
    #| default home page if creating the page subdirectory.
    sub make-directory(Str $subdir!) {
        my $dir = %*ENV<ODDMUSE_WIKI> || 'wiki';
        $dir ~= "/$subdir" if $subdir;
        if !$dir.IO.e {
            mkdir $dir;
            if $subdir eq 'page' {
                my $welcome = %?RESOURCES<wiki/page/Home.md>
                    || 'resources/wiki/page/Home.md';
                copy $welcome, "$dir/Home.md" if $welcome.IO.e;
            }
        }
        return $dir;
    }

    #| Get the current revision for a page.
    method get-current-revision(Str $id! --> Int) {
        my $dir = make-directory '';
        my $path = "$dir/rc.log";
        return 0 unless $path.IO.e;
        my @lines = $path.IO.lines.grep: /$SEP $id $SEP/;
        my @changes = @lines.map: { line-to-change($_) };
        for @changes.reverse {
            return $_.revision + 1 if .id eq $id;
        }
        return 0;
    }

    #| Lock a page.
    method lock-page(Str $id!) {
        my $dir = make-directory 'page';
        my $path = "$dir/$id.locked";
        $path.IO.mkdir;
    }

    #| Unlock a page.
    method unlock-page(Str $id!) {
        my $dir = make-directory 'page';
        my $path = "$dir/$id.locked";
        $path.IO.rmdir;
    }

    #| Is this page locked?
    method is-locked(Str $id!) {
        my $dir = make-directory 'page';
        my $path = "$dir/$id.locked";
        return $path.IO.e;
    }
}
