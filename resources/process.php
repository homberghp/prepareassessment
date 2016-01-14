<?php
session_start();
if (!isset($_SERVER['PHP_AUTH_USER'])) {
  header('WWW-Authenticate: Basic realm="My Realm"');
  header('HTTP/1.0 401 Unauthorized');
  echo 'Text to send if user hits Cancel button';
  exit;
}

include_once 'settings.php';
include_once '/usr/local/prepareassessment/resources/setdb.php';
$kilroy='--';
if ( isSet( $_POST['submit'] ) && isSet( $_POST['stick_event_repo_id'] ) && isSet( $_POST['quest']) && isSet( $_POST['score'] )) {
    $score = $_POST['score'];
    $quest = $_POST['quest'];
    $question_remark=$_POST['question_remark'];
    $stick_event_repo_id = $_POST['stick_event_repo_id'];
    $remark = pg_escape_string( $_POST['remark'] );
    $operator = $_SERVER['PHP_AUTH_USER'];
    $sql = "begin work;\n"
      ."update assessment_scores set score = {$score},"
      . "operator='{$operator}',remark='$remark',update_ts=now()\n"
      ." where stick_event_repo_id={$stick_event_repo_id} and question='{$quest}';\n";
    $sql .="insert into question_remark (event,question,remark) select '{$event}','{$quest}','{$question_remark}' \n"
      ." where not exists (select 1 from question_remark where event='{$event}'and question='{$quest}');\n "
      ."update question_remark set remark='{$question_remark}' where event='{$event}'and question='{$quest}';\n"
      ."commit";
    $resultSet = $dbConn->Execute( $sql );
    if ( $resultSet === null ) {
        die( "query '$sql' failed with " . $dbConn->ErrorMsg() );
    }

    $query ="select min(question||':'||stick_event_repo_id) as next_qs from assessment_scores \n"
      ."where event='{$event}' and question||':'||stick_event_repo_id > '{$quest}:{$stick_event_repo_id}'";

    $resultSet = $dbConn->Execute( $query );
    if ( $resultSet === null ) {
        die( "query '$query' failed with " . $dbConn->ErrorMsg() );
    }
    if ( !$resultSet->EOF ) {
        list($q,$stk) = explode( ':', $resultSet->fields['next_qs'] );
        $_SESSION['quest'] = $q;
	$_SESSION['stick_event_repo_id'] = $stk; 
        $_SESSION['next_qs'] =$resultSet->fields['next_qs'];
    }
}
header( "Location: " . "cwb.php?stick_event_repo_id={$stk}&quest={$q}" );
