create or replace package github_repos_commits

as

	/** Interface to github repositories commits API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List commits on a repository
	* A special note on pagination: Due to the way Git works, commits are paginated based on SHA instead of page number. Please follow the link headers as outlined in the pagination overview instead of constructing page links yourself.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param sha SHA or branch to start listing commits from.
	* @param path Only commits containing this file path will be returned.
	* @param author GitHub login, name, or email by which to filter by commit author
	* @param since Only commits after this date will be returned. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
	* @param until Only commits before this date will be returned. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
	*/
	function list_repos_commits (
		git_account					varchar2
		, repos_name				varchar2
		, sha 						varchar2 default null
		, path 						varchar2 default null
		, author					varchar2 default null
		, since						varchar2 default null
		, until						varchar2 default null
	)
	return json.jsonstructobj;

	/** Get a single commit
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param sha SHA of the commit.
	*/
	function get_commit (
		git_account					varchar2
		, repos_name				varchar2
		, sha 						varchar2
	)
	return json.jsonstructobj;

	/** Compare two commits. Note: Both :base and :head can be either branch names in :repo or branch names in other repositories in the same network as :repo. For the latter case, use the format user:branch
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param base The base to compare
	* @param head The head to compare
	* @return Diff betweeen base and head.
	*/
	function compare_commits (
		git_account					varchar2
		, repos_name				varchar2
		, base 						varchar2
		, head 						varchar2
	)
	return json.jsonstructobj;

end github_repos_commits;
/