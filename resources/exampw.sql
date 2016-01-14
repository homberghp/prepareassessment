
-- begin work;
drop table if exists tutor_pw cascade;
drop table if exists candidate_repos cascade;
create table tutor_pw (username varchar(10) primary key, password varchar(64));
create table candidate_repos (
       _id serial primary key,
       event text,
       username varchar(10),
       password varchar(64) not null,
       active boolean default false,
       uid integer,
       gid integer,
       lastname text,
       firstname text,
       tussenvoegsel text,
       ou varchar(10),
       cohort integer,
       email text,
       pcn integer,
       sclass varchar(10),
       homedir text,
       shell text,
       afko text,
       reposroot text unique,
       reposuri text unique,
       examyear integer,
       examroom text,
       grp_num integer,
       unique (event,username),
       youngest integer,
       youngestdate timestamp
       );

create or replace view svn_users as select username,password,'tutor' as event from tutor_pw
       union 
   select username,password,event from candidate_repos where active = true;

create or replace view doc_users as select username,password,'tutor' as event from tutor_pw
       union 
   select username,password,event from candidate_repos;


grant all on candidate_repos to wwwrun;
grant select, references on tutor_pw to wwwrun;
grant select,references on svn_users to wwwrun;
grant select,references on doc_users to wwwrun;
-- commit;
