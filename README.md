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

###Run the installation script

Log in as sys in sqlplus an run the install.sql script supplied in the root of the release file:

	[oracle@localhost oraclegit]$ sqlplus sys/oracle as sysdba

	SQL*Plus: Release 11.2.0.2.0 Production on Thu Feb 27 12:52:01 2014

	Copyright (c) 1982, 2010, Oracle.  All rights reserved.


	Connected to:
	Oracle Database 11g Enterprise Edition Release 11.2.0.2.0 - Production
	With the Partitioning, OLAP, Data Mining and Real Application Testing options

	SQL> @install

	User created.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	Grant succeeded.


	PL/SQL procedure successfully completed.

	Connected.
	-- Setting optimize level -

	Session altered.

	-----------------------------------
	-- Compiling objects for PL/JSON --
	-----------------------------------

	PL/SQL procedure successfully completed.


	Type created.


	Type created.

	No errors.

	Type created.

	No errors.

	Type created.

	No errors.

	Package created.


	Package body created.


	Package created.


	Package body created.


	Type body created.

	No errors.

	Package created.


	Package body created.


	Type body created.

	No errors.

	Type body created.

	No errors.

	Package created.


	Package body created.

	------------------------------------------
	-- Adding optional packages for PL/JSON --
	------------------------------------------

	Package created.


	Package body created.


	Package created.


	Package body created.


	Package created.


	Package body created.


	Package created.


	Package body created.


	Package created.


	Package body created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Package body created.


	Sequence created.


	Table created.


	1 row created.


	1 row created.


	1 row created.


	1 row created.


	1 row created.


	1 row created.


	1 row created.


	1 row created.


	Table created.


	Table created.


	Table created.


	Table created.


	Table created.


	Table created.


	Package created.


	Package body created.


	Grant succeeded.


	Synonym created.


	Type created.


	PL/SQL procedure successfully completed.


	Procedure created.


	PL/SQL procedure successfully completed.


	PL/SQL procedure successfully completed.


	Procedure created.


	Grant succeeded.


	Synonym created.


	Trigger created.


	Trigger created.

	SQL> 


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

###Push a file to the newly created repository:
	declare
	  myjson json.jsonstructobj;
	begin
	  github.set_session_wallet('file:/home/oracle/wallet', 'Manager123');
	  github.set_logon_info('github-user', 'gitPass123');
	  github_repos_content.create_file (
	    git_account => 'github-user'
	    , repos_name => 'trepos'
	    , path => 'myNewFile.txt'
	    , message => 'Just a commit message'
	    , content => github.encode64_clob('Hello GitHub')
	  );
	end;
	/