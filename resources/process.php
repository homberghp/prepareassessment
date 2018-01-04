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
    $remark = pg_escape_string($_POST['remark']);
    $operator = $_SERVER['PHP_AUTH_USER'];
    $sql = "begin work;\n"
            . "update assessment_scores set score = {$score},"
            . "operator='{$operator}',remark='$remark',update_ts=now()\n"
            . " where stick_event_repo_id={$stick_event_repo_id} and question='{$quest}';\n";
    $resultSet = $dbConn->Execute($sql);
    if ($resultSet === null) {
        die("query '$sql' failed with " . $dbConn->ErrorMsg());
    }

    $query = "select min(question||':'||stick_event_repo_id) as next_qs from assessment_scores join candidate_stick using(stick_event_repo_id)\n"
            . "where event='{$event}' and question||':'||stick_event_repo_id > '{$quest}:{$stick_event_repo_id}'";
    try {
        $resultSet = $dbConn->Execute($query);
        if (!$resultSet->EOF) {
            list($q, $stk) = explode(':', $resultSet->fields['next_qs']);
            $_SESSION['quest'] = $q;
            $_SESSION['stick_event_repo_id'] = $stk;
            $_SESSION['next_qs'] = $resultSet->fields['next_qs'];
        }
    } catch (SQLExecuteException $se) {
        die("query '$query' failed with " . $dbConn->ErrorMsg());
    }
}

if (isSet($_POST['rulesubmit']) && isSet($_POST['question_remark']) && isSet($_POST['quest'])) {
    $q = $quest = $_POST['quest'];
    $stk = $_SESSION['stick_event_repo_id'];
    $question_remark = pg_escape_string($_POST['question_remark']);
    $sql = <<<'SQL'
insert into question_remark (event,question,remark) values($1,$2,$3) 
on conflict(event,question) do update set remark=EXCLUDED.remark 
returning *
SQL;
    try {
        $resultSet = $dbConn->Prepare($sql)->execute(array($event, $quest, $question_remark));
    } catch (Exception $ex) {
        die($ex->getMessage());
    }
}
header("Location: " . "cwb.php?stick_event_repo_id={$stk}&quest={$q}");
