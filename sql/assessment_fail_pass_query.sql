begin work;
drop function if exists assessment_pass_fail_def(text);
drop function if exists assessment_pass_fail_names(text);
drop function if exists assessment_pass_fail_query(text);

create or replace function assessment_pass_fail_def (myevent text) returns text
as $assessment_pass_fail_def$
declare 
th text;
begin
  select array_agg(question||' text') into strict th 
  from (select question from assessment_questions where event=myevent order by question) qq;
  return 'snummer integer,stick_nr integer,stick_event_repo_id integer,'||regexp_replace(th,'[}"{]','','g');
end;
$assessment_pass_fail_def$ language 'plpgsql';

create or replace function assessment_pass_fail_names (myevent text) returns text
as $assessment_pass_fail_names$
declare 
-- note thate snummer collumn is dropped, it would be duplicated in output.
th text;
begin
  select array_agg('ct.'||question) into strict th 
  from (select question from assessment_questions where event=myevent order by question) qq;
  return 'ct.stick_nr,ct.stick_event_repo_id,'||regexp_replace(th,'[}"{]','','g');
end;
$assessment_pass_fail_names$ language 'plpgsql';

create or replace function assessment_pass_fail_query( myevent text) returns text
as $assessment_pass_fail_query$
declare
  th1 text;
  th2 text;
begin
  th1 := assessment_pass_fail_def (myevent);
  -- select array_agg('q'||question||' numeric') into strict th 
  -- from (select question from assessment_questions where event=myevent and category=mycategory order by question) qq;
  -- raise notice 'th=%',th;
  
  th2 := 'crosstab(
  ''select snummer, stick_nr,stick_event_repo_id,question,score||'''':''''||pass_fail_mode as failpass 
  from stick_event_repo car 
  join assessment_scores assc using(event,stick_event_repo_id)
  join assessment_questions qst using(event,question)
  join candidate_stick cs using(stick_event_repo_id)
  join student using(snummer)
  where car.event='''''||myevent||''''' order by stick_nr,question'',
  ''select question from assessment_questions aqs where aqs.event='''''||myevent||''''' order by question''
  ) as ct('||th1||') ';
  return th2;
end; $assessment_pass_fail_query$ 
language 'plpgsql';
commit;


