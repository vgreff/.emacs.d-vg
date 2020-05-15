#!/usr/local/bin/perl

($program) = ($0 =~ /([^\/]*)$/);
die "Usage: ${program} <pattern>\n" if ($#ARGV != 0);
$patn = shift;
foreach $dir (split(/:/, $ENV{'PATH'})) {
    if (opendir(PDIR, $dir))
    {
	while ($_ = readdir(PDIR))
	{
	    $FNAME{"$dir/$_"} = 1 if (/$patn/io);
	}
	closedir(PDIR);
    }
    else
    {
	warn "Unable to read directory: ${dir}\n";
    }
}
print join("\n", sort(keys(%FNAME))), "\n";
