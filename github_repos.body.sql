create or replace package body github_repos

as

	procedure repos_create (
		git_account					varchar2
		, repos_name				varchar2
		, description				varchar2 default null
		, homepage					varchar2 default null
		, private 					boolean default false
		, has_issues				boolean default true
		, has_wiki					boolean default true
		, has_downloads				boolean default true
		, team_id					number default null
		, auto_init					boolean default false
		, gitignore_template		varchar2 default null
		, use_org					boolean default false
		, org_name					varchar2 default null
	)

	as

		github_api_endpoint			varchar2(4000) := '/user/repos';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_api_json	json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'name', repos_name);
		if description is not null then
			github_api_json := json.addattr(github_api_json, 'description', description);
		end if;
		if homepage is not null then
			github_api_json := json.addattr(github_api_json, 'homepage', homepage);
		end if;
		github_api_json := json.addattr(github_api_json, 'private', private);
		github_api_json := json.addattr(github_api_json, 'has_issues', has_issues);
		github_api_json := json.addattr(github_api_json, 'has_wiki', has_wiki);
		github_api_json := json.addattr(github_api_json, 'has_downloads', has_downloads);
		if team_id is not null then
			github_api_json := json.addattr(github_api_json, 'team_id', team_id);
		end if;
		github_api_json := json.addattr(github_api_json, 'auto_init', auto_init);
		if gitignore_template is not null then
			github_api_json := json.addattr(github_api_json, 'gitignore_template', gitignore_template);
		end if;
		json.closejsonobj(github_api_json);

		if use_org then
			github_api_endpoint := '/orgs/' || org_name || '/repos';
		end if;

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end repos_create;

	function repos_get (
		git_account					varchar2
		, repos_name				varchar2
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account ||'/' || repos_name;
		github_api_endpoint_method	varchar2(100) := 'GET';

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end repos_get;

	function repositories (
		git_account					varchar2
		, repos_type 				varchar2 default 'owner'
		, repos_sort				varchar2 default 'full_name'
		, repos_direction			varchar2 default 'asc'
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/users/' || git_account ||'/repos';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'type', repos_type);
		github_api_json := json.addattr(github_api_json, 'sort', repos_sort);
		github_api_json := json.addattr(github_api_json, 'direction', repos_direction);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

		return github.github_api_parsed_result;

	end repositories;

end github_repos;
/