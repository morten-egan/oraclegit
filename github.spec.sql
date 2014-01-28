create or replace package github

as

	/** Github api communication
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	github_api_raw_result			clob;
	github_api_parsed_result		json.jsonstructobj;

	/** Send request to github api
	* @author Morten Egan
	* @param github_account The account to use as api user
	* @param api_endpoint The API endpoint to use
	* @param endpoint_method HTTP method
	* @param api_data The data package to the endpoint
	* @param api_result The result from the API call
	*/
	procedure talk (
		github_account				in			varchar2
		, api_endpoint				in			varchar2
		, endpoint_method			in			varchar2
		, api_data					in			clob
	);

end github;
/