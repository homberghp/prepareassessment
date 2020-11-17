#!/usr/bin/perl -w

my $on = 0;
my $count = 1;
while (<>) {
  #    chomp;
  if (! $on &&  m/\<PRE\>/) {
    s/\s*\d+\s+//;
    print;
    $on = 1;
  } elsif ($on &&  m/\<\/PRE\>/) {
    $on = 0;
    s/\s*\d+\s+//;
    print;
  } elsif ( $on ) {
    #print qq( <span class='ln'>$count</span>$_);
    print qq($_);
    $count++;
  }
}
