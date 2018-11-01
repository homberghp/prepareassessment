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


if (isSet($_POST['rulesubmit']) && isSet($_POST['question_remark']) && isSet($_POST['quest'])) {
    $q = $quest = $_POST['quest'];
    $stk = $_POST['stick_event_repo_id'];
    $question_remark = htmlentities($_POST['question_remark']);
    $sql = <<<'SQL'
insert into question_remark (event,question,remark) values($1,$2,$3) 
on conflict(event,question) do update set remark=EXCLUDED.remark 
returning *
SQL;
    try {
        $resultSet = $dbConn->Prepare($sql)->execute([$event, $quest, $question_remark]);
    } catch (Exception $ex) {
        die($ex->getMessage());
    }
}
header("Location: " . "cwb.php?stick_event_repo_id={$stk}&quest={$q}");
