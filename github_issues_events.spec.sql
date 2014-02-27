create or replace package github_issues_events

as

	/** Interface to Github issues events API
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List events for an issue 
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param issue_number The id of the issue
	* @return The JSON data on all events for specified issue
	*/
	function list_issue_events (
		git_account					varchar2
		, repos_name				varchar2
		, issue_number 				number
	)
	return github.call_result;

	/** List events for a repository 
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @return The JSON data on all events for specified repository
	*/
	function list_repos_events (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result;

	/** Get single event
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param event_id The id of the event to fetch
	* @return The JSON data for that specific event
	*/
	function get_event (
		git_account					varchar2
		, repos_name				varchar2
		, event_id					number
	)
	return github.call_result;

end github_issues_events;
/