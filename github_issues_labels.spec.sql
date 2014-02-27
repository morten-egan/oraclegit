create or replace package github_issues_labels

as

	/** Interface to Github issues labels API
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List all labels for this repository
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	*/
	function list_repos_labels (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result;

	/** Get a single label
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param label The name of the label to get
	*/
	function get_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
	)
	return github.call_result;

	/** Create a label
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param label The name of the label
	* @param color A 6 character hex code, without the leading #, identifying the color.
	*/
	procedure create_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
		, color						varchar2
	);

	/** Update a label
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param label The name of the label
	* @param color A 6 character hex code, without the leading #, identifying the color.
	*/
	procedure update_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
		, color						varchar2
	);

	/** Delete a label
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param label The name of the label
	*/
	procedure delete_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
	);

	/** List labels on an issue
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param issue_id The ID of the issue
	*/
	function list_issue_labels (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
	)
	return github.call_result;

	/** Add labels to an issue
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param issue_id The ID of the issue
	* @param labels A list of labels
	*/
	procedure add_labels_to_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, labels 					json_list
	);

	/** Remove a label from an issue
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param issue_id The ID of the issue
	* @param label Name of label
	*/
	procedure remove_label_from_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, label 					varchar2
	);

	/** Replace all labels for an issue
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param issue_id The ID of the issue
	* @param labels A list of labels
	*/
	procedure replace_all_labels_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, labels 					json_list
	);

	/** Remove all labels from an issue
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param issue_id The ID of the issue
	*/
	procedure remove_labels_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
	);

	/** Get labels for every issue in a milestone
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param milestone_id The id of the milestone
	*/
	function labels_from_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	)
	return github.call_result;

end github_issues_labels;
/