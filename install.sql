-- Create the github user
@@user.sql

-- Create network ACL for github.com access
@@network_acl.sql

-- Connect as the github user
connect github/github

-- Install packages
@@github_utl_load.sql

-- Install tables
@@tables.sql

-- Install oraclegit package for automation
@@oraclegit.spec.sql
@@oraclegit.body.sql

-- Grant execute on oraclegit to public
grant execute on oraclegit to public;
create public synonym oraclegit for github.oraclegit;

-- Install types, queues, procedures and trigger flow for automated github push
@@oraclegit_push_type.sql