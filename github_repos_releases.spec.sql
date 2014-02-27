create or replace package github_repos_releases

as

	/** Interface to github repositories releases API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List releases for a repository. Users with push access to the repository will receive all releases (i.e., published releases and draft releases). Users with pull access will receive published releases only.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @return This returns a list of releases, which does not include regular Git tags that have not been associated with a release.
	*/
	function list_releases (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result;

	/** Get a single release
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param release_id The release ID
	* @return JSON document of release.
	*/
	function get_release (
		git_account					varchar2
		, repos_name				varchar2
		, release_id				number
	)
	return github.call_result;

	/** Create a release. Users with push access to the repository can create a release.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param tag_name The name of the tag.
	* @param target_commitish Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Unused if the Git tag already exists. Default: the repository’s default branch (usually master).
	* @param name The name of the release.
	* @param body Text describing the contents of the tag.
	* @param draft true to create a draft (unpublished) release, false to create a published one. Default: false
	* @param prerelease true to identify the release as a prerelease. false to identify the release as a full release. Default: false
	*/
	procedure create_release (
		git_account					varchar2
		, repos_name				varchar2
		, tag_name 					varchar2
		, target_commitish			varchar2 default 'master'
		, name 						varchar2 default null
		, body 						varchar2 default null
		, draft						boolean default false
		, prerelease				boolean default false
	);

	/** Edit a release. Users with push access to the repository can edit a release.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param release_id The ID of the release.
	* @param tag_name The name of the tag.
	* @param target_commitish Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Unused if the Git tag already exists. Default: the repository’s default branch (usually master).
	* @param name The name of the release.
	* @param body Text describing the contents of the tag.
	* @param draft true to create a draft (unpublished) release, false to create a published one. Default: false
	* @param prerelease true to identify the release as a prerelease. false to identify the release as a full release. Default: false
	*/
	procedure edit_release (
		git_account					varchar2
		, repos_name				varchar2
		, release_id				number
		, tag_name 					varchar2 default null
		, target_commitish			varchar2 default null
		, name 						varchar2 default null
		, body 						varchar2 default null
		, draft						boolean default false
		, prerelease				boolean default false
	);

	/** Delete a release. Users with push access to the repository can delete a release.
	* @author Morten Egan
	* @param git_account The account that owns the repository
	* @param repos_name The name of the repository
	* @param release_id The ID of the release.
	*/
	procedure delete_release (
		git_account					varchar2
		, repos_name				varchar2
		, release_id				number
	);

end github_repos_releases;
/