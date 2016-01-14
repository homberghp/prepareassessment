#!/usr/bin/perl

# this script collects student results from a set of files into one comma separated file.
my ($snummer,$passwd,$uid,$gid,$lname,$fname,$infix,@dummy,$points);
# the maps
my (%collect,%names);
# read record
open(RECORDS,"<records.csv") or die "something broken, cannot read the records file\n";
while(<RECORDS>){
  chomp;
  ($snummer,$passwd,$uid,$gid,$lname,$fname,$infix,@dummy) = split(/:/);
  $snummer =~ s/x//;
  if ($snummer =~ m/^\d+$/) {
    $collect{$snummer} = ();
    $names{$snummer} = "$lname;$fname;$infix";
  }
}

# foreach $snummer ( keys %collect ) {
#   print "$snummer;$names{$snummer};$collect{$snummer}\n";
# }
my ($filename,@filenames,$question,@questions);
opendir(my $dh, 'harvest') || die "can't opendir harvest $!";
while (readdir($dh)){
    $filename = "harvest/$_";
    $question=$_;
    if ($filename =~ m/.+?\.sql$/) { 
#	print "$filename\n";
	$question =~ s/\.sql//;
	push(@filenames,$filename);
	push(@questions,$question);
    }
}
# my $result='';
# $result = join(';',sort(@filenames));
# print "$result\n";

foreach $filename (sort @filenames){
    open(FILE,"<$filename") or die "cannot open file $filename\n";
    while(<FILE>) {
	chomp;
	if (m/\<EXAM.+?\((\d+)\).+?WEIGHT\s+(\d+)/){
	    $snummer = $1;
	    $points = $2;
	    push(@{$collect{$snummer}},$points);
#	    print "$filename $snummer=> $points collect = @{$collect{$snummer}}\n";
	}
    }
    close(FILE);
}
my $gradelist;
$result = join(';',sort(@questions));
print qq(snummer;lname;fname;infix;$result\n);
foreach $snummer ( keys %collect ) {
    $gradelist= join(';',@{$collect{$snummer}});
  print "$snummer;$names{$snummer};$gradelist\n";
}

closedir $dh;
