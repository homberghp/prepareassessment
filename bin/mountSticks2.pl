#!/usr/bin/perl -w
use File::Temp qw(tempfile tempdir);
my ($p1,$p2,$stick,@parts,$mp1, $mp2,$mp3);
my ($rootmp,$homemp,$caspermp,$casperfile);
my @letters= split//,'defghijklmnopqrstuvwx';
my $cmd=qq(/sbin/blkid);
foreach my $c  (@letters) {
    $cmd .= qq( /dev/sd${c}1);
}
sub doCmd($);
my ($fh,$filename,$template);
$template='mounterXXXX';
($fh,$filename) = tempfile($template,SUFFIX=>'.sh');
print qq($filename\n);
print $fh qq(#!/bin/bash\n);
open(PROC,qq($cmd |)) or die qq(cannot use blkid\n);
while(<PROC>) {
    chomp;
    (@parts)= split/\s+/;
    if ($parts[0] =~ /^\/dev\/(sd.+)?:/ ) {
	$p1=$1;
	$stick=$parts[1];
	$stick =~ m/LABEL="(.+)?"/;
	$stick=$1;
	print qq(dev $p1 $stick\n);
	$p2=$p1;
	$p2 =~ s/1$/2/;

	# make mount points based on label
	$rootmp=qq(/media/usb/${stick});
	$homemp=qq(/media/usb/home-rw-${stick});
	$caspermp=qq(/media/usb/casper-rw-${stick});
	$casperfile=qq($rootmp/casper-rw);
	print $fh qq((mkdir --parents  $rootmp $homemp $caspermp
	mount /dev/${p1} $rootmp
	mount /dev/${p2} $homemp
	mount -o loop $casperfile  $caspermp)&

);
    }
}
print $fh qq(wait # for all children to terminate\n);
close(PROC);
close($fh);
system('/bin/bash', $filename)==0 
    or die qq(cannot execute cmd with status $?\n);
unlink $filename;
exit(0);

