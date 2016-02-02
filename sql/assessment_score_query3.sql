begin work;
drop function if exists assessment_score_query3(text,char(1));
create function assessment_score_query3( myevent text, mycategory char(1)) returns text
as $assessment_score_query3$
declare
  th text;
begin
  select array_agg('q'||question||' numeric') into strict th 
  from (select question from assessment_questions where event=myevent and category=mycategory order by question) qq;
  th := 'crosstab(
  ''select snummer, stick_nr,stick_event_repo_id,question,score 
  from stick_event_repo car 
  join assessment_scores assc using(event,stick_event_repo_id)
  join assessment_questions qst using(event,question)
  join candidate_stick cs using(stick_event_repo_id)
  join student using(snummer)
  where car.event='''''||myevent||''''' and qst.category='''''||mycategory||''''' order by stick_nr,question'',
  ''select question from assessment_questions aqs where aqs.event='''''||myevent||''''' and aqs.category='''''||mycategory||''''' order by question''
  ) as ct(snummer integer,stick_nr integer,stick_event_repo_id integer,'||regexp_replace(th,'[}"{]','','g')||') ';
  return th;
end; $assessment_score_query3$ 
language 'plpgsql';
\a
select * from assessment_score_query3('STA120160129','1');
commit;