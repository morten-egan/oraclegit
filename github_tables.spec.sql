create or replace package github_tables

as

	/** Package with table functions, for selecting information directly from github
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	-- Record types
	type github_respository is record (
		repos_id 					number
		, repos_name				varchar2(4000)
		, repos_full_name			varchar2(4000)
		, repos_owner				varchar2(4000)
		, repos_description			varchar2(4000)
		, repos_created				date
		, repos_updated				date
	);

	type repos_tab is table of github_repository;

	/** Return a list of repositories
	* @author Morten Egan
	* @param repos_type Can be one of all, owner, member. Default: owner
	* @param repos_sort Can be one of created, updated, pushed, full_name. Default: full_name
	* @param repos_direction Can be one of asc or desc. Default: when using full_name: asc, otherwise desc
	* @return A table list of repositories
	*/
	function repositories (
		git_account					varchar2 github.get_session_github_user
		, repos_type 				varchar2 default 'owner'
		, repos_sort				varchar2 default 'full_name'
		, repos_direction			varchar2 default 'asc'
	)
	return repos_tab
	pipelined;

end github_tables;
/