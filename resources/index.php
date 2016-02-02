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
?>
<!DOCTYPE html>
<html>
    <head>
        <title>Index page for performance assessment for event<?=$event?></title>
</head>
    <body style='margin:.5em; font-family:verdana'>
        <h3>Index performance assessment <?=$event?>  or back to <a href='cwb.php'>CWB</a></h3>
   <ul><li><a href='cwb.php'>correctors workbench</a></li>
   <li><a href='config.php'>config page for this assessment </a></li>
   </ul>
 <?=$table?>
</body>
</html>
