create user oraclegit identified by oraclegit
default tablespace users
quota unlimited on users;

grant create session to oraclegit;
grant create table to oraclegit;
grant create procedure to oraclegit;
grant select any dictionary to oraclegit;
grant execute on utl_http to oraclegit;
grant execute on dbms_metadata to oraclegit;