#!/usr/bin/perl -w
# $Id: makerepos.pl 246 2010-06-16 13:15:34Z hom $
# @author p.vandenhombergh@fontys.nl
use Config::Properties;
use File::Path qw(make_path remove_tree);
use POSIX qw(floor);
use POSIX qw(locale_h);
use Cwd;
setlocale(LC_ALL,'en_US.UTF-8');
my $workdir= getcwd;
$workdir =~ m/.*(\d{4})(\d{2})(\d{2})$/;
my $defexam_date ="$1-$2-$3";

my ($snummer,$uid,$gid,$name,$anaam,$vl,$rnaam,$vv,$lang,$proj,$projdir,$klas,%setHash);
my ($cohort,$email,$home,$pcn,$shell,$opl,$passwd,$cpasswd);
my ($afko,$pyear,$grp,$examgrp);
my ($student_id,$student_id_tag);

open PROPS, "<./default.properties" or die "unable to open setup file";
if ( -d 'examproject'  && !-f 'project.xml_template' ) {
  die "Need project.xml_template with examproject dir to populate project in repos\n";
}

my $properties = new Config::Properties();
$properties->load(*PROPS);

my $module_name =$properties->getProperty('module_name','SEN1');
my $exam_date = $properties->getProperty('exam_date',$defexam_date);
my $exam_year = substr($exam_date,0,4);
my $svn_location= $properties->getProperty('svn_location','/home/svn').'/'.$exam_year;
my $exam_name = "Performance assessment ${module_name} ${exam_date}";
my $exam_id = $module_name.'-'.$exam_date;
my $app_name = $properties->getProperty('app_name','xxx slot machine');
my $exam_web_dir="/home/examdoc/public_html/${exam_year}/${exam_id}";
my $tutors    = $properties->getProperty('tutors','hom,ode,hee,hvd');
my $local_repos_path=$svn_location.'/'.$exam_id;
my $allowed_from = $properties->getProperty('allowed_from','');
$allowed_from =~ s/"//g;
my $noaccess_url = $properties->getProperty('noaccess_url','http://osirix.fontysvenlo.org/noaccess.html');
my $isNetbeansProject = $properties->getProperty('is_netbeans_project','true');
my $resources_dir='/usr/local/prepareassessment/resources';
my $repolist;

my $site_url=qq(https://osirix.fontysvenlo.org/examdoc/$exam_year/$exam_id/index.php);

my $sql_exam_id=$exam_id;
$sql_exam_id =~ s/-//g;
my $repos_parent=$local_repos_path.'/svnroot';
my $simpledate=$exam_date;
$simpledate =~ s/-//g;
my $authz_svn_file = $repos_parent.'/conf/authz';

print qq(##v tag line identifies exam site.
## examsite;$exam_name;$site_url

AliasMatch ^/examdoc(/.*)?\$ "/home/examdoc/public_html\$1"
<Directory /home/examdoc/public_html/$exam_year/$exam_id>
  Require SSL connection for password protection.
  SSLRequireSSL
  ErrorDocument 403 $noaccess_url
  Order deny,allow
  Deny from all
  Allow From 145.93.27.0/24 145.85.84.0/24 ${allowed_from}

## for database authentication
  AuthType Basic
  AuthName "$exam_name"
  Require valid-user
  AuthBasicProvider dbd
  AuthDBDUserPWQuery  "SELECT password FROM svn_users WHERE username = %s and event in ('tutor','$sql_exam_id')"
## end database authentication
</Directory>

<Location /examsvn/$exam_id>
  DAV svn
  SVNParentPath $local_repos_path
  Require SSL connection for password protection.
  SSLRequireSSL
  ErrorDocument 403 $noaccess_url
  Order deny,allow
  Deny from all
  Allow From 145.93.27.0/24 145.85.84.0/24 ${allowed_from}
  AuthzSVNAccessFile "$authz_svn_file"
  ## for database authentication
  AuthType Basic
  AuthName "$exam_name"
  Require valid-user
  AuthBasicProvider dbd
  AuthDBDUserPWQuery  "SELECT password FROM svn_users WHERE username = %s and event in ('tutor','$sql_exam_id')"
  ## end database authentication
</Location>
);
