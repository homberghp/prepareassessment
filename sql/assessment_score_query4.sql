begin work;
drop function if exists assessment_score_def(text,char(1));
drop function if exists assessment_column_names(text,char(1));
drop function if exists assessment_score_query4(text,char(1));

create or replace function assessment_score_def (myevent text, mycategory char(1)) returns text
as $assessment_score_def$
declare 
th text;
begin
  select array_agg('q'||question||' numeric') into strict th 
  from (select question from assessment_questions where event=myevent and category=mycategory order by question) qq;
  return 'snummer integer,stick_nr integer,stick_event_repo_id integer,'||regexp_replace(th,'[}"{]','','g');
end;
$assessment_score_def$ language 'plpgsql';

create or replace function assessment_column_names (myevent text, mycategory char(1)) returns text
as $assessment_score_def$
declare 
-- note thate snummer collumn is dropped, it would be duplicated in output.
th text;
begin
  select array_agg('ct.q'||question) into strict th 
  from (select question from assessment_questions where event=myevent and category=mycategory order by question) qq;
  return 'ct.stick_nr,ct.stick_event_repo_id,'||regexp_replace(th,'[}"{]','','g');
end;
$assessment_score_def$ language 'plpgsql';

create or replace function assessment_score_query4( myevent text, mycategory char(1)) returns text
as $assessment_score_query4$
declare
  th1 text;
  th2 text;
begin
  th1 := assessment_score_def (myevent,mycategory);
  -- select array_agg('q'||question||' numeric') into strict th 
  -- from (select question from assessment_questions where event=myevent and category=mycategory order by question) qq;
  -- raise notice 'th=%',th;
  
  th2 := 'crosstab(
  ''select snummer, stick_nr,stick_event_repo_id,question,score 
  from stick_event_repo car 
  join assessment_scores assc using(event,stick_event_repo_id)
  join assessment_questions qst using(event,question)
  join candidate_stick cs using(stick_event_repo_id)
  where car.event='''''||myevent||''''' and qst.category='''''||mycategory||''''' order by stick_nr,question'',
  ''select question from assessment_questions aqs where aqs.event='''''||myevent||''''' and aqs.category='''''||mycategory||''''' order by question''
  ) as ct('||th1||') ';
  return th2;
end; $assessment_score_query4$ 
language 'plpgsql';
\a
select * from assessment_score_def('STA120180115','1') ;
select * from assessment_score_query4('STA120180115','1') ;

commit;


