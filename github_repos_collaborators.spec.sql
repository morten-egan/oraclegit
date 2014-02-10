create or replace package github_repos_collaborators

as

	/** Interface to github repositories collaborators API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List collaborators
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	*/
	function list_collaborators (
		git_account					varchar2
		, repos_name				varchar2
	)
	return json.jsonstructobj;

	/** Check if a user is a collaborator
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param collaborator
	* @return True if the user is a collaborator of the repository
	*/
	function check_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	)
	return boolean;

	/** Add user as a collaborator
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param collaborator The collaborator to add to the repository
	*/
	procedure add_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	);

	/** Remove user as a collaborator
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param collaborator The collaborator to remove
	*/
	procedure remove_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	);

end github_repos_collaborators;
/