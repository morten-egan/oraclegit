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

	/** Update a file in a repository
	* @author Morten Egan
	* @param git_acount The account that has push privileges to the repository on github
	* @param repos_name The name of the repository
	* @param path The content path.
	* @param message The commit message.
	* @param content The updated file content, Base64 encoded.
	* @param sha The blob SHA of the file being replaced.
	* @param branch The branch name. Default: the repository’s default branch (usually master)
	*/
	procedure update_file (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, message					varchar2
		, content 					clob
		, sha 						varchar2
		, branch					varchar2 default null
	);

	/** Delete a file from a repository
	* @author Morten Egan
	* @param git_acount The account that has push privileges to the repository on github
	* @param repos_name The name of the repository
	* @param path The content path.
	* @param message The commit message.
	* @param sha The blob SHA of the file being deleted.
	* @param branch The branch name. Default: the repository’s default branch (usually master)
	*/
	procedure delete_file (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, message					varchar2
		, sha 						varchar2
		, branch					varchar2 default null
	);

	/** Get the contents of a file/directory/symlink/submodule in a repository
	* @author Morten Egan
	* @param git_account Owner of the repository
	* @param repos_name The name of the repository
	* @param path The content path.
	* @param ref The name of the commit/branch/tag. Default: the repository’s default branch (usually master)
	* @return The full meta information and content of the requested object
	*/
	function get_content (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, ref 						varchar2 default null
	)
	return github.call_result;

	/** This method will return a 302 to a URL to download a tarball or zipball archive for a repository. 
	* Please make sure your HTTP framework is configured to follow redirects 
	* or you will need to use the Location header to make a second GET request.
	* @author Morten Egan
	* @param git_account Owner of the repository
	* @param repos_name The name of the repository
	* @param archive_format Can be either tarball or zipball. Default: tarball
	* @param ref A valid Git reference. Default: the repository’s default branch (usually master)
	* @return A link to an archive
	*/
	function get_archive_link (
		git_account					varchar2
		, repos_name				varchar2
		, archive_format			varchar2 default 'tarball'
		, ref 						varchar2 default 'master'
	)
	return varchar2;

	/** This method returns the preferred README for a repository.
	* @author Morten Egan
	* @param git_account Owner of the repository
	* @param repos_name The name of the repository
	* @param ref The name of the commit/branch/tag. Default: the repository’s default branch (usually master)
	* @return JSON object of the Readme file
	*/
	function get_readme (
		git_account					varchar2
		, repos_name				varchar2
		, ref 						varchar2 default 'master'
	)
	return github.call_result;

end github_repos_content;
/