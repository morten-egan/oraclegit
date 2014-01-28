create or replace package github_repos

as

	/** Interface to Github repositories API
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	/** Create a repository.
	* @author Morten Egan
	* @param github_account The account that creates the repository on github
	* @param repos_name The name of the repository
	* @param use_org Boolean value to define if it should be created in an organization
	* @param org_name The name of the organization to create the repository under.
	* @param is_private Whether or not the organization should be private or public
	* @param issue_enabled Boolean to enable issues or not.
	*/
	procedure repos_create (
		git_account					varchar2
		, repos_name				varchar2
		, description				varchar2 default 'OracleGit repository'
		, use_org					boolean default false
		, org_name					varchar2 default null
		, is_private				boolean default false
		, issue_enabled				boolean default true
	);

end github_repos;
/