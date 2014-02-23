create or replace package body github

as

	-- Default variables
	def_github_api_location		varchar2(4000) := 'https://api.github.com'; 

	-- Session variables
	session_github_password		varchar2(4000) := null;
	session_github_username		varchar2(4000) := null;
	session_wallet_location		varchar2(4000) := null;
	session_wallet_password		varchar2(4000) := null;

	function get_session_github_user
	return varchar2
	
	as

	begin

		return session_github_username;

	end get_session_github_user;

	procedure set_default_parameter (
		parameter_name			in 			varchar2
		, parameter_value 		in 			varchar2
	)

	as

		up_parm					varchar2(4000) := upper(parameter_name);

	begin

		if up_parm = 'DEF_GITHUB_API_LOCATION' then
			def_github_api_location := parameter_value;
		end if;

	end set_default_parameter; 

	procedure set_session_wallet (
		wallet_location			in 			varchar2
		, wallet_password 		in 			varchar2 default null
	)

	as

	begin

		session_wallet_location := wallet_location;
		session_wallet_password := wallet_password;

	end set_session_wallet;

	procedure set_logon_info (
		github_username 		in 			varchar2
		, github_password 		in 			varchar2
	)

	as

	begin

		session_github_username := github_username;
		session_github_password := github_password;

	end set_logon_info;

	function encode64_clob(
		content 				in 			clob
	) 
	return clob 

	is
		--the chunk size must be a multiple of 48
		chunksize 				integer := 576;
		place 					integer := 1;
		file_size 				integer;
		temp_chunk 				varchar(4000);
		out_clob 				clob;
	begin
		file_size := length(content);
		
		while (place <= file_size) loop
		       temp_chunk := substr(content, place, chunksize);
		       out_clob := out_clob  || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(temp_chunk)));
		       place := place + chunksize;
		end loop;

		-- Ok, so github does not like 10|13 characters in their base64??
		return replace(replace(out_clob, chr(10)), chr(13));
	end encode64_clob;

	function decode64_clob (
		content 				in 			clob
	)
	return clob

	as

		out_clob				clob;

	begin

		return out_clob;

	end decode64_clob;

	function github_committer_hash
	return json.jsonstructobj

	as

		committer 					json.jsonstructobj;

	begin

		json.newjsonobj(committer);
		committer := json.addattr(committer, 'name', user);
		committer := json.addattr(committer, 'email', 'user.' || user || '@' || sys_context('USERENV', 'DB_NAME') || '.db');
		json.closejsonobj(committer);

		return committer;

	end github_committer_hash;

	procedure parse_github_raw_response

	as

		arr_count					number := 0;
		arr_fixed_json				json.jsonstructobj;
		final_json					json.jsonstructobj;

	begin

		-- Because of some bugs in the json pacakge, we need first to add to
		-- all occurrences of booleans, an extra json key value, or else the parse
		-- will fail.
		github_api_raw_result := replace(github_api_raw_result, '"site_admin":true', '"site_admin":true,"t1":"t1"');
		github_api_raw_result := replace(github_api_raw_result, '"site_admin":false', '"site_admin":false,"t1":"t1"');
		github_api_raw_result := replace(github_api_raw_result, '"pull":true', '"pull":true,"t1":"t1"');
		github_api_raw_result := replace(github_api_raw_result, '"pull":false', '"pull":false,"t1":"t1"');
		github_api_raw_result := replace(github_api_raw_result, '"due_on":null', '"due_on":null,"t1":"t1"');

		arr_fixed_json := json.string2json(github_api_raw_result);
		-- Now for the parse itself, we need to parse differently if the response is an array
		-- of json objects or if it is a single json object.
		if substr(github_api_raw_result, 1, 1) = '[' then
			-- This is an array of json objects parse different then normal.
			dbms_output.put_line('Fixing array json');
			json.getJsonObjFromJsonObjArr(arr_fixed_json, arr_count, final_json);
			github_response_result.result_type := 'ARRAY_JSON';
			github_response_result.result_count := arr_count;
			github_response_result.result := final_json;
		else
			github_response_result.result_type := 'SINGLE_JSON';
			github_response_result.result := arr_fixed_json;
		end if;
		
		-- For backwards compatibility
		github_api_parsed_result := arr_fixed_json;

	end parse_github_raw_response;

	procedure talk (
		github_account				in			varchar2
		, api_endpoint				in			varchar2
		, endpoint_method			in			varchar2
		, api_data					in			clob default null
	)

	as

		github_request				utl_http.req;
		github_response				utl_http.resp;
		github_result_piece			varchar2(32000);

		github_header_name			varchar2(4000);
		github_header_value			varchar2(4000);


	begin

		-- Always reset result
		github.github_api_raw_result := null;

		-- dbms_output.put_line('API data: ' || api_data);

		-- Extended error checking
		utl_http.set_response_error_check(
			enable => true
		);
		utl_http.set_detailed_excp_support(
			enable => true
		);

		utl_http.set_wallet(
			session_wallet_location
			, session_wallet_password
		);

		-- We set follow redirects to 1.
		-- Those github services that sends you to a next destination
		-- will be handled in their own procedure
		utl_http.set_follow_redirect (
			max_redirects => 1
		);

		-- dbms_output.put_line('Calling: ' || def_github_api_location || api_endpoint);
		-- Start the request
		github_request := utl_http.begin_request(
			url => def_github_api_location || api_endpoint
			, method => endpoint_method
		);

		-- Set authentication and headers
		utl_http.set_authentication(
			r => github_request
			, username => session_github_username
			, password => session_github_password
			, scheme => 'Basic'
			, for_proxy => false
		);
		utl_http.set_header(
			r => github_request
			, name => 'User-Agent'
			, value => github_account
		);

		-- Method specific headers
		if (api_data is not null) then
			utl_http.set_header(
				r => github_request
				, name => 'Content-Type'
				, value => 'application/x-www-form-urlencoded'
			);
			utl_http.set_header(
				r => github_request
				, name => 'Content-Length'
				, value => length(api_data)
			);
			-- Write the content
			utl_http.write_text (
				r => github_request
				, data => api_data
			);
		end if;

		github_response := utl_http.get_response (
			r => github_request
		);

		-- Should handle exceptions here
		github_call_status_code := github_response.status_code;
		github_call_status_reason := github_response.reason_phrase;

		-- Load header data before reading body
		for i in 1..utl_http.get_header_count(r => github_response) loop
			utl_http.get_header(
				r => github_response
				, n => i
				, name => github_header_name
				, value => github_header_value
			);
			github_response_headers(github_header_name) := github_header_value;
		end loop;

		-- Collect response and put into api_result
		begin
			loop
				utl_http.read_text (
					r => github_response
					, data => github_result_piece
				);
				github_api_raw_result := github_api_raw_result || github_result_piece;
			end loop;

			exception
				when utl_http.end_of_body then
					null;
				when others then
					raise;
		end;

		utl_http.end_response(
			r => github_response
		);

		-- Parse output to github_utl readable format 
		-- github_api_parsed_result := json.string2json(github_api_raw_result);
		parse_github_raw_response;

		exception
			when utl_http.http_client_error then
				null;
			when others then
				raise;

	end talk;

	function listen (
		fetch_url					in 			varchar2
	)
	return clob

	as

		fetched_data				clob;
		github_listen_request		utl_http.req;
		github_listen_response		utl_http.resp;
		github_listen_result_piece	varchar2(32000);

	begin

		utl_http.set_wallet(
			session_wallet_location
			, session_wallet_password
		);

		github_listen_request := utl_http.begin_request(
			url => fetch_url
			, method => 'GET'
		);

		-- Set authentication and headers
		utl_http.set_authentication(
			r => github_listen_request
			, username => session_github_username
			, password => session_github_password
			, scheme => 'Basic'
			, for_proxy => false
		);
		utl_http.set_header(
			r => github_listen_request
			, name => 'User-Agent'
			, value => 'github_utl oracle package'
		);

		github_listen_response := utl_http.get_response (
			r => github_listen_request
		);

		-- Should handle exceptions here
		github_call_status_code := github_listen_response.status_code;
		github_call_status_reason := github_listen_response.reason_phrase;

		begin
			loop
				utl_http.read_text (
					r => github_listen_response
					, data => github_listen_result_piece
				);
				fetched_data := fetched_data || github_listen_result_piece;
			end loop;

			exception
				when utl_http.end_of_body then
					null;
				when others then
					raise;
		end;

		utl_http.end_response(
			r => github_listen_response
		);

		return fetched_data;

		exception
			when utl_http.http_client_error then
				dbms_output.put_line(UTL_HTTP.GET_DETAILED_SQLERRM);
				raise;
			when others then
				raise;

	end listen;

end github;
/