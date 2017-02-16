#!/usr/bin/perl -w
use strict;
use DBI;
use DBD::Pg;
use DBD::Pg qw(:pg_types);
use Config::Properties;
use MIME::Lite;
# use IO::All;
use File::Basename;
use Email::Sender::Simple qw(sendmail);

my ( $row,$snummer, $achternaam, $roepnaam, $to, $stick, $event, $question, $filepath, $weight, $score,$weightedscore,$email);
if ($#ARGV < 1) {
  die qq(Need event and stick\n);
}

$event=$ARGV[0];
$stick=$ARGV[1];

my $dbh= DBI->connect("dbi:Pg:dbname=sebiassessment"); #);
my ($file,$count);
$count=0;
my $query = qq(select snummer, achternaam, roepnaam, email1 as email,stick, event, replace(question,'_','\\_') as question, filepath, weight, score, weight*score as weightedscore
 from event_scores where event='$event' and stick='$stick');

my $sth = $dbh->prepare($query);
$sth->execute( );
$file=$stick.'.tex'; 
open(TEX,">$file ") or die qq(cannot open $file);
if ($row = $sth->fetchrow_arrayref) {
  ( $snummer, $achternaam, $roepnaam, $to, $stick, $event, $question, $filepath, $weight, $score,$weightedscore) = @$row;
  print TEX qq(
\\documentclass[12pt]{article}
\\usepackage[landscape,scale={0.8,0.8}]{geometry}

\\usepackage[usenames,dvipsnames]{xcolor}
\\usepackage{colortbl}
\\definecolor{light-gray}{gray}{0.95}
\\setlength{\\parindent}{0pt}

\\begin{document}

Score report for performance assessment $event, candidate \\\\
{\\large\\bfseries\\sffamily
$snummer, $achternaam, $roepnaam, $stick\n
}

\\vfill
{%\\scriptsize
\\begin{tabular}{|l|l|r|r|r|}\\hline
\\rowcolor{gray}{\\color{white}Question}& {\\color{white}File} & {\\color{white}Weight} & {\\color{white}Score} & {\\color{white}Weighted Score}\\\\\\hline
);
  print TEX qq($question & $filepath &  $weight &  $score & $weightedscore\\\\\\hline\n);

}
while ($row = $sth->fetchrow_arrayref) {
  ( $snummer, $achternaam, $roepnaam, $to,$stick, $event, $question, $filepath, $weight, $score,$weightedscore) = @$row;
  $count++;
  if ($count % 2) {
    print TEX qq(\\rowcolor{light-gray});
  }
  print TEX qq($question & $filepath &  $weight &  $score & $weightedscore\\\\\\hline\n);
}

$query= qq(select sum(weight) as weights ,sum(weight)*10.0 as maxscore,sum(weight*score) 
   as "your weighted score",round(sum(weight*score)/sum(weight),1) as grade,substr(now()::text,1,16) as generated_at from event_scores where event='$event' and stick='$stick');

$sth = $dbh->prepare($query);
my ( $weightsum, $maxscore, $weightscore, $grade,$gen);
$sth->execute( );
while ($row = $sth->fetchrow_arrayref) {
  ( $weightsum, $maxscore, $weightscore, $grade,$gen) = @$row;
  print TEX qq(
& \\textbf{summing up to} & $weightsum & & $weightscore \\\\\\hline
& Maximum achievable score  & & & $maxscore\\\\\\hline
\\rowcolor{light-gray}& \\textbf{Preliminary Grade} &&& \\textbf{$grade}\\\\\\hline
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
`pdflatex -interaction=batchmode $stick`;

my ($message,$subject,$mailbody);
# $to ='p.vandenhombergh@fontys.nl';
$mailbody .=qq(
Dear $roepnaam $achternaam,

Please find attached, the score details of the Java performance assessment $event.
If you have any questions regarding your result, please contact the teacher of your class.
Also notice that your personal java1 repository at fontysvenlo.org contains a pristine copy of your
work.

----

Kind regards, SEBI Venlo Java Teachers.
Richard van den Ham
Geert Monsieur
Pieter van den Hombergh

);

$message = MIME::Lite->new(
		       From => 'p.vandenhombergh@fontys.nl',
		       To => $to,
		       Subject => 'Java 1 Performance assessment score details',
		       Type => 'multipart/mixed',
);
$message->attach(
		 Type => 'TEXT',
		 Data => $mailbody
);
$message->attach(
		 Type  => 'applicateio/pdf',
		 Path  => "$stick.pdf",
		 Filename => "detailed_score_$stick.pdf",
		 Disposition => 'attachment',
);



$message -> send('sendmail','localhost',Debug=>1);



exit(0);

