begin work;
drop function assessment_score_query(text);
create function assessment_score_query( myevent text) returns text
as $assessment_score_query$
declare
  th text;
begin
  select array_agg('q'||question||' numeric') into strict th from (select question from assessment_questions where event=myevent order by question) qq;
  th := 'select * from crosstab(
  ''select snummer,lastname,firstname,tussenvoegsel,email,question,score from candidate_repos car join assessment_scores assc using(snummer,event) where event='''''||myevent||''''' and youngest > 1 order by snummer,question'',
  ''select question from assessment_questions where event='''''||myevent||''''' order by question''
  ) as ct(snummer integer,lastname text,firstname text,tussenvoegsel text,email text,'||regexp_replace(th,'[}"{]','','g')||') order by lastname,firstname';
  return th;
end; $assessment_score_query$ 
language 'plpgsql';

commit;