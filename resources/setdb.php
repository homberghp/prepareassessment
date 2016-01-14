<?php
$db_name = 'assessment';
$dbUser='wwwrun';
$host = 'localhost';
$proto = 'pgsql';
$pass='apache4ever';

$include_path=ini_get('include_path');
$include_path='/home/hom/peerweb/peer/peerlib/:'.$include_path.':/usr/share/php/PHPExcel/';
$include_path=ini_set('include_path',$include_path);

require_once('peerpgdbconnection.php');

$dbConn = new PeerPGDBConnection($proto);
if (!$dbConn->Connect('localhost', $dbUser, $pass, $db_name)) {
  die("sorry, cannot connect to database $db_name because " . $dbConn->ErrorMsg());
 }

?>