begin work;
drop table if exists compiler_errors cascade;
create table compiler_errors (
       compiler_error_id serial,
       event text,
       stick integer,
       project text,
       pass_fail text,
       jclass text,
       coordinate text,
       message text
);
alter table compiler_errors add constraint compiler_errors_un1
       unique(event,stick,project,pass_fail,jclass,coordinate,message);

commit;
