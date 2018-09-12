#!/usr/bin/env perl
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

use Text::Markdown;

unit module Pages;

sub get-html-page (Str $id) is export {
    my $html = join("\n", get-header().to_html,
		    get-page($id).to_html,
		    get-footer.to_html);
    return $html;
}

sub get-page (Str $id) {
    my $path = get-path($id);
    return parse-markdown(get-default-text()) unless $path.IO.e;
    return parse-markdown(get-forbidden-text()) unless $path.IO.r;
    return parse-markdown-from-file($path);
}

sub get-default-text () {
    return "This page doesn't exist yet, but you can create it."; # FIXME
}

sub get-forbidden-text () {
    return "This page exists but it cannot be read."; # FIXME
}

sub get-header () {
    my $path = get-path('header');
    return parse-markdown(get-default-header()) unless $path.IO.e;
    return parse-markdown(get-forbidden-header()) unless $path.IO.r;
    return parse-markdown-from-file($path);
}

sub get-default-header () {
    return "[Home](Home) [About](About)"; # FIXME
}

sub get-forbidden-header () {
    return "The page header exists but it cannot be read."; # FIXME
}

sub get-footer () {
    my $path = get-path('footer');
    return parse-markdown(get-default-footer()) unless $path.IO.e;
    return parse-markdown(get-forbidden-footer()) unless $path.IO.r;
    return parse-markdown-from-file($path);
}

sub get-default-footer () {
    return "[Edit](edit/Home)"; # FIXME
}

sub get-forbidden-footer () {
    return "The page footer exists but it cannot be read."; # FIXME
}

sub get-path (Str $id) {
    my $dir = %*ENV<dir>;
    return "$dir/page/$id.md";
}
