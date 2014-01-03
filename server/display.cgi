#!/usr/bin/perl

# $Id: display.cgi,v 1.3 2010-03-27 00:54:54 ericblue76 Exp $
#
# Author:       Eric Blue - ericblue76@gmail.com
# Project:      MindMap Viewer
#
# Revision History:
#
# $Log: display.cgi,v $
# Revision 1.3  2010-03-27 00:54:54  ericblue76
# Changed file limit to 10MB
#
# Revision 1.2  2007/12/13 19:41:37  dev
# Used perltidy to fix formatting
#
#
#

use CGI;
use CGI::Carp qw(fatalsToBrowser set_message warningsToBrowser);
use CGI::Lite;
use LWP::UserAgent;
use LWP::Simple;
use Data::Dumper;
use MIME::Base64;
use DateTime;
use DateTime::Format::HTTP;
use File::Remove qw(remove);
use Log::Log4perl qw(:easy);
use vars qw($q $logger);
use XML::Simple;
use strict;

my $zip_dir = "/tmp/mindmapview/$$";
my $xml     = "";

sub error {
    my ($message) = @_;
    $logger->error($message);

    print $q->header( -status => '500 Internal Server Error' );
    print qq{
    <html>
    <head><title>Error Displaying MindMap</title></head>
    <body><H3>Internal Server Error</H3>$message</body>
    </html>
    };
    exit(1);
}

sub convert_image {

    my ( $filename, $height, $width ) = @_;

    my $conv_tmp = "/usr/local/wine/emf2vec/tmp";
    my $conv_cmd = "/usr/bin/sudo /usr/local/wine/emf2vec/convert.sh";

    if ( length($filename) < 1 ) {
        $logger->error("Filename length is < 1");
        return -1;
    }

    $logger->info("Processing $filename");

    if ( -e "$zip_dir/bin/$filename" ) {
        $logger->info("Converting to input.emf");
        system("cp -f $zip_dir/bin/$filename $conv_tmp/input.emf");
        $logger->info( "Stat: ", `ls -l "$conv_tmp/input.emf"` );
        $logger->info("Converting to output.pdf");
        system("cd $conv_tmp; $conv_cmd input.emf output.pdf >/dev/null 2>/dev/null");
        $filename =~ s/.bin/.gif/;

        #my $dim = $height . "x" . $width;
        my $dim = 60 . "x" . 60;
        $logger->info("Converting to gif ($filename): height = $height, width = $width");
        system("cd $zip_dir/bin; /usr/bin/convert -transparent white -resize $dim $conv_tmp/output.pdf $filename >/dev/null 2>/dev/null");
        unlink("$conv_tmp/input.emf");
        unlink("$conv_tmp/output.pdf");

        return 1;
    }
    else {
        return -1;
    }

}

sub post_process_xml {

    my ($node) = @_;

    foreach ( keys( %{$node} ) ) {

        if ( $_ eq "TEXT" ) {

            if ( $node->{'TEXT'} =~ /mmarch:/ ) {
                my ($image_data) = ( $node->{'TEXT'} =~ /({.*})/ );

                my $tmp = $image_data;
                $tmp =~ s/{//g;
                $tmp =~ s/}//g;
                my ( $mmarch, $height, $width ) = split( /,/, "$tmp" );
                $mmarch =~ s/mmarch:\/\/bin\///g;
                if ( convert_image( $mmarch, $height, $width ) != 1 ) {
                    $xml =~ s/$image_data//;
                }
                else {
                    $mmarch =~ s/.bin/.gif/g;
                    my $img_html = "&lt;html&gt;&lt;img src=&quot;http://eric-blue.com/projects/mindmapviewer/maps/img/$mmarch&quot;&gt;";
                    $xml =~ s/$image_data/$img_html/;
                }
            }

        }

        if ( $_ eq "node" ) {

            if ( ref( $node->{'node'} ) eq "ARRAY" ) {
                foreach my $sub_node ( @{ $node->{'node'} } ) {
                    post_process_xml($sub_node);
                }
            }

        }

    }

}

# Init logger
Log::Log4perl->init("conf/logger.conf");
$logger = get_logger();

# Init CGI
$q = new CGI;
warningsToBrowser(1);

my $display_format = $q->param('format');
if ( !defined $display_format ) {
    $display_format = "flash";
}
my $url = $q->param('mmap_url');

$logger->info("Converting mindmap at URL: $url");
if ( ( $url !~ /^http/ ) || ( $url !~ /.mmap$/ ) ) {
    error "URL is not valid!";
}

my $ua = new LWP::UserAgent;
$ua->timeout(10);

# limit size to 10MB
$ua->max_size( 10000 * 1024 );

my $request_head = new HTTP::Request( 'HEAD', $url );
my $head = $ua->request($request_head);
my $status = $head->{'_rc'};

if ( !$head->is_success ) {
    error "Error retriving file: status = $status";
}

my $last_modified = $head->{'_headers'}->{'last-modified'};
my $last_modified_epoch = 0;

if ( defined $last_modified ) {
    $last_modified_epoch =
      DateTime::Format::HTTP->parse_datetime($last_modified)->epoch();
    $logger->debug(
        "Lost modified = $last_modified, epoch = $last_modified_epoch");
}

my $decoded_url = url_decode($url);
my $enc = `echo '$decoded_url' | md5sum`;
my ( $encoded_url, $n ) = split( / /, "$enc" );
chomp $encoded_url;

my $converted_filename = $encoded_url . "-" . $last_modified_epoch . ".mm";

if ( !-e "maps/$converted_filename" ) {

    $logger->debug(
        "File hasn't been fetched yet, performing HEAD to get status");
    my $request = new HTTP::Request( 'GET', $url );
    my $response = $ua->request($request);
    my $status = $response->{'_rc'};

    if ( !$response->is_success ) {
        error "Error retriving file: status = $status";
    }

    my $content = $response->{'_content'};
    error "Couldn't get $url" unless defined $content;

    mkdir("$zip_dir") or error "Unable to create directory $zip_dir";
    open( ZIP, ">$zip_dir/mindmap.zip" )
      or error "Unable to save mindmap file: content length = ",
      length($content);
    print ZIP $content;
    close(ZIP);

    system("cd $zip_dir;/usr/bin/unzip $zip_dir/mindmap.zip >/dev/null");
    if ( !-e "$zip_dir/Document.xml" ) {
        error "Couldn't extract XML document from .mmap file (pid = $$)!";
    }

    $xml = `xsltproc xsl/mindmanager2mm.xsl $zip_dir/Document.xml 2>/dev/null`;
    if ( length($xml) < 1 ) {
        error "Couldn't convert to freemind format!";
    }

    my $xs   = XML::Simple->new();
    my $xref = $xs->XMLin($xml);
    post_process_xml( $xref->{'node'} );

    #my $xml_processed = $xs->XMLout($xref, RootName=>'map', noattr => 0);
    #$xml_processed =~s/&amp;/&/g;

    open( XML, ">maps/$converted_filename" )
      or error "Can't write converted file to maps directory!";
    print XML $xml;
    close(XML);

    system("cp -f $zip_dir/bin/*.gif maps/img");

    remove \1, qw($zip_dir);

}
else {
    $logger->debug("File exists, reading from disk - $converted_filename");
}

my $template_file;

if ( $display_format eq "java" ) {
    $template_file = "java/display_java.tpl";
}
elsif ( $display_format eq "flash" ) {
    $template_file = "flash/display_flash.tpl";
}
else {
    error "Invalid display format (type = Java or Flash)";
}

$/ = undef;
open( TPL, "$template_file" ) or error("Can't open template for display");
my $tpl = <TPL>;
close(TPL);
$/ = "\n";

$logger->debug( Dumper \%ENV );

my $bookmark_url = "http://eric-blue.com/projects/mindmapviewer/display.cgi";
my $u            = url_encode($url);
$u =~ s/\./\%2E/g;
$bookmark_url .= "?mmap_url=$u&format=$display_format";

my $header = qq{
    <a target="about" href="http://eric-blue.com/projects/mindmapviewer/">What's This?<a>
    &nbsp;|&nbsp;
    <a href="$bookmark_url">Bookmarkable URL</a>
    &nbsp;|&nbsp;
    <a target="newwindow" href="$bookmark_url">Full Screen</a>
    };

my $content = $tpl;
$content =~ s/\$MAPID\$/$converted_filename/g;
$content =~ s/\$HEADER\$/$header/g;

print $q->header();
print $content;

