create or replace package github_repos_forks

as

	/** Interface to github repositories forks API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List forks
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param sort The sort order. Can be either newest, oldest, or stargazers. Default: newest
	*/
	function list_forks (
		git_account					varchar2
		, repos_name				varchar2
		, sort						varchar2 default 'newest'
	)
	return json.jsonstructobj;

	/** Create a fork. Create a fork for the authenticated user.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param organization The organization login. The repository will be forked into this organization.
	*/
	procedure create_fork (
		git_account					varchar2
		, repos_name				varchar2
		, organization 				varchar2 default null
	);


end github_repos_forks;
/