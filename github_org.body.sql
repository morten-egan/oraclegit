create or replace package body github_org

as

	function list_user_orgs (
		git_account					varchar2
	)
	return github.call_result

	as

		github_api_endpoint			varchar2(4000) := '/users/' || git_account || '/orgs';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_response_result;

	end list_user_orgs;

	function get_org (
		org_name					varchar2
	)
	return github.call_result

	as

		github_api_endpoint			varchar2(4000) := '/orgs/' || org_name;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_response_result;

	end get_org;

	procedure edit_org (
		org_name					varchar2
		, billing_email				varchar2 default null
		, company					varchar2 default null
		, email 					varchar2 default null
		, location					varchar2 default null
		, name 						varchar2 default null
	)

	as

		github_api_endpoint			varchar2(4000) := '/orgs/' || org_name;
		github_api_endpoint_method	varchar2(100) := 'PATCH';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		if billing_email is not null then
			github_api_json := json.addattr(github_api_json, 'billing_email', billing_email);
		end if;
		if company is not null then
			github_api_json := json.addattr(github_api_json, 'company', company);
		end if;
		if email is not null then
			github_api_json := json.addattr(github_api_json, 'email', email);
		end if;
		if location is not null then
			github_api_json := json.addattr(github_api_json, 'location', location);
		end if;
		if name is not null then
			github_api_json := json.addattr(github_api_json, 'name', name);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end edit_org;

end github_org;
/