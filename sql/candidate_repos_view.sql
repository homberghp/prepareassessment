begin work;
drop view if exists candidate_repos_view;
create view candidate_repos_view as
       select ser.event,
       s.username,
       ep.password,
       true as  active,
       stick_nr as  uid,
       stick_nr as gid,
       s.achternaam as lastname,
       s.roepnaam as firstname,	
       s.voorvoegsel as tussenvoegsel,
       s.opl as ou, 
       s.cohort,
       s.email1 as email,
       s.pcn,
       s.sclass,
       '/exam/exam'::text as homedir,
       '/bin/rbash'::text as shell,
       ser.event as afko,
       ser.reposroot,
       ser.reposuri,
       to_char(now(),'YYYY')::numeric as examyear,
       '2.94'::text as examroom,
       ser.stick_nr as grp_num,
       ser.youngest,
       ser.youngestdate,
       cs.snummer,
       ser.stick_nr as sticknr,
       stick_event_repo_id
       from stick_event_repo ser 
       join candidate_stick cs using(stick_event_repo_id)
       --join event_candidate ec on (ser.event=ec.event and cs.snummer=ec.snummer)
       join student s on(cs.snummer=s.snummer)
       left join event_password ep on (ser.event=ep.event and ep.snummer=cs.snummer);

grant all on table candidate_repos_view to wwwrun;
commit;
--rollback;