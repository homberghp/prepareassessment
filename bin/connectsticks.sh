#!/bin/bash
# connect students to sticks
cat - <<EOF | psql -X assessment
begin work;
update stick_event_repo s set youngest=2 where exists (select 1 from candidate_stick where stick_event_repo_id=s.stick_event_repo_id);
insert into assessment_scores (event,student,question,update_ts,snummer,stick_event_repo_id) 
    select event,username as student,question,null, snummer,stick_event_repo_id 
    from candidate_repos 
    join assessment_questions using(event)
      where (event,snummer) not in (select event,snummer from assessment_scores);

commit;
EOF
