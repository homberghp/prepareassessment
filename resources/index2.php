<?php
include_once 'settings.php';
include_once '/usr/local/prepareassessment/resources/setdb.php';
$remoteUser= $_SERVER['PHP_AUTH_USER'];
$sql = "select count(*) as is_tutor from tutor_pw where username='$remoteUser'";
$resultSet = $dbConn->Execute( $sql );
$isTutor = ($resultSet->fields['is_tutor'] != 0);
$remoteAddress=$_SERVER['REMOTE_ADDR'];
function getTable( $dbConn, $exam_id, $event ) {
  global $remoteUser;
    global $isTutor;
    $tablist = "\n\t<ul>\n";

    $tabs = "<div id='tabs'>\n";
    $repos_root = '/examsvn/' . $exam_id . '/';
    $server_name = 'osirix.fontysvenlo.org';
    $server_url = 'https://' . $server_name;
    $myFile = "svn_repos.txt";
    $lines = file( $myFile );
    $count = 0;
    $map = array( );
    $map2 = array( );
    $maxyoungest = 0;
    $youngest = 0;
        $extraConstraint = $isTutor?"\n":" and username = '$remoteUser'\n";
    $sql = "select distinct username,lastname||', '||firstname||coalesce(' '||tussenvoegsel,'') as name,"
      . "reposroot as repos,examroom,reposuri,active, \n"
      . "youngest,youngestdate,sticknr,"
      . "case when age(last_call_time) < '2 minutes'::interval then 'active' else 'inactive' end as stick_style\n"
      . "from candidate_repos left join et_lastcall  using(sticknr) where event='$event' \n".$extraConstraint
      . "order by examroom,name";
    $resultSet = $dbConn->Execute( $sql );
    if ( $resultSet === null ) {
        die( 'query failed with ' . $dbConn->ErrorMsg() );
    }
    $rowcount = 0;
    $oldRoom = '';
    $divount = 0;
    $red = 164;
    $green = 128;
    $blue = 192;
    while ( !$resultSet->EOF ) {
        $rowcount++;
        $newRoom = ($oldRoom != $resultSet->fields['examroom']);
        extract( $resultSet->fields );
	
        if ( $newRoom ) {
            $red = ($red + 32) % 256;
            $green = ($green + 32) % 256;
            $blue = ($blue + 32) % 256;
            if ( $oldRoom != '' ) {
                $tabs .="\n</table>";
                if ( $isTutor ) {
                    $tabs .="<input type='submit' name='activate' value='Update enable repos'/>"
                            . "<input type='hidden' name='examroom' value='$oldRoom'/>"
                            . "\n</form>\n";
                }
                $tabs .= "</div>";
            }
            $oldRoom = $examroom;
            $divcount++;
            $tablist .="\t\t<li><a href='#tabs-${divcount}'>Room $examroom</a></li>\n";
            $divLabel = "tabs-${divcount}";
            $tabs .= "<div id='${divLabel}'>\n"
                    . "<a name='$divLabel'/>\n"
                    . "<form id='enform' name='enform' action='setactive.php' method='POST'>\n";
            $tabs .= "<table border='1px' style='border-collapse:collapse' width='100%'>"
                    . "<thead>"
                    . "<caption>Here you find a link to your repository and the number of commits you made.</caption>"
                    . "</thead>\n"
                    . "<tr><th colspan='5'>You must use https (ssl or tls) to access the repository.</th></tr>\n"
                    . "<tr><th>Commits</th><th>commit at</th>\n";
            if ( $isTutor ) {
                $tabs .= "<th title='enable/disable all' align='left'><input name='checkAll' "
                        . "type='checkbox' onclick='javascript:checkThem(\"active[]\",this.checked)'/>"
                        . "<input type='submit' name='activate' value='en'/></th>\n";
            }
            $tabs .= "<th>svn url (left click, copy link location)</th>\n"
                    . "<th>Server Address</th><th>Repository server path</th><th>Room</th><th>#</th></tr>\n";
        }
        // $youngest= @`/usr/bin/svnlook youngest $repos`;
        // $youngestDate = @`/usr/bin/svnlook date $repos`;
        $lastCommit = ($youngest > 1) ? substr( $youngestdate, 11, 8 ) : "<span style='font-weight:bold;'>nothing</span>";
        $repos_path = $repos . '/trunk';
        $trunk_url = $server_url . $reposuri;
        $opac = 0.2 + 0.2 * ($rowcount % 2);
        $color = "rgba($red,$green,$blue,$opac)";
        $checked = ($active == 't') ? 'checked' : '';
        $ena = ($active == 't') ? '<span style=\'color:#080\'>is on</span>' : '<span style=\'color:#800\'>is off</span>';
        $tabs .= "\t<tr style='background:$color'>\n"
                . "\t\t<td align='right'>$youngest</td>\n"
                . "\t\t<td align='right'>$lastCommit</td>\n";
        if ( $isTutor ) {
            $tabs .= "\t\t<td ><input type='checkbox' name='active[]' value='$username' $checked/>$ena <span style='font-size:70%' class='{$stick_style}'>[$sticknr]</span></td>\n";
        }
        $tabs .= "\t\t<td><a href='$trunk_url'>$name</a></td><td>$server_name</td><td>$reposuri</td>\n"
                . "\t\t<td>$examroom</td>\n"
                . "\t\t<td align='right'>$rowcount</td>\n"
                . "\t</tr>\n";
        $resultSet->moveNext();
    }
    $tabs .="\n</table>";
    if ( $isTutor ) {
        $tabs .="<input type='submit' name='activate' value='Update enable repos'/>\n"
                . "<input type='hidden' name='examroom' value='$oldRoom'/>"
                . "</form>\n";
    }
    $tabs .= "</div>\n";
    $tablist .="\n\t</ul>\n";
    $result = $tablist . $tabs;
    return $result;
}

#die( "exam_id $exam_id candTable $candTable\n");

$reposTable = getTable( $dbConn, $exam_id, $event );
$cwblink = '';
if ( $isTutor ) {
    $cwblink = "<a href='cwb.php'>CWB</a>";
}
include_once 'index_template.html';
