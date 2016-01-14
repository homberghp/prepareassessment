begin work;
drop table if exists question_remark;
create table question_remark (
       question_remark_id serial primary key,
       event text not null,
       question varchar(40) not null,
       remark text
);

alter table question_remark add constraint question_remark_fk1
      foreign key (event,question) references assessment_questions(event, question) ON UPDATE CASCADE;
grant select,update,insert,references on table question_remark to wwwrun;
grant all on sequence table question_remark_question_remark_id_seq to wwwrun;

commit; 