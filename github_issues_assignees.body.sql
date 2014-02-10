create or replace package body github_issues_assignees

as

	function list_assignees (
		git_account					varchar2
		, repos_name				varchar2
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/assignees';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end list_assignees;

	function check_assignee (
		git_account					varchar2
		, repos_name				varchar2
		, assignee 					varchar2
	)
	return boolean

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/assignees/' || assignee;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		if github.github_call_status_code = 204 then
			return true;
		else
			return false;
		end if;

	end check_assignee;

end github_issues_assignees;
/