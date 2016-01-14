begin work;
drop function if exists assessment_score_query2(text);
create function assessment_score_query2( myevent text) returns text
as $assessment_score_query2$
declare
  th text;
begin
  select array_agg('q'||question||' numeric') into strict th from (select question from assessment_questions where event=myevent order by question) qq;
  th := 'crosstab(
  ''select stick_nr,stick_event_repo_id,question,score from stick_event_repo car join assessment_scores assc using(stick_event_repo_id) where car.event='''''||myevent||''''' and youngest > 1 order by snummer,question'',
  ''select question from assessment_questions aqs where aqs.event='''''||myevent||''''' order by question''
  ) as ct(stick_nr integer,stick_event_repo_id integer,'||regexp_replace(th,'[}"{]','','g')||') ';
  return th;
end; $assessment_score_query2$ 
language 'plpgsql';
select * from assessment_score_query2('JAVA220150701');
commit;