#Project oraclegit readme file

A github enabled database.

##Description:

This plsql library enables you to use github as source control for your oracle code, as well as using it for issue tracking of any errors your code encounters.

##Installation

To use this package, you will need to install the GitHub ssl certificates into an oracle wallet. Download the certificates using your browser, and create a wallet and import the certificates (for a more detailed exmaple on how to do this go here [Create wallet](http://www.oracle-base.com/articles/misc/utl_http-and-ssl.php)):

###Create wallet

orapki wallet create -wallet /home/oracle/wallet -pwd WalletPasswd123
orapki wallet add -wallet /home/oracle/wallet -trusted_cert -cert "/home/oracle/cert1.crt" -pwd WalletPasswd123
orapki wallet add -wallet /home/oracle/wallet -trusted_cert -cert "/home/oracle/cert2.crt" -pwd WalletPasswd123
orapki wallet add -wallet /home/oracle/wallet -trusted_cert -cert "/home/oracle/cert3.crt" -pwd WalletPasswd123

###Create a user
Create a user to install the packages into. You can user this template:

	create user oraclegit identified by oraclegit
	default tablespace users
	quota unlimited on users;

	grant create session to oraclegit;
	grant create table to oraclegit;
	grant create procedure to oraclegit;
	grant select any dictionary to oraclegit;
	grant execute on utl_http to oraclegit;
	grant execute on dbms_metadata to oraclegit;

###Add Access Control List
If you are installing this into oracle 11g or higher we need to create an ACL for utl_http and the user we created in the previous step [This should be run as sys]:

	BEGIN
	  DBMS_NETWORK_ACL_ADMIN.create_acl (
	    acl          => 'github_acl.xml', 
	    description  => 'ACL definition for Github.com access',
	    principal    => 'ORACLEGIT',
	    is_grant     => TRUE, 
	    privilege    => 'connect',
	    start_date   => SYSTIMESTAMP,
	    end_date     => NULL);

	  COMMIT;

	dbms_network_acl_admin.add_privilege (
				acl	 => 'github_acl.xml',
				principal	 => 'ORACLEGIT',
				is_grant	 => true,
				privilege	 => 'resolve'
			);
			commit;

			dbms_network_acl_admin.assign_acl (
				acl          => 'github_acl.xml',
				host         => 'api.github.com',
				lower_port	 => 443,
				upper_port	 => null
			);
			commit;

	  COMMIT;
	END;
	/

###Install packages

To install the packages run the following commands as the user we created:

	@json.spec.sql
	@github.spec.sql
	@github_repos.spec.sql
	@github_repos_content.spec.sql
	@github_issues.spec.sql
	@json.body.sql
	@github.body.sql
	@github_repos.body.sql
	@github_repos_content.body.sql
	@github_issues.body.sql

##Examples

For the examples below, we expect wallet location to be */home/oracle/wallet* and wallet password to be *WalletPasswd123*. Also we are using a github test user with the username of *github-user* with the password *gitPass123*.

###Create a repository:
	declare
	  myjson json.jsonstructobj;
	begin
		github.set_session_wallet('file:/home/oracle/wallet', 'WalletPasswd123');
		github.set_logon_info('github-user', 'gitPass123');
		github_repos.repos_create (
			git_account => 'github-user'
			, repos_name => 'trepos'
			, use_org => false
			, org_name => null
			, private => false
			, auto_init => true
		);
	end;
	/