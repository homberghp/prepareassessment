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
while(<>){
#    if (m/^examproject\/(.*?\/\w+\.java):.+?\<editor-fold\s+defaultstate=\"expanded\"\s+desc=\"(\w+);\s+MAX\s+(\d+)/){
    if (m/^examproject\/(\w+?\.sql):.+?\<editor-fold\s+defaultstate=\"expanded\"\s+desc=\"(\w+);.+?WEIGHT\s+(\d+)/){
      $filename=$1;
      $question=$2;
      $maxpoints=$3;
  print qq(insert into assessment_questions (event,question,max_points,filepath) select '$event','$question',$maxpoints,'$filename'; \n);
#      print qq(insert into assessment_questions (event,question,max_points,filepathset filepath='$filename' where event='$event' and question='$question'; \n);
    }
}

print qq(insert into assessment_scores (event,question,stick_event_repo_id) 
    select event,question,stick_event_repo_id from stick_event_repo
    join assessment_questions using(event)
      where (event,stick_event_repo_id) not in (select event,stick_event_repo_id from assessment_scores);
commit;
);
