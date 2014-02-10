create or replace package github_issues_assignees

as

	/** Interface to github issues assignees API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List assignees. This call lists all the available assignees (owner + collaborators) to which issues may be assigned.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @return The list of available assignees
	*/
	function list_assignees (
		git_account					varchar2
		, repos_name				varchar2
	)
	return json.jsonstructobj;

	/** Check assignee. You may also check to see if a particular user is an assignee for a repository.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param assignee If the given assignee login belongs to an assignee for the repository.
	* @return True if the assignee is part of repository
	*/
	function check_assignee (
		git_account					varchar2
		, repos_name				varchar2
		, assignee 					varchar2
	)
	return boolean;

end github_issues_assignees;
/