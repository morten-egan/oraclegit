create or replace package github_repos_content

as

	/** Interface to github repositories content API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** Create a file in a repository
	* @author Morten Egan
	* @param git_account The account that has push privileges to the repository on github
	* @param repos_name The name of the repository
	* @param path The content path.
	* @param message The commit message.
	* @param content The new file content, Base64 encoded.
	* @param branch The branch name. Default: the repository’s default branch (usually master)
	*/
	procedure create_file (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, message					varchar2
		, content 					clob
		, branch					varchar2 default null
	);

end github_repos_content;
/