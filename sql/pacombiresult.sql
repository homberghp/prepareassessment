
-- drop function if exists pacombiresult(text);
-- create function pacombiresult (myevent text) returns text as
-- $pacombi$
begin work;
drop view if exists pacombiresult;
drop view if exists pacombirsult;
create view pacombiresult as 
with c1 as (
              select event, category, stick_event_repo_id, summed_score,weight_sum, round(summed_score/weight_sum,1) as grade 
       	      from stick_grade_sum_cat join stick_event_repo using(stick_event_repo_id) join assessment_weight_sum
       	      using(event,category) where category='1'

       ), 
       c2 as (
              select event, category, stick_event_repo_id, summed_score,weight_sum, round(summed_score/weight_sum,1) as grade 
       	      from stick_grade_sum_cat join stick_event_repo using(stick_event_repo_id) join assessment_weight_sum
       	      using(event,category) where category='2'
      ) 
      select snummer,achternaam,roepnaam,voorvoegsel, email1,event,
       	      c1.summed_score as c1summed_score,c1.weight_sum as c1_weight_sum,
       	      c2.summed_score as c2summed_score,c2.weight_sum as c2_weight_sum,
       	      c1.grade as c1grade,
       	      c2.grade as c2grade
       from stick_event_repo join candidate_stick using(stick_event_repo_id) 
       join student using(snummer) 
       join c1 using(event,stick_event_repo_id) 
       join c2 using(event,stick_event_repo_id) 
       order by achternaam, roepnaam;

commit;
--select * from pacombiresult where event='JAVA220160406';
