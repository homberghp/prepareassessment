#!/usr/bin/perl -w
use strict;
use DBI;
use POSIX qw(floor);;

if ($#ARGV+1 < 2) {
    die "usage: updatepeersvnloop.pl repos rev rdate rtime\n";
}
my $db='assessment';
my $dbuser='wwwrun';
my $dbpasswd='apache4ever';

my $repospath = $ARGV[0];
my $rev = $ARGV[1];
my $rdate = $ARGV[2];
my $rtime = $ARGV[3];

my $dbh= DBI->connect("dbi:Pg:dbname=$db","$dbuser" ,"$dbpasswd");

my $query = "update candidate_repos set youngest = $rev,youngestdate=now()::timestamp where reposroot='$repospath'";

my $sth=$dbh->prepare($query);
$sth->execute();

$dbh->disconnect;
exit(0);
