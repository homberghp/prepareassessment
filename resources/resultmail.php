<?php
include_once 'settings.php';
include_once '/usr/local/prepareassessment/resources/setdb.php';
require_once 'simplequerytable.inc';
require_once 'component.inc';
/**
 * same interface as mail, for testing
 */
$mailtail='';
function domail($to, $sub, $msg, $head) {
    global $dbConn;
    global $mailtail;
    mail($to, $sub, $msg, $head);
    $mailtail .= "<pre>\nHEAD:" . htmlentities($head) . "\nRCPT:"
      . htmlentities($to) . "\n\nSubject:$sub\nBody:" 
      . htmlentities($msg) . "\n</pre>\n";
}
/**
 * create a set of headers to send a html/mime email text
 */
function htmlmailheaders($from, $from_name, $to, $cc = '') {
    $msgid = @`date +%Y%m%d%H%M%S`;
    $msgid = rtrim($msgid);
    $msgid .='.@fontysvenlo.org';
    $mailtimestamp = date('D, j M Y H:i:s O'); // Mon, 5 Nov 2007 11:22:33 +0100
    $headers = "From: $from
Reply-To:\"from_name\" <$from>
";
    if ($cc != '')
        $headers = "CC:$cc
";
    $headers = "Content-Type: text/html; charset=\"utf-8\"
Received: from hermes.fontys.nl (145.85.2.2) by fontysvenlo.org (85.214.143.122) with PEERWEB mailer for <$to>; $mailtimestamp
From: \"$from_name\" <$from>
Reply-To: \"$from_name\" <$from>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-Path: " . '<' . "$from" . '>' . "
Message-Id: " . '<' . "$msgid" . '>' . "
";
    return $headers;
}

require_once 'mailFunctions.php';
require_once 'simplequerytable.inc';


$mailsubject = "result to performance assessment \$afko: \$description";
$templatefile = 'templates/resultmailtemplate.html';
// create mailbody
$mailbody = file_get_contents($templatefile, true);
$sender=$replyto = 'Pieter.van.den.Hombergh@fontysvenlo.org';
$sender_name = 'Pieter van den Hombergh';
$signature = '';



$mailbody .= $signature;

if (isSet($_POST['mailbody'])) {
    $mailbody = preg_replace('/"/', '\'', $_POST['mailbody']);
}
if (isSet($_POST['mailsubject'])) {
    $mailsubject = $_POST['mailsubject'];
}
$tabsql = "select *,email as email1,'SEN1' as project,'2013-04-10' as adate,\n"
  ."firstname||coalesce(' '||tussenvoegsel||' ',' ')||lastname as name\n"
  ." from sen1_result_20130410 where final notnull order by lastname";
$rsnames = $dbConn->Execute($tabsql);
$colcount = $rsnames->FieldCount();
$columnNames = array();

for ($i = 0; $i < $colcount; $i++) {
  $field = $rsnames->FetchField($i);
  $columnNames[$i] = $field->name;
}
$availableNames='$'.join(", $",$columnNames);
if (isSet($_POST['invite'])) {
    formMailer($dbConn, $tabsql, $mailsubject, $mailbody, $sender, $sender_name);
}

$page = new PageContainer();
$page->setTitle('Assessment result mailer');
$tab = simpleTableString( $dbConn, $tabsql,"<table id='myTable' name='myTable' class='tablesorter' summary='simple table' style='empty-cells:show;border-collapse:collapse' border='1'>" );

$templatefile = 'templates/resultmailform.html';
$template_text = file_get_contents($templatefile, true);
$text='';
if ($template_text === false) {
    $page->addBodyComponent(new Component("<strong>cannot read template file $templatefile</strong>"));
} else {
    eval("\$text = \"$template_text\";");
    $page->addBodyComponent(new Component($text));
}

$page->addHeadText(
        '<script language="javascript" type="text/javascript" src="/js/tiny_mce/tiny_mce.js"></script>
 <script language="javascript" type="text/javascript">
   tinyMCE.init({
        theme: "advanced",
        /*auto_resize: true,*/
        gecko_spellcheck : true,
        theme_advanced_toolbar_location : "top",
	mode : "textareas", /*editor_selector : "mceEditor",*/

        theme_advanced_styles : "Header 1=header1;Header 2=header2;Header 3=header3;Table Row=tableRow1",
        plugins: "advlink,searchreplace,insertdatetime,table",
	plugin_insertdate_dateFormat : "%Y-%m-%d",
	plugin_insertdate_timeFormat : "%H:%M:%S",
	table_styles : "Header 1=header1;Header 2=header2;Header 3=header3",
	table_cell_styles : "Header 1=header1;Header 2=header2;Header 3=header3;Table Cell=tableCel1",
	table_row_styles : "Header 1=header1;Header 2=header2;Header 3=header3;Table Row=tableRow1",
	table_cell_limit : 100,
	table_row_limit : 5,
	table_col_limit : 5,
	theme_advanced_buttons1_add : "search,replace,insertdate,inserttime,tablecontrols",
/*        theme_advanced_buttons2 : "",
	theme_advanced_buttons3 : ""*/
    });
 </script>
       <script type="text/javascript" src="/examdoc/js/jquery.min.js"></script>
    <script src="/examdoc/js/jquery.tablesorter.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
           $("#myTable").tablesorter({widgets: ["zebra"]});
      });

    </script>
    <link rel="stylesheet" type="text/css" href="/examdoc/css/tablesorterstyle.css"/>

');
$page->addBodyComponent(new Component("<pre>".$mailtail."</pre>"));
$page->show();
?>
