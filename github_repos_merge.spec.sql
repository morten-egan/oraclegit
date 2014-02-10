create or replace package github_repos_merge

as

	/** Interface to github repositories merge API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** The Repo Merging API supports merging branches in a repository. 
	* This accomplishes essentially the same thing as merging one branch into another in a local repository and then pushing to GitHub. 
	* The benefit is that the merge is done on the server side and a local repository is not needed. 
	* This makes it more appropriate for automation and other tools where maintaining local repositories would be cumbersome and inefficient.
	* The authenticated user will be the author of any merges done through this endpoint.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param base The name of the base branch that the head will be merged into.
	* @param head The head to merge. This can be a branch name or a commit SHA1.
	* @param commit_message Commit message to use for the merge commit. If omitted, a default message will be used.
	*/
	procedure repos_merge (
		git_account					varchar2
		, repos_name				varchar2
		, base 						varchar2
		, head						varchar2
		, commit_message			varchar2 default null
	);

end github_repos_merge;
/