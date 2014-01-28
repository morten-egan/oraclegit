create or replace package body github

as

	function get_account_passwd (
		github_account				in			varchar2
	)
	return varchar2

	as

		pass_out					varchar2(500) := null;

	begin

		select github_password
		into pass_out
		from github_account
		where upper(github_username) = upper(github_account);

		return pass_out;

	end get_account_passwd;

	procedure talk (
		github_account				in			varchar2
		, api_endpoint				in			varchar2
		, endpoint_method			in			varchar2
		, api_data					in			clob
	)

	as

		github_request				utl_http.req;
		github_response				utl_http.resp;
		github_result_piece			varchar2(32000);


	begin

		-- Extended error checking
		utl_http.set_response_error_check(
			enable => true
		);
		utl_http.set_detailed_excp_support(
			enable => true
		);

		utl_http.set_wallet(
			oraclegit.get_oraclegit_env('github_wallet_location')
			, oraclegit.get_oraclegit_env('github_wallet_passwd')
		);

		-- Start the request
		github_request := utl_http.begin_request(
			url => oraclegit.get_oraclegit_env('github_api_location') || api_endpoint
			, method => endpoint_method
		);

		-- Set authentication and headers
		utl_http.set_authentication(
			r => github_request
			, username => github_account
			, password => get_account_passwd(github_account)
			, scheme => 'Basic'
			, for_proxy => false
		);
		utl_http.set_header(
			r => github_request
			, name => 'User-Agent'
			, value => github_account
		);

		-- Method specific headers
		if upper(endpoint_method) = 'POST' or upper(endpoint_method) = 'PUT' then
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

		github_api_parsed_result := json.string2json(github_api_raw_result);

		-- dbms_output.put_line(github_api_raw_result);

		exception
			when others then
				dbms_output.put_line(UTL_HTTP.GET_DETAILED_SQLERRM);
				raise;

	end talk;

end github;
/