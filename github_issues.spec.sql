create or replace package github_issues

as

	/** Interface to github issues API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** Create an issue
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @param title The title of the issue.
	* @param body The contents of the issue.
	* @param assignee Login for the user that this issue should be assigned to.
	* @param milestone Milestone to associate this issue with.
	* @param labels Labels to associate with this issue.
	*/
	procedure create_issue (
		git_account					varchar2
		, repos_name				varchar2
		, title						varchar2
		, body						clob default null
		, assignee					varchar2 default null
		, milestone 				number default null
		, labels 					varchar2 default null
	);

	/** Get a single issue
	* @author Morten Egan
	* @param git_account Owner of the repository
	* @param repos_name The name of the repository
	* @param issue_number ID of the issue to fetch
	*/
	function get_single_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_number				number
	)
	return json.jsonstructobj;

	/** Get issues for a specific repositories
	* @author Morten Egan
	* @param git_account Owner of the repository
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
	function get_repository_issues (
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
	return json.jsonstructobj;

	/** Edit an issue
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @param issue_number ID of the issue to fetch
	* @param title The title of the issue.
	* @param body The contents of the issue.
	* @param assignee Login for the user that this issue should be assigned to.
	* @param state State of the issue. Either open or closed.
	* @param milestone Milestone to associate this issue with.
	* @param labels Labels to associate with this issue.
	*/
	procedure edit_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_number				number
		, title						varchar2
		, body						clob default null
		, assignee					varchar2 default null
		, state 					varchar2 default null
		, milestone 				number default null
		, labels 					varchar2 default null
	);

end github_issues;
/