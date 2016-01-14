begin work;
drop table if exists candidate_stick;
drop table if exists stick_event_repo;
create table stick_event_repo (
       stick_event_repo_id bigserial primary key,
       event text not null,
       stick_nr integer,
       reposroot text,
       reposuri text,
       youngest integer,
       youngestdate timestamp without time zone,
       unique(event,stick_nr)
) without oids;

create table candidate_stick (
       stick_event_repo_id bigint references stick_event_repo(stick_event_repo_id),
       snummer integer,
       unique( stick_event_repo_id,snummer)
) without oids;

--rollback;

create table event_password (
       _id serial primary key,
       event text not null,
       snummer integer,
       password character varying(64),
       unique(event,snummer)
);

commit;
