#!/usr/bin/perl -w
use strict;
use DBI;
use DBD::Pg;
use DBD::Pg qw(:pg_types);

my ( $row,$snummer, $achternaam, $roepnaam, $stick, $event, $question, $filepath, $weight, $score,$weightedscore);
if ($#ARGV < 1) {
    die qq(Need event and stick\n);
}

$event=$ARGV[0];
$stick=$ARGV[1];

my $dbh= DBI->connect("dbi:Pg:dbname=sebiassessment");#);
my ($file);
my $query = qq(select snummer, achternaam, roepnaam, stick, event, replace(question,'_','\\_') as question, filepath, weight, score, weight*score as weightedscore
 from event_scores where event='$event' and stick='$stick');

my $sth = $dbh->prepare($query);
$sth->execute( );
$file=$stick.'.tex'; 
open(TEX,">$file ") or die qq(cannot open $file);
if ($row = $sth->fetchrow_arrayref) {
 ( $snummer, $achternaam, $roepnaam, $stick, $event, $question, $filepath, $weight, $score,$weightedscore) = @$row;
  print TEX qq(
\\documentclass[12pt]{article}
\\usepackage[scale={0.8,0.8}]{geometry}
\\begin{document}
\\centering
score report for performance assessment $event, candidate \\\\
{\\large\\bfseries\\sffamily
$snummer, $achternaam, $roepnaam, $stick\n
}

\\vfill
{\\scriptsize
\\begin{tabular}{|l|l|r|r|r|}\\hline
Question& File & Weight & score & weightedscore\\\\\\hline
);
  print TEX qq($question & $filepath &  $weight &  $score & $weightedscore\\\\\\hline\n);

}
while ($row = $sth->fetchrow_arrayref) {
 ( $snummer, $achternaam, $roepnaam, $stick, $event, $question, $filepath, $weight, $score,$weightedscore) = @$row;
  print TEX qq($question & $filepath &  $weight &  $score & $weightedscore\\\\\\hline\n);
}

$query= qq(select sum(weight) as weights ,sum(weight)*10.0 as maxscore,sum(weight*score) 
   as "your weighted score",round(sum(weight*score)/sum(weight),1) as grade,substr(now()::text,1,16) as generated_at from event_scores where event='$event' and stick='$stick');

$sth = $dbh->prepare($query);
my ( $weightsum, $maxscore, $weightscore, $grade,$gen);
$sth->execute( );
while ($row = $sth->fetchrow_arrayref) {
 ( $weightsum, $maxscore, $weightscore, $grade,$gen) = @$row;
#   print TEX qq(sum of weights = $weightsum\\\\
# maximum achievable score= $maxscore\\\\
# your score= $weightscore\\\\
# your grade = \\textbf{$grade}\\\\
# Report generated at = $gen\\\\

# );
    print TEX qq(
& \\textbf{summing up to} & $weightsum & & $weightscore \\\\\\hline
& Maximum achievable score  & & & $maxscore\\\\\\hline
& \\textbf{Preliminary Grade} &&& \\textbf{$grade}\\\\\\hline
& Report generated at &&& $gen\\\\\\hline
);
}
print TEX qq(\\end{tabular}}
\\vfill

);

print TEX qq(
\\vfill
\\end{document}
);
$dbh->disconnect;

close(TEX);
 `pdflatex $stick`;

exit(0);

