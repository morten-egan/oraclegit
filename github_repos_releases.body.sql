create or replace package body github_repos_releases

as

	function list_releases (
		git_account					varchar2
		, repos_name				varchar2
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/releases';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end list_releases;

	function get_release (
		git_account					varchar2
		, repos_name				varchar2
		, release_id				number
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/releases/' || release_id;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end get_release;

	procedure create_release (
		git_account					varchar2
		, repos_name				varchar2
		, tag_name 					varchar2
		, target_commitish			varchar2 default 'master'
		, name 						varchar2 default null
		, body 						varchar2 default null
		, draft						boolean default false
		, prerelease				boolean default false
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/releases';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'tag_name', tag_name);
		github_api_json := json.addattr(github_api_json, 'target_commitish', target_commitish);
		if name is not null then
			github_api_json := json.addattr(github_api_json, 'name', name);
		end if;
		if body is not null then
			github_api_json := json.addattr(github_api_json, 'body', body);
		end if;
		github_api_json := json.addattr(github_api_json, 'draft', draft);
		github_api_json := json.addattr(github_api_json, 'prerelease', prerelease);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end create_release;

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
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/releases/' || release_id;
		github_api_endpoint_method	varchar2(100) := 'PATCH';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		if tag_name is not null then
			github_api_json := json.addattr(github_api_json, 'tag_name', tag_name);
		end if;
		if target_commitish is not null then
			github_api_json := json.addattr(github_api_json, 'target_commitish', target_commitish);
		end if;
		if name is not null then
			github_api_json := json.addattr(github_api_json, 'name', name);
		end if;
		if body is not null then
			github_api_json := json.addattr(github_api_json, 'body', body);
		end if;
		github_api_json := json.addattr(github_api_json, 'draft', draft);
		github_api_json := json.addattr(github_api_json, 'prerelease', prerelease);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end edit_release;

	procedure delete_release (
		git_account					varchar2
		, repos_name				varchar2
		, release_id				number
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/releases/' || release_id;
		github_api_endpoint_method	varchar2(100) := 'DELETE';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

	end delete_release;

end github_repos_releases;
/