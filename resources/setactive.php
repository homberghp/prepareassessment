<?php
include_once 'settings.php';
include_once '/usr/local/prepareassessment/resources/setdb.php';
if (isSet($_POST['activate'])){
  $examroom=$_POST['examroom'];
  $sql = "begin work;\n"
    ."update candidate_repos set active = false where event='$event' and examroom='$examroom';\n";
  if (isSet($_POST['active'])){
      $active = $_POST['active'];
      $active = '\'' . implode( "','", $active ) . '\'';
      $sql .= "update  candidate_repos set active = true where event='$event' and username in ($active);\n";
  }
  $sql .= "commit;\n";
  $dbConn->Execute($sql);
  
 }
header("Location: index.php");
?>