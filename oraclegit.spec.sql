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

	/** Helper function to base64 encode content
	* @author Morten Egan
	* @param content The data to encode
	* @return The content data as base64
	*/
	function encode64_clob(
		content 				in 			clob
	) 
	return clob;

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

end oraclegit;
/