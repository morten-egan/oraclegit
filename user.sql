create user github identified by github
default tablespace users
quota unlimited on users;

grant connect to github;
grant create table to github;
grant create sequence to github;
grant create procedure to github;
grant create type to github;
grant create any job to github;
grant aq_administrator_role to github;
grant aq_user_role to github;
grant create trigger to github;
grant execute on dbms_aq to github;
grant execute on dbms_aqadm to github;
grant administer database trigger to github;
grant create public synonym to github;
grant execute on utl_http to github;
grant execute on dbms_metadata to github;
grant select on dba_objects to github;

-- Create network ACL for github.com access
@@network_acl.sql

connect github/github

-- Install packages
@@github_utl_load.sql

-- Install tables
@tables.sql

@@oraclegit.spec.sql
@@oraclegit.body.sql

grant execute on oraclegit to public;
create public synonym oraclegit for github.oraclegit;

@@oraclegit_push_type.sql