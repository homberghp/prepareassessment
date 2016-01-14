begin work;

create table candidate_repos_table_backup as select * from candidate_repos;
-- first give all pre 201309xx events a stick number, even if it is fake.


alter table candidate_repos rename to candidate_repos_table;
create table sn as select 100+row_number() over(partition by event) as sticknr,event,snummer 
       from candidate_repos_table;
update candidate_repos_table crt
       set sticknr =(select sticknr 
       from sn  where sn.snummer=crt.snummer and sn.event=crt.event)
       where sticknr isnull ;
drop table sn;
create table event_candidate as 
select event,
       snummer,
       username,
       lastname,
       firstname,
       tussenvoegsel,
       ou,
       cohort,
       email,
       pcn,
       sclass from candidate_repos_table;

insert into stick_event_repo
       (event,stick_nr,reposroot,reposuri,youngest,youngestdate)
       select event,sticknr,reposroot,reposuri,youngest,youngestdate 
       from candidate_repos_table;

insert into candidate_stick
       (stick_event_repo_id,snummer)
       select stick_event_repo_id,snummer 
       from candidate_repos_table crt
       join stick_event_repo ser 
       	    on (crt.event=ser.event and crt.sticknr=ser.stick_nr);

insert into event_password
       (event,snummer,password)
       select event,snummer,password from candidate_repos_table;


create view candidate_repos_view as
       select ec.event,
       username,
       password,
       true as  active,
       stick_nr as  uid,
       stick_nr as gid,
       lastname,
       firstname,	
       tussenvoegsel,
       ou, 
       cohort,
       email,
       pcn,
       sclass,
       '/exam/exam'::text as homedir,
       '/bin/rbash'::text as shell,
       ec.event as afko,
       reposroot,
       reposuri,
       to_char(now(),'YYYY')::numeric as examyear,
       '2.94'::text as examroom,
       stick_nr as grp_num,
       youngest,
       youngestdate,
       cs.snummer,
       stick_nr as sticknr
       from stick_event_repo ser 
       join candidate_stick cs using(stick_event_repo_id)
       join event_candidate ec on (ser.event=ec.event and cs.snummer=ec.snummer)
       join event_password ep on (ec.event=ep.event and ep.snummer=cs.snummer);

--commit;
-- checks
select count(*) from candidate_repos_table;
select count(*) from candidate_repos_view;

select * from candidate_repos_table 
       where (sticknr,snummer,reposuri) not in (select sticknr,snummer,reposuri from candidate_repos_view);
select * from candidate_repos_view 
       where (sticknr,snummer,reposuri) not in (select sticknr,snummer,reposuri from candidate_repos_table);

select * from candidate_repos_view 
       where (snummer,reposuri) not in (select snummer,reposuri from candidate_repos_table_backup);

select * from candidate_repos_table_backup 
       where (snummer,reposuri) not in (select snummer,reposuri from candidate_repos_view);

alter table candidate_repos_view rename to candidate_repos;
commit;
--rollback;
