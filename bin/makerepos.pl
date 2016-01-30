#!/usr/bin/perl -w
# $Id: makerepos.pl 246 2010-06-16 13:15:34Z hom $
# @author p.vandenhombergh@fontys.nl
use strict;
use diagnostics;
use warnings;
use  Config::Properties;
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

# remove old stuff
remove_tree('./paconfig');
make_path('./paconfig');

open PHP_INPUT,">./paconfig/svn_repos.txt" or die "unable to open php input file\n";

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
my $resources_dir='/usr/local/prepareassessment/resources';
my $repolist;
my ($sticknr,$projdir);
# if ( $isNetbeansProject != 0 &&  ! -f './project.xml_template' ) {
#   die "\033[41mNeed project.xml_template with examproject dir to populate netbeans project in repos\033[m\n";
# }

if (! -d './examproject' ) {
  die "Missing exam project directory './examproject' . cannot continue \n";
}
if (! -d './examsolution' ) {
  die "Missing exam solution directory './examsolution' . cannot continue \n";
}
print qq(extension='$extension'\n);
if ($extension eq 'java') {
  symlink ($scriptdir.'/transform_java', 'transform');
} elsif ($extension eq 'sql') {
  symlink ($scriptdir.'/transform_sql', 'transform');
} elsif ($extension eq 'R') {
  symlink ($scriptdir.'/transform_r', 'transform');
} else {
  die "do not yet understand extension $extension\n";
}

system ('validateProject') == 0 or die "\033[01;41;37mproject not suited for show time, aborting\033[K\033[0m \n\n";

open(SETTINGSPHP,">paconfig/settings.php") or die "cannot open php settings file settings.php for write\n";
open(SQL,">paconfig/filldb.sql") or die "cannot write to filldb.sql\n";
#open(SCHEMA,"</usr/local/prepareassessment/resources/exampw.sql") or die "cannot read database schema\n";
#open(TUTPW,"</home/svn/lecturerPass.exam") or die "cannot open tutor password file\n";
my $event=$exam_id;
$event =~ s/-//g;
my $sortdate=$exam_date;
$sortdate =~ s/-//g;
my $repos_parent=$local_repos_path.'/svnroot';
my $simpledate=$exam_date;
$simpledate =~ s/-//g;
my $authz_svn_file = $repos_parent.'/conf/authz';
my $site_url=qq(https://osirix.fontysvenlo.org/examdoc/$exam_year/$exam_id/index.php);
# cleanup from previous run
print SQL qq(
begin work;
delete  from assessment_scores where event='$event';
delete  from assessment_questions where event='$event';
delete  from assessment_events where event='$event';
insert into assessment_events (event) select '$event';
delete from candidate_stick where stick_event_repo_id  in (select stick_event_repo_id from stick_event_repo where event='$event');
delete from stick_event_repo  where event='$event';
insert into event select '$event','$exam_date' where not exists (select 1 from event where event='$event');
);

print SETTINGSPHP qq(<?php
\$title='Progress performance assessment ${module_name} ${exam_date}';
\$h1Title=\$title;
\$javadocDir='./api';
\$javadocTitle='$app_name';
\$exam_id='$exam_id';
\$exam_year='$exam_year';
\$event='$event';
\$catmap = array(1=>'T');
?>
);
my $svn_groups=qq(# This file auto generated. Only change when you know what you are doing
# and acept that your changes will be undone when the creating script is rerun.
#
# This version introduces the 'harvester' user, to be able to collect uncommitted files
# from the usb-sticks. These uncommitted files will be committed by the harvester user
# who has write access to all repos. Not that the svn log will show if harvester did
# any commit on a repo.
# This file is created by makerepos5.pl.
[groups]
tutors=$tutors
);
my $svn_rights=qq(
[svnroot:/]
\@tutors = rw
* =
);

# start the script output
print qq(#!/bin/bash
# This file is autogenerated from exam data
# Do not edit.
# set env, encoding
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8
export LC_CTYPE LANG LC_ALL
umask 002
# Execute this script with root rights as in sudo bash <scriptname>
#
# remove stuff from previous run
rm -fr /home/${stype}/${STYPE}*-repo
rm -fr /home/${stype}/Desktop/examproject-${STYPE}*
# start with repos
#svnadmin create $repos_parent
#cp ${resources_dir}/repos-templates/hooks/post-commit ${repos_parent}/hooks
#chmod a+rx ${repos_parent}/hooks/post-commit
);
print qq(echo in the next few seconds the script creates all repositories using all server cores, so be please be patient.\n);
$repolist='';
my $stickcount=0;
print SQL qq(prepare new_repo(text,int,text,text) as
	insert into  stick_event_repo (event,stick_nr,reposroot,reposuri) values (\$1,\$2,\$3,\$4);
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
  print qq(\t\(\n\t\tmkdir -p $projdir\n);
  $svn_groups .= qq(g$sticknr=$uname\n);
  $svn_rights .= qq([$uname:/]
\@g$sticknr = rw
harvester = rw
\@tutors = r
* =

);
  #  dir to dir copy; target created  by cp
  if ( -d  'examproject' ) {
    print "\t\tcp -r -L examproject/* $projdir\n";
    if ( $isNetbeansProject  ) {
      print qq(\t\tfor i in \$\(find examproject -name project.xml\); do 
		  sed -re "s\@<name>(.*)?</name>\@<name>\\1-$uname</name>\@"  \$\{i\} > $projdir\$\{i/examproject\}
                  done
              );
    }
    if ( -x './transform' ) {
      print qq(./transform $projdir __STUDENT_ID__ '($uname)'\n);
    }
  }
  print qq(\t\tsvnadmin create  $reposdir
    \t\tsvn import -q -m'initial repos struct and project' $projdir $reposurilocal
    \t\trm -fr $projdir
    \t\tsvn co $reposurilocal $projdir
    \t\)&\n);
  print PHP_INPUT qq($uname;$reposdir\n);
  print SQL qq(execute new_repo('$event',$sticknr,'$reposdir','$reposuri');\n);
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
      where (event,stick_event_repo_id) not in (select event,stick_event_repo_id from assessment_scores);
     -- update stick_event_repo set youngest=2 where stick_event_repo_id in 
     -- (select stick_event_repo_id from stick_event_repo join candidate_stick using(stick_event_repo_id) where event='$event');
commit;
);
close(SQL);
print qq(# wait for svn import childs to complete
wait
echo created all repos
echo -e"\t"            '$repolist'
);

print "cat \<\<EOF \> $authz_svn_file\n";
print $svn_groups;
print $svn_rights;
print "EOF\n";
open(APACHECONF,">paconfig/$exam_id.conf") or die "cannot open apache conf file\n";
print APACHECONF qq(
##v tag line identifies exam site.
## examsite;$sortdate;$exam_name;$site_url

Use ExamSite $exam_year $exam_id $event
);
close(APACHECONF);
close(SETTINGSPHP);
print qq(
# give apache access
#chown -R www-data:www-data $local_repos_path


# (re)create web dir

# remove any old stuff for this exam
rm -fr ${exam_web_dir}
mkdir -p ${exam_web_dir}

#any module/exam specific stuff for the web
test -d ./web &&   cp -r web/* ${exam_web_dir}

# copy template things plus anything from web subdir
cp -f paconfig/settings.php ${exam_web_dir}
ln -sf ${resources_dir}/index2.php ${exam_web_dir}/index.php
ln -sf ${resources_dir}/index_template.html ${exam_web_dir}
ln -sf ${resources_dir}/setactive.php ${exam_web_dir}

# any jars should also be copied and made web accessible
test -d ./jar &&   cp -r jar ${exam_web_dir}

# unzip the api of the jars used.
if [ -f api.zip ] ; then
    mkdir -p ${exam_web_dir}/api
    unzip -d ${exam_web_dir}/api api.zip
fi
#chown -R  \${SUDO_USER} ${exam_web_dir}
chown -R exam:exam /home/exam
export exam_id=${exam_id}
bash ${scriptdir}/tailmanual.txt
);

print STDERR qq(
    # now execute the script you saved (in doit.sh) with:
    sudo bash doit.sh
    # Do not forget to fill the database with:
    cat paconfig/filldb.sql | psql -X assessment

    # copy the config file apache and activate it:
    sudo cp paconfig/$exam_id.conf /etc/apache2/sslsites-available
    sudo ln -sf ../sslsites-available/$exam_id.conf /etc/apache2/sslsites-enabled
    sudo service apache2 reload

    # Once an exam site is visible under /etc/apache2/sites-available
    # it is automatically picked up by the index.php file.
    # so there is no need to edit the exam index file
    # with the your_Editor_Of_Choice /home/examdoc/public_html/index.html
);

#EOF
