create user oraclegit identified by oraclegit
default tablespace users
quota unlimited on users;

grant create session to oraclegit;
grant create table to oraclegit;
grant create procedure to oraclegit;
grant select any dictionary to oraclegit;
grant create type to oraclegit;
grant create job to oraclegit;
grant aq_administrator_role to oraclegit;
grant create public synonym to oraclegit;
grant execute on utl_http to oraclegit;
grant execute on dbms_metadata to oraclegit;