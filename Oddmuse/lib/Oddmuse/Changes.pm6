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

use Template::Mustache;
use Oddmuse::Storage;
use Oddmuse::Filter;

=head1 Changes

=head2 view-changes()

=begin pod

This loads all the changes and renders them using the C<changes>
template.

This happens via an array called C<changes>. Each element is a hash
with the following keys:

=item C<date> in the format C<YYYY-mm-dd>.

=item C<first> is set when this is the first change in the list of
changes. The template can uses this for the first day heading.

=item C<last> is set when this is the last change in the list of
changes. The template can uses this for HTML cleanup.

=item C<day> is set when this change is on a different date compared
to previous changes. The template can uses this for subsequent day
heading.

=item C<time> in the format C<hh-mm-ss>.

=item C<minor> to indicate whether this is a minor change.

=item C<name> is the name of the page affected.

=item C<revision> is the revision that was changed, which is
equivalent to the number of edits made to a page.

=item C<to> is the revision that the change resulted in, which is just
the revision + 1. That's the revision that will be shown when looking
at the change.

=item C<author> is the name of the author, if specified.

=item C<code> is a code used to identify changes when no author was
provided. In this case the IP number of the user making the change is
used to compute four numbers in the range from 1 to 8, and these
numbers are then turned into a color using the default CSS. This
generates little color codes that look a bit like flags.

=item C<summary> is the summary provided for the change, if any.

=end pod

multi view-changes (%params!) is export {
    view-changes(Oddmuse::Filter.new.from-hash(%params));
}

multi view-changes (Oddmuse::Filter $filter!) is export {
    my $menu = %*ENV<menu> || "Home, Changes";
    my @pages = $menu.split(/ ',' \s* /);
    my %params =
	id => %*ENV<changes> || "Changes",
	pages => [ map { id => $_ }, @pages ];

	# Get the changes from storage. Note that the revision is the
	# revision that was changed: the first revision has number 1. To
	# look at the change, however, you'd want to look at the result,
	# the revision after that! Thus, for the last change, there is no
	# keep file! That's why we introduce the new key show-revision,
	# below.
    my $storage = Oddmuse::Storage.new;
    my @changes = $storage.get-changes($filter);

    # Turn the object into a hash fit for the template.
    my $day = '';
    my @hashes = map {
		my %change =
			date => $_.ts.yyyy-mm-dd,
			time => $_.ts.hh-mm-ss,
			minor => $_.minor,
			name => $_.name,
			revision => $_.revision,
			to => $_.revision + 1,
			author => $_.author,
			# { c => "1", c=> "2", c=> "3", c=> "4", }
			code => [ map { c => $_ }, $_.code.split("", :skip-empty) ],
			summary => $_.summary||'';
        if not $day {
            %change<first> = True;
            $day = %change<date>;
        } elsif $day ne %change<date> {
            %change<day> = True;
            $day = %change<date>;
        }
        %change;
	}, @changes;

    %params<changes> = @hashes;

	# The same is true for the filter description...
	my %filter =
	    n		=> $filter.n,
	    name	=> $filter.name,
		author	=> $filter.author,
		minor	=> $filter.minor,
		all	    => $filter.all;

	%params<filter> = %filter;

    my $template = $storage.get-template('changes');
    return Template::Mustache.render($template, %params);
}
