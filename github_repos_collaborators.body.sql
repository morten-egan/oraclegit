create or replace package body github_repos_collaborators

as

	function list_collaborators (
		git_account					varchar2
		, repos_name				varchar2
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/collaborators';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end list_collaborators;

	function check_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	)
	return boolean

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/collaborators/' || collaborator;
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

	end check_collaborator;

	procedure add_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/collaborators/' || collaborator;
		github_api_endpoint_method	varchar2(100) := 'PUT';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

	end add_collaborator;

	procedure remove_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/collaborators/' || collaborator;
		github_api_endpoint_method	varchar2(100) := 'DELETE';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

	end remove_collaborator;

end github_repos_collaborators;
/