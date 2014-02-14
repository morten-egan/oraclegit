create or replace package github_org

as

	/** Interface to github oragnizations API
	* @author Morten Egan
	* @project OracleGit
	* @version 0.1.0
	*/

	/** List User Organizations
	* @author Morten Egan
	* @param git_account The user to list orgs from
	* @return Array of JSON orgs docs
	*/
	function list_user_orgs (
		git_account					varchar2
	)
	return github.call_result;

	/** Get an Organization
	* @author Morten Egan
	* @param org_name The orginazation to get
	* @return JSON doc of requested org
	*/
	function get_org (
		org_name					varchar2
	)
	return github.call_result;

	/** Edit an Organization
	* @author Morten Egan
	* @param org_name The organization to edit
	* @param billing_email Billing email address. This address is not publicized.
	* @param company The company name.
	* @param email The publicly visible email address.
	* @param location The location.
	* @param name The shorthand name of the company.
	*/
	procedure edit_org (
		org_name					varchar2
		, billing_email				varchar2 default null
		, company					varchar2 default null
		, email 					varchar2 default null
		, location					varchar2 default null
		, name 						varchar2 default null
	);

end github_org;
/