<?php
include_once 'settings.php';
include_once '/usr/local/prepareassessment/resources/setdb.php';
require_once 'simplequerytable.inc';
require_once 'SpreadSheetWriter.php';
$spreadSheetWriter= array();

/**
 * return a div with widget and table.
 */
function score_by_category($event,$category,$tweight){
  global $dbConn;
  global $catMap;
  global $spreadSheetWriter;
  $tabHead="<div style='margin:1em;font-size:10pt'><table border='1' style='border-collapse:collapse'>\n<thead><tr><th>Task</th>";
  $weightsRow="\n<tr><th>Weight</th>";
  $tab='<table>';
  $weights=array();
  $sql ="select question,max_points as weight from assessment_questions where event='{$event}' and category='{$category}' order by question";
  $resultSet = $dbConn->Execute( $sql );
  if ( $resultSet === null ) {
    die( "query '{$sql}' failed with " . $dbConn->ErrorMsg() . "\n" );
  }
  $weightSum =0;
  for(;!$resultSet->EOF; $resultSet->moveNext()){
    $tabHead .="<th>{$resultSet->fields['question']}</th>";
    $weightsRow .="<td align='right'>{$resultSet->fields['weight']}</td>";
    $weightSum += $resultSet->fields['weight'];
    $weights[] =  $resultSet->fields['weight'];
  }
  $tabHead .="<th>WeightSum</th>";
  $weightsRow.="<td align='right'>{$weightSum}</td>";
  $tabHead .="</tr></thead>\n{$weightsRow}</tr>\n</table>\n</div>";
  $sql = "select assessment_score_query3('{$event}','{$category}') as query";
  $resultSet = $dbConn->Execute( $sql );
  if ( $resultSet === null ) {
    die( "query '{$sql}' failed with " . $dbConn->ErrorMsg() . "\n" );
  }
//echo "{$resultSet->fields['query']}<br/>";
  $query = "select s.snummer,s.achternaam,s.roepnaam,s.voorvoegsel,trim(email1) as email,s.cohort,ct.*,round(fs.weighted_sum/{$tweight},1) as final \n"
    ." from {$resultSet->fields['query']}\n"
    /* ." join candidate_stick cs using(stick_event_repo_id)\n" */
    /* ." join stick_event_repo using(stick_event_repo_id)\n" */
    ." join student s using(snummer) \n"
    ." join assessment_final_score3 fs using(stick_event_repo_id) where category='{$category}' order by s.achternaam,s.roepnaam";

  $resultSet = $dbConn->Execute( $query );
  if ( $resultSet === null ) {
    die( "query '$query' failed with " . $dbConn->ErrorMsg() . "\n" );
  }
  $res = "<table border=1 style='border-collapse:collapse'>\n";
  $firstWeightColumn =9;
  $weightSumColumn=$firstWeightColumn+count($weights);
  while ( !$resultSet->EOF ) {
    
    $res .= '<tr><td>' . join( '</td><td>', $resultSet->fields ) . "</td></tr>\n";
    $resultSet->moveNext();
  }
  $res .="\n</table>";
  //$query="select * from assessment_results where event='$event'";
  $tab = $tabHead.simpleTableString( $dbConn, $query,"<table id='myTable-{$category}' name='myTable-{$category}' "
			    ."class='tablesorter' summary='simple table' style='empty-cells:show;border-collapse:collapse' border='1'>" );
  $resultSet = $dbConn->Execute( $query );
  $spreadSheetWriter[$category] = new SpreadSheetWriter( $dbConn, $query );
  $fileName = "{$event}-{$catMap[$category]}";
  $spreadSheetWriter[$category]->setTitle("Result for ".$event." part {$catMap[$category]}")
    ->setName('spreadsheetwriter_'.$category)
    ->setLinkUrl("https://osirix.fontysvenlo.org")
    ->setWeights($weights)
    ->setFirstWeightsColumn($firstWeightColumn)
    ->setWeightSumsColumn($weightSumColumn)
    ->setFilename(  $fileName )
    ->setAutoZebra(true);
  // when the previous method returns, render the page.
  $spreadSheetWidget[$category] = $spreadSheetWriter[$category]->getWidget();
  return "<form id='form{$category}' action='results.php' method='get' >\n"
    ."<input type='hidden' name='category' value='{$category}'/>{$spreadSheetWidget[$category]}</form>\n"
    ."{$tab}\n";
} // end function

// sum weight
$sql ="select sum(max_points) as tweight,category from assessment_questions where event='{$event}' group by category";
$resultSet = $dbConn->Execute( $sql );
//echo $sql;
$divs='';
$tabs='';
$headScript='';
$categries=array();
while(!$resultSet->EOF) {
  $tweight=$resultSet->fields['tweight'];
  $category =$resultSet->fields['category'];
  $categories[] = $category;
  //  echo "{$event} and {$category}<br/>";
  $divs .= "<div id='tabs-{$category}'>".score_by_category($event,$category,$tweight)."</div>\n<!-- end tabs-{$category}-->\n";
  $tabs .= "\t\t<li><a href='#tabs-{$category}'>Part {$catMap[$category]}</a></li>\n";
  $headScripts .= '
  $(document).ready(function() {
      $("#myTable-'.$category.'").tablesorter({widgets: ["zebra"]});
    });
';
  $resultSet->moveNext();
}
// either return a file and exit or...
foreach ($categories as $category) {
  $spreadSheetWriter[$category]->processRequest();
}

$tabs .="\t</ul>\n";
?>
<!DOCTYPE html>
<html>
    <head>
        <title>performance assessment result for event <?=$event?></title>
    <link type="text/css" href="/examdoc/css/pepper-grinder/jquery-ui-1.8.17.custom.css" rel="stylesheet" />
    <script type="text/javascript" src="/examdoc/js/jquery-1.7.1.min.js"></script>
    <script type="text/javascript" src="/examdoc/js/jquery-ui-1.8.17.custom.min.js"></script>
    <script src="/examdoc/js/jquery.tablesorter.min.js"></script>
  <style type='text/css'>
  .num {text-align:right;}
  </style>
  <script type="text/javascript">
    <?=$headScripts?>
$(function() {
    $( "#tabs" ).tabs();
  });

</script>
    <link rel='stylesheet' type='text/css' href='/examdoc/css/tablesorterstyle.css'/>
</head>
    <body style='margin:.5em; font-family:verdana'>
        <h3>Scores for event <?=$title?>  or back to <a href='cwb.php'>CWB</a></h3>
<div id='tabs'><ul>
  <?=$tabs?>
  <?=$divs?>
</div> <!-- end tabs -->
  <a href='cwb.php'>CWB</a>
    </body>
</html>

