create or replace package github_issues_comments

as

	/** Interface to github issues comments API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List comments on an issue
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param issue_id The id of the issue
	*/
	function list_issue_comments (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id					number
	)
	return github.call_result;

	/** List comments in a repository
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param sort Either created or updated. Default: created
	* @param direction Either asc or desc. Ignored without the sort parameter.
	* @param since Only comments updated at or after this time are returned. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
	*/
	function list_repository_comments (
		git_account					varchar2
		, repos_name				varchar2
		, sort 						varchar2 default 'created'
		, direction					varchar2 default 'asc'
		, since						varchar2 default null
	)
	return github.call_result;

	/** Get a single comment
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param comment_id The id of the comment to get
	* @return The JSON document of specified comment
	*/
	function get_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
	)
	return github.call_result;

	/** Create a comment
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param issue_id The id of the issue to comment on
	* @param body The comment to create
	*/
	procedure create_comment (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id					number
		, body						varchar2
	);

	/** Edit a comment
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param comment_id The id of the issue to comment on
	* @param body The comment to create
	*/
	procedure edit_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
		, body						varchar2
	);

	/** Delete a comment
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param comment_id The id of the comment to delete
	*/
	procedure delete_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
	);

end github_issues_comments;
/