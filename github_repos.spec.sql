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

	/** Return information about repository.
	* @author Morten Egan
	* @param git_account The account owner of the repository
	* @param repos_name The name of the repository to get
	*/
	function repos_get (
		git_account					varchar2
		, repos_name				varchar2
	)
	return json.jsonstructobj;

	/** Repository list
	* @author Morten Egan
	* @param 
	*/
	function repositories (
		git_account					varchar2
		, repos_type 				varchar2 default 'owner'
		, repos_sort				varchar2 default 'full_name'
		, repos_direction			varchar2 default 'asc'
	)
	-- return json.jsonstructobj;
	return number;

end github_repos;
/