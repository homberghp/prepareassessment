<?php
function remarkTableQuest($dbConn,$event,$quest){
  $sql_remarks="select s.remark,'EXAM'||cr.stick_nr,cr.stick_nr as stk,stick_event_repo_id,question\n"
    ." from assessment_scores s join stick_event_repo cr using(stick_event_repo_id)\n"
    ." where s.event='{$event}' and question='{$quest}' and  remark <>'' order by stk";
  
  $resultSet = $dbConn->Execute( $sql_remarks );
  $remarks="<b>Remarks for question {$quest}</b><br/>";
  if ( $resultSet === false ) {
    die( 'query failed with ' . $dbConn->ErrorMsg() );
  }
  while (!$resultSet->EOF){
    extract( $resultSet->fields );
    $remarks .="<b><a href='cwb.php?stick_event_repo_id={$stick_event_repo_id}&quest={$question}'>EXAM{$stk}</a></b>:\n{$remark}<br/>\n";
    $resultSet->moveNext();
  }
  return $remarks;
}

function remarkTableCand($dbConn,$event,$stick_event_repo_id){
  $sql_remarks="select s.remark,s.question,stick_event_repo_id\n"
    ." from assessment_scores s join stick_event_repo cr using(stick_event_repo_id)\n"
    ." where s.event='{$event}' and cr.stick_event_repo_id='{$stick_event_repo_id}' and  remark <>'' order by s.question";
//  echo $sql_remarks;
  $resultSet = $dbConn->Execute( $sql_remarks );
  $remarks="<b>Remarks for stick_id {$stick_event_repo_id}</b><br/>";
  if ( $resultSet === false ) {
    die( 'query failed with ' . $dbConn->ErrorMsg() );
  }
  while (!$resultSet->EOF){
    extract( $resultSet->fields );
    $remarks .="<b><a href='cwb.php?stick_event_repo_id={$stick_event_repo_id}&quest={$question}'>{$question}</a></b>:\n{$remark}<br/>\n";
    $resultSet->moveNext();
  }
  return $remarks;
}
if ($rremarks) {
  $remarks=remarkTableQuest($dbConn,$event,$quest);
} else {
  $remarks=remarkTableCand($dbConn,$event,$stick_event_repo_id);
}
$sql = "select max_points,score,remark, \n"
        . " aq.filepath,stick_nr,stick_event_repo_id,'EXAM'||stick_nr as cand \n"
        . " from stick_event_repo cr \n"
        . " join  assessment_scores ac using (event,stick_event_repo_id) \n"
        . " join assessment_questions aq on(ac.event = aq.event  and ac.question=aq.question)\n"
        . " where cr.event='{$event}' and aq.question='{$quest}' and stick_event_repo_id='{$stick_event_repo_id}'";

$resultSet = $dbConn->Execute( $sql );
if ( $resultSet === null ) {
    die( 'query failed with ' . $dbConn->ErrorMsg() );
}
extract( $resultSet->fields );
$id = "$cand-$quest";
$fext= substr(strrchr($filepath,'.'),1);
$tasksnippetpath="harvest/snippets/$quest/{$cand}.{$fext}.snippet.html";
$taskpath="harvest/sandbox/EXAM{$stick_nr}/{$filepath}.html";
if ($snippets == 1) {
    $snippetfile = $tasksnippetpath;
} else {
  $snippetfile = $taskpath;
}
$workdir=dirname("harvest/sandbox/EXAM{$stick_nr}/{$filepath}.html");
//echo "<pre>$sql</pre>";
$solsnippetfile = "harvest/solution/{$quest}.{$fext}.snippet.html";
$radio = '';
$cls = 'odd';
for ( $i = 1; $i <= 10; $i++ ) {
    $cls = (($i % 2) == 0) ? 'even' : 'odd';
    $radio .= "\t\t\t<span class='$cls'><label for='rscore-$i'>{$i}.0</label><input type='radio' "
            . "id='rscore-$i' name='score' value='{$i}.0' "
            . "onclick='javascript:setScore({$i}.0);'/></span>\n";
}
$sql= "select remark as question_remark from question_remark where event='{$event}' and question='{$quest}'";
$resultSet = $dbConn->Execute( $sql );
if ( $resultSet === null ) {
    die( 'query failed with ' . $dbConn->ErrorMsg() );
}
$question_remark=$resultSet->fields['question_remark'];

include_once '/usr/local/prepareassessment/resources/wb_html.html';
