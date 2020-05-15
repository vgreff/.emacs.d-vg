#!/usr/bin/perl -w
#
# HISTORY FILE: %P%
#
# VERSION: %I%
#    
# CREATED: October 13, 2011 by Vincent B. Greff
#
# LAST CHANGED: %G% %U% 
#
# AUTHOR: Vincent B. Greff
#
#
# vcsId = "%W%	%E% %U%"


#===============================================================================
# extend include path
# BEGIN
# {
#     use lib qw#. .. /path1 /path2#;
# };

use strict;
use Data::Dumper;
$Data::Dumper::Sortkeys=1; #sort all hash keys before dumping
use Cwd qw(abs_path);
use File::Basename;
 
#===============================================================================
my $HOMEDIR=$ENV{"HOME"};
my $LOGDIR="$HOMEDIR/LOG";
my $PIDDIR="$HOMEDIR/PID";

my $dirBase = abs_path(dirname(__FILE__) . '/../');
my $myDir = abs_path(dirname(__FILE__));
my $myApp = basename(__FILE__);
my $packageName = basename $myDir;
#===============================================================================
my %option = ();

use Getopt::Std;

getopts("hJ:C:A:S:", \%option);

sub usage
{ 
    print "Usage: \n";
    print "      -J jobId  \n";
    print "      -C appname  \n";
    print "      -A args  \n";
    print "      -S startDateTime  \n";
    print "      -h = help, print usage\n";
    exit(1);
}

usage() if ($option{h});

my $jobId=0;
if ($option{J})
{
    $jobId="$option{J}";
}
my $appname="";
if ($option{C})
{
    $appname="$option{C}";
}
my $args="";
if ($option{A})
{
    $args="$option{A}";
}
my $startDateTime="";
if ($option{S})
{
    $startDateTime="$option{S}";
}
#===============================================================================
$ENV{"STARTTIME"} = $startDateTime;
my $startDate = `date +%Y-%m-%d`;
chop $startDate;
$ENV{"STARTDATE"} = $startDate;

$ENV{"PATHORG"} = $ENV{"PATH"};
$ENV{"LD_LIBRARY_PATHORG"} = $ENV{"LD_LIBRARY_PATH"};
#===============================================================================
$ENV{"APPJID"} = $jobId;
$ENV{"APPNAME"} = $appname;
$ENV{"APPARGS"} = $args;
$ENV{"APPSTARTTIME"} = $startDateTime;
$ENV{"APPPKGNAME"} = $packageName;
$ENV{"APPPKGNAME"} = $packageName;
$ENV{"APPSCRIPTDIR"} = $myDir;
$ENV{"APPSCRIPTNAME"} = $myApp;

$ENV{"APPSTARTDATE"} = $startDate;
my $startTime = `date +%H:%M:%S`;
chop $startTime;
$ENV{"APPSTARTTIME"} = $startTime;

#===============================================================================

my $pid = fork();
die "unable to fork: $!" unless defined($pid);

my $piddir = "$PIDDIR";
my $pidfile =  "${appname}.${jobId}";
$ENV{"APPPIDDIR"} = $piddir;
$ENV{"APPPIDFILE"} = $pidfile;

if (!$pid)
{  # child
    my $startDateTimeDir = $startDateTime;
    $startDateTimeDir =~ s/:/-/g;
    my $dir ="$LOGDIR/${startDate}_${startDateTimeDir}";
    my $logfile =  $pidfile;
    $ENV{"APPLOGDIR"} = $dir;
    $ENV{"APPLOGFILE"} = $logfile;
    unless(-d $dir)
    {
        system("mkdir -p $dir");
    }
    my @line1 = split(/#/,$args);
    $args=$line1[0];
    my $nb1=$#line1;
    if ($nb1 > 0)
    {
	my $vars = $line1[1];
	$vars =~ s/^ +//g;
	$vars =~ s/ +$//g;
	my @line = split(/ /,$vars);
	my $nb=$#line;
	for(my $i=0;$i <=$nb;$i++)
	{
	    my @var=split(/=/,$line[$i]);
	    $ENV{$var[0]} = $var[1];
	    #print "VG ==> ($i) $line[$i] || $var[0] = $var[1]\n";
	}
    }
    system(". $myDir/startEnv.sh $dirBase; env | sort -u > ${dir}/${appname}.${jobId}" );
    exec(". $myDir/startEnv.sh $dirBase;exec $appname $args >> ${dir}/${logfile} 2>&1" );
    die "unable to exec: $!";
}

unless(-d $piddir)
{
    system("mkdir -p $piddir");
}
open(PF, "> $piddir/$pidfile");
print PF "$pid\n";
close(PF);

