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
use Storage;
use Filter;

=head1 Changes

=head2 view-changes()

=begin pod

This loads all the changes and renders them using the C<changes>
template.

=end pod

sub view-changes (Filter $filter!) is export {
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
    my $storage = Storage.new;
    my @changes = $storage.get-changes($filter);

    # Turn the object into a hash fit for the template.
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
	}, @changes;

    %params<changes> = @hashes;

	# The same is true for the filter description...
	my %filter =
	    tail	=> $filter.tail,
	    name	=> $filter.name,
		author	=> $filter.author,
		minor	=> $filter.minor;

	%params<filter> = %filter;

    my $template = $storage.get-template('changes');
    return Template::Mustache.render($template, %params);
}
