#!/usr/bin/perl -w
use Config::Properties;
use File::Path qw(make_path);
use Cwd;

my $workdir= getcwd;
$workdir =~ m/.*(\d{4})(\d{2})(\d{2})$/;
my $defexam_date ="$1-$2-$3";

open PROPS, "<../default.properties" or die "unable to open setup file";

# if ( -d 'examproject'  && !-f 'project.xml_template' ) {
#   die "Need project.xml_template with examproject dir to populate project in repos\n";
# }

my $properties = new Config::Properties();
$properties->load(*PROPS);
my $module_name =$properties->getProperty('module_name','SEN1');
my $exam_date = $properties->getProperty('exam_date',$defexam_date);
my $exam_year = substr($exam_date,0,4);
my $exam_id = $module_name.'-'.$exam_date;
my $exam_web_dir="/home/examdoc/public_html/${exam_year}/${exam_id}";

my $resources_dir='/usr/local/prepareassessment/resources';
my $event=$exam_id;
$event =~ s/-//g;

my ($question,$maxpoints);
print qq(begin work;
delete  from assessment_scores where event='$event';
delete  from assessment_questions where event='$event';
delete  from assessment_events where event='$event';
insert into assessment_events (event) select '$event';
);
#examproject/FractionTest.java:    //<editor-fold defaultstate="expanded" desc="TASK_B2; __STUDENT_ID__; WEIGHT 10;">
my ($filepart,$tagpart);
while(<>){
    chomp;
    ($filepart,$tagpart) = split/:\s*/;
    # path or package is optional and might not be present, sof filename is first capture, question is 3rd.
#    if (m/^examproject\/((.*?\/)?\w+)\.java:.+?\<editor-fold\s+defaultstate=\"expanded\" desc=\"(\w+);.+?;\sWEIGHT\s+(\d+);\"/){
    # if ($tagpart =~ m/\<editor-fold\s+defaultstate=\"expanded\" desc=\"(\w+);.+?WEIGHT\s+(\d+);\"/){
     if ($tagpart =~ m/.*?[\<\-]editor-fold\s+defaultstate=\"expanded\" desc=\"(\w+);.+?WEIGHT\s+(\d+)/){
      $question=$1;
      $maxpoints=$2;
      $filename=$filepart;
      $filename =~ s/.*?examproject\///;
#      $filename =~s/.java$//;
      print qq(insert into assessment_questions (event,question,max_points,filepath) select '$event','$question',$maxpoints,'$filename'; \n);
#      print qq(insert into assessment_questions (event,question,max_points,filepathset filepath='$filename' where event='$event' and question='$question'; \n);
    }
}
print qq(insert into assessment_scores (event,student,question,update_ts,snummer,stick_event_repo_id) 
    select event,username as student,question,null, snummer,stick_event_repo_id from candidate_repos 
    join assessment_questions using(event)
      where (event,snummer) not in (select event,snummer from assessment_scores);
     update stick_event_repo set youngest=2 where stick_event_repo_id in 
     (select stick_event_repo_id from stick_event_repo join candidate_stick using(stick_event_repo_id) where event='$event');
commit;
);
