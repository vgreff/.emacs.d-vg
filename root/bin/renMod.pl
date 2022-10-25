#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);

my $nbArgs= @ARGV;

die "Usage: $0 SrcName DestName * \n" if $nbArgs < 3;

# print Dumper \@ARGV;

my $SrcName = shift;
$SrcName = ucfirst($SrcName);
my $srcName = lcfirst($SrcName);
my $SRCNAME = uc($SrcName);

my $DstName = shift;
$DstName = ucfirst($DstName);
my $dstName = lcfirst($DstName);
my $DSTNAME = uc($DstName);


# printf("src=$srcName $SrcName $SRCNAME\n");
# printf("src=$dstName $DstName $DSTNAME\n");

printf("@ARGV\n");
print Dumper \@ARGV;

my $cmd;

foreach my $f (@ARGV)
{
    $cmd = sprintf("perl -i -ape 's/$SrcName/$DstName/g' $f");
    # printf("$cmd\n");
    `$cmd`;
    $cmd = sprintf("perl -i -ape 's/$srcName/$dstName/g' $f");
    # printf("$cmd\n");
    `$cmd`;
    $cmd = sprintf("perl -i -ape 's/$SRCNAME/$DSTNAME/g' $f");
    # printf("$cmd\n");
    `$cmd`;
    printf("Substituting in $f\n");
}

$cmd = sprintf("rename 's/$SrcName/$DstName/g' @ARGV");
printf("$cmd\n");
`$cmd`;
`ls -l`;

