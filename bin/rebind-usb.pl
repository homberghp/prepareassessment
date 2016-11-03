#!/usr/bin/perl -w
use strict;
use warnings;
my ($dev,$mp1, $partition,$mp2,$nmp2, $nmp3, $stick,%devhash,%roothash,%mphash,@parts,@cmd,$casperfile,$root,$rootmp,$partition2,$caspermp,$partition1,$homemp);
my $first='d';
my $last='q';
open(PROC, qq(cat /proc/mounts | grep -e "^/dev/sd[d-q]"|)) or die qq(cannot read mounts\n) ;
while(<PROC>) {
    chomp;
    #  assume devices found are mounted under /media/hom/XXXXyyy
    (@parts) = split/\s+/;
    if ($parts[0] =~ /(\/dev\/sd[c-p])(.)/) {
	$dev=$1;
	$mp1=$parts[1];
	$partition=$2;
	$stick=$mp1;
	$stick =~ s/\/media\/hom\///;
	print qq($dev has on $mp1 $partition stick  $stick\n);
	$devhash{$dev} = $stick;
	$roothash{$dev} = $mp1;
    }
}
foreach my $dev (sort keys %devhash) {
    $stick=$devhash{$dev};
    $partition1 = qq(${dev}1);
    $partition2 = qq(${dev}2);
    $root= $roothash{$dev};
    $rootmp=qq(/media/usb/${stick});
    $homemp=qq(/media/usb/home-rw-${stick});
    $caspermp=qq(/media/usb/casper-rw-${stick});
    $casperfile=qq($rootmp/casper-rw);
    print qq($dev => $devhash{$dev}, mounted on $roothash{$dev} \n);
    print qq(\tmount $partition1 to $rootmp (moved)
\tmount $partition2 to $homemp
\tmount $rootmp/casper-rw $caspermp (loopback)
);
    # mount point to use under usb
    print qq(mkdir --parent $rootmp,$homemp,$caspermp\n);
    @cmd=('mkdir', '--parents', $rootmp,$homemp,$caspermp );
    system(@cmd) == 0 or die "system @cmd failed $?\n";
    # mount point for casper (root) file
    print qq(mount --move $root $rootmp\n);
    @cmd=('mount','--move', $root, $rootmp);
    system(@cmd) == 0 or die "system @cmd failed $?\n";
    print qq(mount  $partition2 $homemp\n);
    @cmd=('mount' , $partition2, $homemp);
    system(@cmd) == 0 or die "system @cmd failed $?\n";
    print qq(mount  -o loop $casperfile $caspermp\n);
    @cmd=('mount','-o','loop',$casperfile,$caspermp);
    system(@cmd) == 0 or die "system @cmd failed $?\n";
}
exit(0);

