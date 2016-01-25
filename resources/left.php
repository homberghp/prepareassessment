<?php
function leftMenu($dbConn,$event,$quest,$stick){
  $sql = "select 'EXAM'||stick_nr as cand,stick_nr as nsticknr,"
    ." coalesce(score,0.0) as score,round(summed_score/weight_sum,1) as grade,\n"
    ." case when ac.remark notnull and ac.remark <>'' then 'R'::text else ''::text end as has_remark,"
    ." ac.remark,stick_nr as stk,stick_event_repo_id,operator\n"
    ."from stick_event_repo ser\n"
    ." join assessment_scores ac using(stick_event_repo_id,event) \n"
    ." join stick_grade_sum using(stick_event_repo_id) \n"
    ."join assessment_weight_sum using(event)\n"
    ."where ser.event='{$event}' "
    ."and question='{$quest}' and youngest notnull order by stick_nr";
  //  select *,round(summed_score/weight_sum,1) as final from stick_grade_sum natural join stick_event_repo join assessment_weight_sum using(event)  where event='DBS120150126';

  $resultSet = $dbConn->Execute( $sql );
  if ( $resultSet === false ) {
    die( "query <pre>'$sql'</pre> failed with " . $dbConn->ErrorMsg() );
  }
  $out = '';
  $left_idx=0;
  while ( !$resultSet->EOF ) {
    extract( $resultSet->fields );
    if ( $stick == $stick_event_repo_id ) {
      $style = 'background:#fff;font-weight:bold;';
    } else
      if ( $score > 6.0 ) {
        $style = 'background:#afa;';
      } else if ( $score >= 1.0 ) {
        $style = 'background:#faa;';
      } else {
        $style = 'background:#bbb;';
      }
    $gradestyle = 'font-weight:bold;';
    if ( $grade < 5.5 ) {
      $gradestyle .='color:c00;';
    }
    $remark_title ='';
    if ($remark && $remark !== '') {
      $remark_title =" title='{$remark}' style='background:white' class='pulse1'";
    }
    $snip=$_SESSION['snippets'];
    $out .= "<tr style='$style'><td align='right' style='width:3em' title='{$operator}'>{$score}</td>"
      . "<td><a href='cwb.php?stick_event_repo_id={$stick_event_repo_id}&quest={$quest}&snippets={$snip}'>" 
      //         .   "$lastname, $firstname ($username)</a></td><th {$remark_title}>{$has_remark}</th><td style='$gradestyle'>{$grade}</td></tr>\n";
      ."{$cand}</a>({$stick_event_repo_id})</td><th {$remark_title}>{$has_remark}</th><td style='$gradestyle'>{$grade}</td></tr>\n";
    $resultSet->moveNext();
    $left_idx++;
  } return $out;
}
$table=leftMenu($dbConn,$event,$quest,$stick_event_repo_id);

?>
<table style='border-collapse: collapse; font-family:verdana;font-size:10pt;' border='1' width="220px">
  <caption>Corrector: <?=$_SERVER['PHP_AUTH_USER']?></caption>
    <tr><th><?=$quest?></th><th>USB Stick</th><th>R</th><th>fin</th></tr>
    <?= $table ?>
</table>
