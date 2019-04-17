<?php

session_start();
if (!isset($_SERVER['PHP_AUTH_USER'])) {
    header('WWW-Authenticate: Basic realm="SEBI Venlo Performance Assessment Correctors Work Bench"');
    header('HTTP/1.0 401 Unauthorized');
    echo 'You should authenticate yourselves';
    exit;
}

include_once 'settings.php';
include_once '/usr/local/prepareassessment/resources/setdb.php';
$kilroy = '--';
if (isSet($_POST['submit']) && isSet($_POST['stick_event_repo_id']) && isSet($_POST['quest']) && isSet($_POST['score'])) {
    $score = $_POST['score'];
    $quest = $_POST['quest'];
    $stick_event_repo_id = $_POST['stick_event_repo_id'];
    $remark = htmlentities($_POST['remark']);
    $operator = $_SERVER['PHP_AUTH_USER'];
    $sql = <<<'SQL'
update assessment_scores set score = $1,
operator=$2,remark=$3,update_ts=now()
where stick_event_repo_id=$4 and question=$5
SQL;
    $nsql = <<<'NSQL'
select min(question||':'||stick_event_repo_id) as next_qs from assessment_scores 
    join candidate_stick using(stick_event_repo_id)
where event=$1 and question||':'||stick_event_repo_id > $2
NSQL;

    try {
        $stkq = "{$quest}:{$stick_event_repo_id}";
        $resultSet = $dbConn->Prepare($sql)->execute([$score, $operator, $remark, $stick_event_repo_id, $quest]);
        $resultSet = $dbConn->Prepare($nsql)->execute([$event, $stkq]);
        if (!$resultSet->EOF) {
            list($q, $stk) = explode(':', $resultSet->fields['next_qs']);
            $_SESSION['quest'] = $q;
            $_SESSION['stick_event_repo_id'] = $stk;
            $_SESSION['next_qs'] = $resultSet->fields['next_qs'];
        }
    } catch (Exception $ex) {
        echo("query failed with " . $dbConn->ErrorMsg());
    }
}

header("Location: " . "cwb.php?stick_event_repo_id={$stk}&quest={$q}");
