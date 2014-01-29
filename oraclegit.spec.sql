create or replace package oraclegit.oraclegit

as

	/**
	* Oraclegit package enables you to automatically add git source control to an oracle schema
	* in your database. It tracks all changes to your plsql code and write them to your git
	* repository. 
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	/**
	* Enable git tracking for schema
	* @author Morten Egan
	* @param git_schema The schema that should be git tracking enabled
	* @param git_repository_name The name of the repository. If null, resolve to schema_name
	* @param git_account Name of the github account to use
	* @param git_repository_desc A short description of the repository
	* @param git_organization Organization that the repository belongs to
	*/
	procedure git_enable (
		git_account					varchar2
		, git_schema				varchar2 default user
		, git_repository_name		varchar2 default null
		, git_repository_desc		varchar2 default null
		, git_organization			varchar2 default null
	);

	/** Write captured changes to git repository.
	* @author Morten Egan
	* @param git_schema The owner of the object created/updated
	* @param obj_type The object type created/updated
	* @param obj_name The name of the object created/updated
	*/
	procedure git_write (
		git_schema					varchar2
		, obj_type					varchar2
		, obj_name					varchar2
	);

	/** Check if a schema is git tracked
	* @author Morten Egan
	* @param git_schema The schema to check
	* @return True if schema is git tracked, false if not.
	*/
	function is_tracked (
		git_schema					varchar2
	)
	return boolean;

	/** Check if a repository already exists
	* @author Morten Egan
	* @param repository
	* @return True if repository exists, false it not.
	*/
	function repos_exists (
		repository 					varchar2
	)
	return boolean;

	/** Get oraclegit env setting
	* @author Morten Egan
	* @param env_name The name of the environment variable
	* @return The value of requested variable. Null if not set
	*/
	function get_oraclegit_env (
		env_name					varchar2
	)
	return varchar2;

	/** Add a github account to the OracleGit system
	* @author Morten Egan
	* @param git_account The name of the account.
	* @param git_passwd The password for the account.
	* @param git_full_name The full name of the user
	* @param git_email_address The email address of the user.
	* @param organization The default organization to use, if any.
	*/
	procedure add_github_account (
		git_account 				varchar2
		, git_passwd 				varchar2
		, git_full_name 			varchar2 default null
		, git_email_address			varchar2 default null
		, organization 				varchar2 default null
	);

	/** Add a repository to OracleGit
	* @author Morten Egan
	* @param repos_name Name of the repository
	* @param repos_owner The owner of the repository
	* @param repos_organization Organization of repository
	* @param repos_branch Branch to use in the repository, if different than default
	*/
	procedure add_github_repository (
		repos_name 					varchar2
		, repos_owner 				varchar2
		, repos_organization		varchar2 default null
		, repos_branch				varchar2 default null
	);

	/** Add object for github tracking
	* @author Morten Egan
	* @param repos_name The repository name
	* @param oracle_schema_name The oracle owner of the object
	* @param obj_name The object name in oracle
	* @param obj_type The type of object
	* @param obj_path The github path of the object
	* @param obj_sha The sha of the github file
	*/
	procedure add_object_tracking (
		repos_name 					varchar2
		, oracle_schema_name		varchar2
		, obj_name					varchar2
		, obj_type					varchar2
		, obj_path					varchar2
		, obj_sha					varchar2
	);

end oraclegit;
/