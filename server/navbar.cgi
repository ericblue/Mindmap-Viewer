#!/usr/bin/perl

use CGI qw /:all/;
use strict;
my $url = param("url");
my @menu;

$menu[0]->{name} = "Home";
$menu[0]->{url} = "index.html";
$menu[1]->{name} = "Share Your Maps";
$menu[1]->{url} = "share.html";
$menu[2]->{name} = "Download Plugin";
$menu[2]->{url} = "plugin.html";
$menu[3]->{name} = "Blog Posts";
$menu[3]->{url} = "blog.html";


print "Content-type: text/html\n\n";

my $output;

for (my $i = 0; $menu[$i]; $i++) {

    my $target = "";

    if ($ENV{'DOCUMENT_URI'} =~ /$menu[$i]->{url}/) {

        $output .= "<li><a id=\"current\" name=\"current\" href=\"$menu[$i]->{url}\">$menu[$i]->{name}</a></li>";
    }
    else {

	if ($menu[$i]->{target}) { 
            $target = "target=\"$menu[$i]->{target}\"";
        }

        $output .= "<li><a $target href=\"$menu[$i]->{url}\">$menu[$i]->{name}</a></li>";
    }
}

chop($output);
print $output;

