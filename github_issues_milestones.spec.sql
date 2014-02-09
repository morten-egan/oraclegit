create or replace package github_issues_milestones

as

	/** Interface to github issues milestones API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List milestones for a repository
	* @author Morten Egan
	* @param git_account The account that has push privileges to the repository on github
	* @param repos_name The name of the repository
	* @param state The state of the milestone. Either open or closed. Default: open
	* @param sort What to sort results by. Either due_date or completeness. Default: due_date
	* @param direction The direction of the sort. Either asc or desc. Default: asc
	* @return Milestones for the repository
	*/
	function list_milestones (
		git_account					varchar2
		, repos_name				varchar2
		, state 					varchar2 default 'open'
		, sort 						varchar2 default 'due_date'
		, direction 				varchar2 default 'asc'
	)
	return json.jsonstructobj;

	/** Get a single milestone
	* @author Morten Egan
	* @param git_account The account that has push privileges to the repository on github
	* @param repos_name The name of the repository
	* @param milestone_id The id of the milestone to get
	* @return The JSON object of a milestone
	*/
	function get_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	)
	return json.jsonstructobj;

	/** Create a milestone
	* @author Morten Egan
	* @param git_account The account that has push privileges to the repository on github
	* @param repos_name The name of the repository
	* @param title The title of the milestone.
	* @param state The state of the milestone. Either open or closed. Default: open
	* @param description A description of the milestone.
	* @param due_on The milestone due date. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
	*/
	procedure create_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, title						varchar2
		, state						varchar2 default 'open'
		, description				varchar2 default null
		, due_on					varchar2 default null
	);

	/** Update a milestone
	* @author Morten Egan
	* @param git_account The account that has push privileges to the repository on github
	* @param repos_name The name of the repository
	* @param milestone_id The id of the milestone to edit
	* @param title The title of the milestone.
	* @param state The state of the milestone. Either open or closed. Default: open
	* @param description A description of the milestone.
	* @param due_on The milestone due date. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
	*/
	procedure update_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
		, title						varchar2 default null
		, state						varchar2 default 'open'
		, description				varchar2 default null
		, due_on					varchar2 default null
	);

	/** Delete a milestone
	* @author Morten Egan
	* @param git_account The account that has push privileges to the repository on github
	* @param repos_name The name of the repository
	* @param milestone_id The id of the milestone to delete
	*/
	procedure delete_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	);

end github_issues_milestones;
/