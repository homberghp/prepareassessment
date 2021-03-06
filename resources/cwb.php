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
$quest = '';
$cand = '';
if (!isSet($_SESSION['snippets'])) {
  $snippets = $_SESSION['snippets'] = 1;
}
$rremarks=0;
$stick_event_repo_id=0;
if (!isSet($_SESSION['stick_event_repo_id']) || !isSet($_SESSION['quest']) || ! isSet($_SESSION['event']) || $event !== $_SESSION['event']) {
  $sql = "select min(question||':'||stick_event_repo_id) as next_qs from assessment_scores join candidate_stick using(stick_event_repo_id)\n"
      ."where event='{$event}' and question||':'||stick_event_repo_id > '{$quest}:{$stick_event_repo_id}'";
    $resultSet = $dbConn->Execute( $sql );
    if ( $resultSet === null ) {
        die( "query '$sql' failed with " . $dbConn->ErrorMsg() );
    }
    if ( !$resultSet->EOF ) {
      list($q,$stk) = explode( ':', $resultSet->fields['next_qs'] );
      $stick_event_repo_id=$_SESSION['stick_event_repo_id'] = $stk;
      $quest=$_SESSION['quest']=$q;
      $_SESSION['event']=$event;
    }
}
extract( $_SESSION );
if ( isSet( $_REQUEST['quest'] ) && $_REQUEST['quest'] !=='' ) {
    $quest = $_REQUEST['quest'];
}
if ( isSet( $_REQUEST['stick_event_repo_id'] )  && $_REQUEST['stick_event_repo_id']!=='') {
    $stick_event_repo_id = $_REQUEST['stick_event_repo_id'];
}
$snippets = $_SESSION['snippets']; 
if ( isSet($_REQUEST['snippets'] ) ) {
    $snippets =$_SESSION['snippets'] = $_REQUEST['snippets'];
}
if (isSet($_SESSION['rremarks'])){
   $rremarks = $_SESSION['rremarks']; 
}
if ( isSet($_REQUEST['rremarks'] ) ) {
    $rremarks =$_SESSION['rremarks'] = $_REQUEST['rremarks'];
}

$youngest =1;
if ( $quest == '' ) {
    $sql = "select min(question) as quest from assessment_questions where event='$event'";
    $resultSet = $dbConn->Execute( $sql );
    if ( $resultSet === null ) {
        die( "query '$sql' failed with " . $dbConn->ErrorMsg() );
    }
    extract( $resultSet->fields );
    $_SESSION['quest']=$quest;
}

if ( !isSet($stick_event_repo_id) ) {
    $sql = "select min(stick_event_repo_id) as stick_event_repo_id from stick_event_repo where event='{$event}'";
    $resultSet = $dbConn->Execute( $sql );
    if ( $resultSet === null ) {
        die( "query '$sql' failed with " . $dbConn->ErrorMsg() );
    }
    extract( $resultSet->fields );
    $_SESSION['stick_event_repo_id']=$stick_event_repo_id;
}
?>
<!DOCTYPE html>
<html>
    <head>

     <link rel='stylesheet' type='text/css' href='css/style.css'/>
     <link rel='stylesheet' type='text/css' href='css/layout.css'/>
     <link rel='stylesheet' type='text/css' href='css/pulse.css'/>
     <link rel='stylesheet' type='text/css' href='css/buttons.css'/>
        <script language='javascript'>
            function setScore( score ) {
                document.getElementById('score').value=score;
                document.getElementById('points').value=score;
            }
            function setFocus() {
                document.getElementById("score").focus();
            }

        </script>
        <title><?=$event?>&nbsp;CWB Fontys Venlo Corrector&#8217;s work bench</title>
        <meta http-equiv='Window-target' content='top'/>
    </head>
    <body style='padding:0;margin:0' onload='setFocus()' >
	    
<strong><?= $event ?> question <?=$quest?></strong>
        <a href='/'><img src='images/home.png' border=0/>&nbsp;osirix home</a>
        &nbsp;<strong><a href='results.php'>results</a></strong> oper=<?=$_SESSION['operator']?>&nbsp;</strong>
<div id='container'>
<div id='top'>
<?php require_once 'top.php'; ?>
</div><!-- top -->
<div id='left'>
  <?php require_once 'left.php' ?>
</div><!--left-->
    <?php require_once 'wb.php' ?>
</div> <!-- container -->
</body>
</html>
