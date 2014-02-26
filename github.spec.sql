create or replace package github

as

	/** Github api communication
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	-- Global variables and types
	type call_request is record (
		call_endpoint				varchar2(4000)
		, call_method				varchar2(100)
		, call_json					json
	);
	github_call_request				call_request;

	type call_result is record (
		result_type					varchar2(200)
		, result_count				number
		, result 					json
		, result_list				json_list
	);
	github_response_result			call_result;

	github_api_raw_result			clob;
	github_call_status_code			pls_integer;
	github_call_status_reason		varchar2(256);

	type text_text_arr is table of varchar2(4000) index by varchar2(250);
	type text_num_arr is table of varchar2(2000) index by pls_integer;
	github_response_headers			text_text_arr;
	github_label_list				text_num_arr;

	/** Helper function to base64 encode content
	* @author Morten Egan
	* @param content The data to encode
	* @return The content data as base64
	*/
	function encode64_clob(
		content 				in 			clob
	) 
	return clob;

	/** Set default parameters for your GitHub session, such as API endpoint location and more.
	* @author Morten Egan
	* @param parameter_name The name of the variable to set.
	* @param parameter_value The value of the parameter.
	*/
	procedure set_default_parameter (
		parameter_name			in 			varchar2
		, parameter_value 		in 			varchar2
	);

	/** Set the Oracle wallet location and password
	* @author Morten Egan
	* @param wallet_location The location on the filesystem, excluding filename and trailing slash
	* @param wallet_password Password to the wallet file. If autologin enabled on wallet, this should be null
	*/
	procedure set_session_wallet (
		wallet_location			in 			varchar2
		, wallet_password 		in 			varchar2 default null
	);

	/** Set the account and password for the github session
	* @author Morten Egan
	* @param github_username The GitHub account name
	* @param github_password The password for the github account
	*/
	procedure set_logon_info (
		github_username 		in 			varchar2
		, github_password 		in 			varchar2
	);

	/** Get the current github username set for the session
	* @author Morten Egan
	* @return Current set github username for session
	*/
	function get_session_github_user
	return varchar2;

	/** Create a committer hash for github content and commit calls
	* @author Morten Egan
	* @return A pljson stucture of github committer hash
	*/
	function github_committer_hash
	return json;

	/** Init the call structure
	* @author Morten Egan
	* @param endpoint The API endpoint
	* @param endpoint_method The method of the request
	*/
	procedure init_talk (
		endpoint 					in 			varchar2
		, endpoint_method			in 			varchar2
	);

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
	);

	/** Get clob contents of url
	* @author Morten Egan
	* @param fetch_url The URL to fetch content from
	*/
	function listen (
		fetch_url					in 			varchar2
	)
	return clob;

end github;
/