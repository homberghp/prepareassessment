<?php
$sess = session_start() ? 'session started' : 'session failed';
if (!isset($_SERVER['PHP_AUTH_USER'])) {
  header('WWW-Authenticate: Basic realm="SEBI Venlo Performance Assessment Correctors Work Bench"');
  header('HTTP/1.0 401 Unauthorized');
  echo 'You should authenticate yourselves';
  exit;
}
else {
  $_SESSION['operator']=$_SERVER['PHP_AUTH_USER']; 
}
include_once 'settings.php';
include_once '/usr/local/prepareassessment/resources/setdb.php';
require_once 'simplequerytable.inc';
require_once 'SpreadSheetWriter.php';

$sql ="select question,max_points,description,filepath,category,remark \n"
  ." from assessment_questions left join question_remark using(event,question)\n".
  "where event='{$event}' order by question";
$resultSet = $dbConn->Execute( $sql );
if ( $resultSet === null ) {
  die( "query '{$sql}' failed with " . $dbConn->ErrorMsg() . "\n" );
}
$table='';
if (!$resultSet->EOF) {
/* $table=simpleTableString( $dbConn, $sql,"<table id='questionTable' name='questionTable' " */
/* 			  ."class='tablesorter' summary='simple table' style='empty-cells:show;border-collapse:collapse' border='1'>" ); */
$table="<table id='questionTable' name='questionTable' 
  class='tablesorter' summary='simple table' style='empty-cells:show;border-collapse:collapse' border='1'>
  <tr><th>Question</th><th>maxpoints</th><th>Description</th><th>Category</th><th>Correctors remarks</th></tr>";
for (;!$resultSet->EOF; $resultSet->moveNext()){

  $table .="
   <tr><td>{$resultSet->fields['question']}</td>
       <td>{$resultSet->fields['max_points']}</td>
       <td><textarea>{$resultSet->fields['description']}</textarea></td>
       <td>{$resultSet->fields['category']}</td>
       <td><textarea>{$resultSet->fields['remark']}</textarea></td>
";
}
}

require_once 'config.html';
