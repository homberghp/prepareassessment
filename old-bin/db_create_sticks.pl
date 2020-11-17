#!/usr/bin/perl -w
# $Id: makerepos.pl 246 2010-06-16 13:15:34Z hom $
# @author p.vandenhombergh@fontys.nl
use strict;
use diagnostics;
use warnings;
use Config::Properties;
use File::Path qw(make_path remove_tree);
use File::Basename;
use POSIX qw(floor);
use POSIX qw(locale_h);
use Cwd;
setlocale(LC_ALL,'en_US.UTF-8');
my $workdir= getcwd;
my $STYPE='EXAM';
my $stype=lc $STYPE;
if ($workdir !~ m/.*(\d{4})(\d{2})(\d{2})$/) {
  die qq(The current directory name does not conform the convention (ISO 8601 8 digit date format).\nPlease correct\n);
}
my  $defexam_date ="$1-$2-$3";
# read properties from parent dir , if available.
my $defproperties = new Config::Properties();

if ( -f '../default.properties') {

  open PROPS, "<../default.properties" or die "unable to open ../default.properties file\n";
  $defproperties->load(*PROPS);
  close(PROPS);
}
my $properties = new Config::Properties(defaults=>$defproperties);

if ( -f 'setup.properties') {
  open PROPS, "<setup.properties" or die "unable to open setup.properties file\n";
  $properties->load(*PROPS);
  close(PROPS);
}

my ($reposdir,$reposuri,$projname,$uname,$salt,$fromdir,$nbprojectxml,$reposurilocal);
my $scriptdir = dirname($0);

## debug: show loaded properties
my %props=$properties->properties;
print STDERR "properties used\n";
foreach my $k (sort keys %props) {
  print STDERR "\t$k => \033[1;32m$props{$k}\033[m\n";
}

# ensure dir
make_path('./paconfig');

my $module_name =$properties->getProperty('module_name','SEN1');
# derive exam date from dir name.

my $examcount=$properties->getProperty('candidate_count',2);
my $stick_id = $properties->getProperty('stick_id',100);
my $exam_date = $properties->getProperty('exam_date',$defexam_date);
my $exam_year = substr($exam_date,0,4);
my $svn_location= $properties->getProperty('svn_location',"/home/${stype}");
my $exam_name = "Performance assessment ${module_name} ${exam_date}";
my $exam_id = $module_name.'-'.$exam_date;
my $app_name = $properties->getProperty('app_name','xxx slot machine');
my $exam_web_dir="/home/examdoc/public_html/${exam_year}/${exam_id}";
my $tutors    = $properties->getProperty('tutors','hom,ode,hee,hvd');
my $local_repos_path=$svn_location.'/'.$exam_id;
my $allowed_from = $properties->getProperty('allowed_from','');
my $extension= $properties->getProperty('extension','c');
$allowed_from =~ s/"//g;
my $noaccess_url = $properties->getProperty('noaccess_url','http://osirix.fontysvenlo.org/noaccess.html');
my $isNetbeansProject = $properties->getProperty('is_netbeans_project',0);
my $resources_dir='/home/prepareassessment/resources';
my $repolist;
my ($sticknr,$projdir);
# if ( $isNetbeansProject != 0 &&  ! -f './project.xml_template' ) {
#   die "\033[41mNeed project.xml_template with examproject dir to populate netbeans project in repos\033[m\n";
# }

#system ('validateProject') == 0 or die "\033[01;41;37mproject not suited for show time, aborting\033[K\033[0m \n\n";

open(SQL,">paconfig/filldb.sql") or die "cannot write to filldb.sql\n";
my $event=$exam_id;
$event =~ s/-//g;
my $sortdate=$exam_date;
$sortdate =~ s/-//g;
my $repos_parent=$local_repos_path.'/svnroot';
my $simpledate=$exam_date;
$simpledate =~ s/-//g;
my $authz_svn_file = $repos_parent.'/conf/authz';
my $site_url=qq(https://osirix.fontysvenlo.org/examdoc/$exam_year/$exam_id/index.php);
my $webdir=qq(/home/examdoc/public_html/$exam_year/$exam_id);
# cleanup from previous run
print SQL qq(-- file created by script, do not modify, it will be overwritten
begin work;
delete  from assessment_scores where event='$event';
delete  from assessment_questions where event='$event';
delete  from assessment_events where event='$event';
insert into assessment_events (event) select '$event';
delete from candidate_stick where stick_event_repo_id  in (select stick_event_repo_id from stick_event_repo where event='$event');
delete from stick_event_repo  where event='$event';
insert into event select '$event','$exam_date' where not exists (select 1 from event where event='$event');
);

my $stickcount=0;
print SQL qq(prepare new_repo(text,int) as
	insert into  stick_event_repo (event,stick_nr) values (\$1,\$2);
);
while ($stickcount < $examcount) {
  $sticknr = $stick_id+$stickcount;
  $uname = $STYPE.$sticknr;
  $fromdir=$local_repos_path.'/tmp/'.$uname;
  $projname=$module_name.'_'.$simpledate.'_'.$uname;
  $projname =~ s/ /_/g;
  $reposdir=qq(/home/${stype}/${uname}-repo);
  $reposurilocal='file://'.$reposdir;
  $reposuri = '/examsvn/'.$exam_id.'/'.$uname;
  $projdir=qq(/home/${stype}/Desktop/examproject-${uname}/);		#.'/'.$projname;
  $nbprojectxml=$projdir.'/nbproject/project.xml';
  $repolist .= qq($reposurilocal\n);
  #  dir to dir copy; target created  by cp
  print SQL qq(execute new_repo('$event',$sticknr);\n);
  $stickcount++;
}
# process questions by filtering by tag.
open(STREAM,"grep -r  STUDENT_ID  examproject|") or die qq(cannot open stream from examproject/*\n);
my ($filepart,$tagpart,$question,$maxpoints,$filename);
print SQL qq(prepare new_question(text,varchar(40),int,text) as
	insert into assessment_questions (event,question,max_points,filepath) values(\$1,\$2,\$3,\$4);
);
while(<STREAM>){
    chomp;
    ($filepart,$tagpart) = split/:\s*/;
     if ($tagpart =~ m/.*?[\<\-]editor-fold\s+defaultstate=\"expanded\" desc=\"(\w+);.+?WEIGHT\s+(\d+)/){
      $question=$1;
      $maxpoints=$2;
      $filename=$filepart;
      $filename =~ s/.*?examproject\///;
      print SQL qq(execute new_question ('$event','$question',$maxpoints,'$filename'); \n);
    }
}
close(STREAM);
print SQL qq(insert into assessment_scores (event,question,update_ts,stick_event_repo_id) 
    select event,question,null, stick_event_repo_id from stick_event_repo 
    join assessment_questions using(event)
      where event='$event' 
        and (event,stick_event_repo_id) 
        not in (select event,stick_event_repo_id from assessment_scores);
commit;
);
close(SQL);
print STDERR qq(Wrote paconfig/filldb.sql\n);

open(APACHECONF,">paconfig/$exam_id.conf") or die "cannot open apache conf file\n";
print APACHECONF qq(
##v tag line identifies exam site.
## examsite;$sortdate;$exam_name;$site_url

Use ExamSite $exam_year $exam_id $event
);
close(APACHECONF);
print STDERR qq(Wrote paconfig/$exam_id.conf\n);

open(SETTINGSPHP,">paconfig/settings.php") or die "cannot open php settings file settings.php for write\n";
print SETTINGSPHP qq(<?php
\$title='Progress performance assessment ${module_name} ${exam_date}';
\$h1Title=\$title;
\$javadocDir='./api';
\$javadocTitle='$app_name';
\$exam_id='$exam_id';
\$exam_year='$exam_year';
\$event='$event';
\$catMap = array(1=>'T');
);
close(SETTINGSPHP);
print STDERR qq(Wrote paconfig/settings.php\n);
open(DOITA,">paconfig/doitconfig.sh") or die "cannot open file doitconfig.sh,\n";
print DOITA qq(#/bin/bash
connectsticks > paconfig/connectsticks.sql
cat paconfig/filldb.sql | psql -X sebiassessment
cat paconfig/connectsticks.sql | psql -X sebiassessment
ln -sf /home/prepareassessment/resources/{cwb,index2,left,process,processrules,getfile,resultmail,results,setactive,top,wb}.php ${webdir}
ln -sf /home/prepareassessment/resources/{images,js,css} ${webdir}
cp paconfig/settings.php ${webdir}
cd /etc/apache2/sslsites-enabled
);
close(DOITA);
print STDERR qq(Wrote \033\[32mpaconfig/doitconfig.sh\033\[0m, run with \033\[34mnormal user\033\[0m \n);

open(DOITB,">paconfig/doitapache.sh") or die "cannot open file doitapache.sh,\n";

print DOITB qq(#/bin/bash
cp paconfig/$exam_id.conf /etc/apache2/sslsites-available
cd /etc/apache2/sslsites-enabled
ln -sf ../sslsites-available/$exam_id.conf .
service apache2 restart
);
close(DOITB);

print STDERR qq(Wrote \033[32mpaconfig/doitapache.sh\033[0m, run with \033[31msudo\033[0m \n);


#EOF
