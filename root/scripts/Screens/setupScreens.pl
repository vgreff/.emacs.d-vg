#!/usr/bin/perl -w
#
# HISTORY FILE: %P%
#
# VERSION: %I%
#    
# CREATED: May 6, 2011 by Vincent B. Greff
#
# LAST CHANGED: %G% %U% 
#
# AUTHOR: Vincent B. Greff
#
#
# vcsId = "%W%	%E% %U%"

#===============================================================================
# wmctrl -l -x -G > ~/Documents/HIST/win_`now`.txt'
# fgrep Emacs  HIST/win_20110506-093322.txt | sort -k 8,9  > win.txt
#===============================================================================
# extend include path
# BEGIN
# {
#     use lib qw#. .. /path1 /path2#;
# };

use strict;
use Data::Dumper;
$Data::Dumper::Sortkeys=1; #sort all hash keys before dumping

#===============================================================================
# my %option = ();

# use Getopt::Std;

# getopts("hB:", \%option);

# sub usage
# { 
#     print "Usage: \n";
#     print "      -B value = \n";
#     print "      -h = help, print usage\n";
#     exit(1);
# }

# usage() if ($option{h});

# if ($option{B})
# {
#     $dirPrefix="$option{B}"
# }
#===============================================================================
my $hostPrev="";

while(<>)
{
    my @line = split();
    my $i=0;
    my $id=$line[$i++];
    my $desk=$line[$i++];
    my $posx=$line[$i++];
    my $posy=$line[$i++];
    my $szx=$line[$i++];
    my $szy=$line[$i++];
    my $app=$line[$i++];
    my $host=$line[$i++];
    my $title=$line[$i++];
    my $titleFull=$title;
    #print "$host\n" ;
    open(VGOUT, "> $host") if ($host ne $hostPrev);
    $hostPrev=$host;

    if ($title =~ /emacs@/i)
    {
        next;
    }
    elsif ($title =~ /^cpp/i)
    {
        $title =~ s|ruby/||g;
        print VGOUT "cd ; cjv ;cd cpp;";
    }
    elsif ($title =~ /^ruby/i)
    {
        $title =~ s|ruby/||g;
        print VGOUT "cd ; cjv ; cd `find ruby -type d -name \"*$title\" | egrep -v \"ORG-|database\"`; ";
    }
   elsif ($title =~ /^jvt/i)
    {
        $title =~ s|jvt/||g;
        print VGOUT "cd ; cjv ; cd `find cpp  -type d -name \"*$title\"`; ";
    }
    elsif ($title =~ /js/i)
    {
        print VGOUT "cd ; cjs; cd src; ";
    }
    elsif ($title =~ /jet/i)
    {
        print VGOUT "cd ; cj; ";
    }
    else
    {
        print VGOUT "cd ; cjv; ";
    }
    print VGOUT "e -T $titleFull -f load-marker-list\n";
    
    close(VGOUT) if ($host ne $hostPrev);

    print  "wmctrl -r $titleFull -e 0,$posx,$posy,$szx,$szy ; ";
    print  "wmctrl -r $titleFull -t $desk ; ";
    print  "wmctrl -r $titleFull -b add,maximized_vert,maximized_horz ; ";
    print "\n" ;

}
