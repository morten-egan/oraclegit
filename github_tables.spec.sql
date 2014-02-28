create or replace package github_tables

as

	/** Package with table functions, for selecting information directly from github
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	-- Record types
	type github_repository is record (
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
		git_account					varchar2 default github.get_session_github_user
		, repos_type 				varchar2 default 'owner'
		, repos_sort				varchar2 default 'full_name'
		, repos_direction			varchar2 default 'asc'
	)
	return repos_tab
	pipelined;

	type github_repos_lang is record (
		repos_name 					varchar2(4000)
		, repos_lang 				varchar2(4000)
		, lang_bytes				number
	);

	type repos_lang_tab is table of github_repos_lang;

	/** Return the list of languages in the repository
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @return A table list of languages
	*/
	function repository_languages (
		repos_name 					varchar2
		, git_account				varchar2 default github.get_session_github_user
	)
	return repos_lang_tab
	pipelined;

	type github_issue is record (
		issue_id 					number
		, api_url					varchar2(4000)
		, html_url					varchar2(4000)
		, state						varchar2(4000)
		, title						varchar2(4000)
		, body						varchar2(4000)
		, created_by				varchar2(4000)
		, assignee					varchar2(4000)
		, comments					number
		, created 					date
		, updated 					date
		, closed					date
	);

	type repos_issues_tab is table of github_issue;

	/** Return the list of issues for a repository
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @param milestone If an integer is passed, it should refer to a milestone number. If the string * is passed, issues with any milestone are accepted. If the string none is passed, issues without milestones are returned. Default: *
	* @param state Indicates the state of the issues to return. Can be either open or closed. Default: open
	* @param assignee Can be the name of a user. Pass in none for issues with no assigned user, and * for issues assigned to any user. Default: *
	* @param creator The user that created the issue.
	* @param mentioned A user that’s mentioned in the issue.
	* @param labels A list of comma separated label names. Example: bug,ui,@high
	* @param sort What to sort results by. Can be either created, updated, comments. Default: created
	* @param direction The direction of the sort. Can be either asc or desc. Default: desc
	* @param since Only issues updated at or after this time are returned. This is a string timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
	*/
	function repository_issues (
		git_account					varchar2
		, repos_name				varchar2
		, milestone 				varchar2 default null
		, state						varchar2 default null
		, assignee					varchar2 default null
		, creator					varchar2 default null
		, mentioned					varchar2 default null
		, labels 					varchar2 default null
		, sort 						varchar2 default null
		, direction 				varchar2 default null
		, since 					varchar2 default null
	)
	return repos_issues_tab
	pipelined;

	type repos_contributor is record (
		user_name					varchar2(4000)
		, url 						varchar2(4000)
		, contributions				number
	);

	type repos_contributor_tab is table of repos_contributor;

	/** Return a list of contributors for a repository
	* @author Morten Egan
	* @param git_Account The owner of the repository
	* @param repos_name The name of the repository
	* @param anon Whether or not to include anonymous users
	*/
	function repository_contributors (
		git_account					varchar2
		, repos_name				varchar2
		, anon 						varchar2 default '1'
	)
	return repos_contributor_tab
	pipelined;

	type repos_branch is record (
		branch_name					varchar2(4000)
		, commit_sha				varchar2(4000)
		, commit_url				varchar2(4000)
	);

	type repos_branch_tab is table of repos_branch;

	/** Return repository branches
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	*/
	function repository_branches (
		git_account					varchar2
		, repos_name				varchar2
	)
	return repos_branch_tab
	pipelined;

	type repos_content_obj is record (
		content_type				varchar2(20)
		, content_name				varchar2(4000)
		, content_path				varchar2(4000)
		, github_sha				varchar2(4000)
		, url 						varchar2(4000)
	);

	type repos_content_obj_tab is table of repos_content_obj;

	/** Return a list of repository contents from path
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @param path The path to get contents from
	*/
	function repository_contents (
		git_account					varchar2
		, repos_name				varchar2
		, path 						varchar2 default '/'
	)
	return repos_content_obj_tab
	pipelined;

end github_tables;
/