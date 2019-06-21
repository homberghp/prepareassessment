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
