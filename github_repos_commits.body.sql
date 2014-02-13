create or replace package body github_repos_commits

as

	function list_repos_commits (
		git_account					varchar2
		, repos_name				varchar2
		, sha 						varchar2 default null
		, path 						varchar2 default null
		, author					varchar2 default null
		, since						varchar2 default null
		, until						varchar2 default null
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/commits';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		if sha is not null then
			github_api_json := json.addattr(github_api_json, 'sha', sha);
		end if;
		if path is not null then
			github_api_json := json.addattr(github_api_json, 'path', path);
		end if;
		if author is not null then
			github_api_json := json.addattr(github_api_json, 'author', author);
		end if;
		if since is not null then
			github_api_json := json.addattr(github_api_json, 'since', since);
		end if;
		if until is not null then
			github_api_json := json.addattr(github_api_json, 'until', until);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

		return github.github_api_parsed_result;

	end list_repos_commits;

	function get_commit (
		git_account					varchar2
		, repos_name				varchar2
		, sha 						varchar2
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/commits/' || sha;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end get_commit;

	function compare_commits (
		git_account					varchar2
		, repos_name				varchar2
		, base 						varchar2
		, head 						varchar2
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/compare/' || base || '...' || head;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'base', base);
		github_api_json := json.addattr(github_api_json, 'head', head);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

		return github.github_api_parsed_result;

	end compare_commits;

end github_repos_commits;
/