create or replace package github_repos

as

	/** Interface to Github repositories API. To call any of these, we expect that github session has been
	* set up prior to calling.
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	/** Create a repository.
	* @author Morten Egan
	* @param git_account The account that creates the repository on github
	* @param repos_name The name of the repository
	* @param homepage A URL with more information about the repository
	* @param private Either true to create a private repository, or false to create a public one. Creating private repositories requires a paid GitHub account. Default: false
	* @param has_issues Either true to enable issues for this repository, false to disable them. Default: true
	* @param has_wiki Either true to enable the wiki for this repository, false to disable it. Default: true
	* @param has_downloads Either true to enable downloads for this repository, false to disable them. Default: true
	* @param team_id The id of the team that will be granted access to this repository. This is only valid when creating a repository in an organization.
	* @param auto_init Pass true to create an initial commit with empty README. Default: false
	* @param gitignore_template Desired language or platform .gitignore template to apply. Use the name of the template without the extension. For example, “Haskell”. Ignored if the auto_init parameter is not provided.
	* @param use_org Boolean value to define if it should be created in an organization
	* @param org_name The name of the organization to create the repository under.
	*/
	procedure repos_create (
		git_account					varchar2
		, repos_name				varchar2
		, description				varchar2 default null
		, homepage					varchar2 default null
		, private 					boolean default false
		, has_issues				boolean default true
		, has_wiki					boolean default true
		, has_downloads				boolean default true
		, team_id					number default null
		, auto_init					boolean default false
		, gitignore_template		varchar2 default null
		, use_org					boolean default false
		, org_name					varchar2 default null
	);

	/** Return information about specific repository.
	* @author Morten Egan
	* @param git_account The account owner of the repository
	* @param repos_name The name of the repository to get
	*/
	function repos_get (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result;

	/** Repository list
	* @author Morten Egan
	* @param repos_type Can be one of all, owner, member. Default: owner
	* @param repos_sort Can be one of created, updated, pushed, full_name. Default: full_name
	* @param repos_direction Can be one of asc or desc. Default: when using full_name: asc, otherwise desc
	*/
	function repositories (
		git_account					varchar2
		, repos_type 				varchar2 default 'owner'
		, repos_sort				varchar2 default 'full_name'
		, repos_direction			varchar2 default 'asc'
	)
	return github.call_result;

	/** Edit an existing repository
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name	The name of the repository
	* @param description A short description of the repository
	* @param homepage A URL with more information about the repository
	* @param private Either true to make the repository private, or false to make it public. Creating private repositories requires a paid GitHub account. Default: false
	* @param has_issues Either true to enable issues for this repository, false to disable them. Default: true
	* @param has_wiki Either true to enable the wiki for this repository, false to disable it. Default: true
	* @param has_downloads Either true to enable downloads for this repository, false to disable them. Default: true
	* @param default_branch Updates the default branch for this repository.
	*/
	procedure repos_edit (
		git_account					varchar2
		, repos_name				varchar2
		, description				varchar2 default null
		, homepage					varchar2 default null
		, private 					boolean default false
		, has_issues				boolean default true
		, has_wiki					boolean default true
		, has_downloads				boolean default true
		, default_branch 			varchar2 default null
	);

	/** List contributors to the specified repository, sorted by the number of commits per contributor in descending order.
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @param anon Set to 1 or true to include anonymous contributors in results.
	* @return 
	*/
	function repos_contributors (
		git_account					varchar2
		, repos_name				varchar2
		, anon 						varchar2 default '1'
	)
	return github.call_result;

	/** List languages for the specified repository. The value on the right of a language is the number of bytes of code written in that language.
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @return Languages used
	*/
	function repos_languages (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result;

	/** List teams for the specified repository
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @return Teams in the repository
	*/
	function repos_teams (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result;

	/** List tags for the specified repository
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @return Tags in the repository
	*/
	function repos_tags (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result;

	/** List branches for the specified repository
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @return Branches in the repository
	*/
	function repos_branches (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result;

	/** Get specific branch in repository
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	* @return Branch details of specified branch
	*/
	function repos_branch_get (
		git_account					varchar2
		, repos_name				varchar2
		, branch 					varchar2
	)
	return github.call_result;

	/** Deleting a repository requires admin access. If OAuth is used, the delete_repo scope is required.
	* @author Morten Egan
	* @param git_account The owner of the repository
	* @param repos_name The name of the repository
	*/
	procedure repos_delete (
		git_account					varchar2
		, repos_name				varchar2
	);


end github_repos;
/