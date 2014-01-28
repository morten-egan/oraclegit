create or replace package body github_repos

as

	procedure repos_create (
		git_account					varchar2
		, repos_name				varchar2
		, description				varchar2 default 'OracleGit repository'
		, use_org					boolean default false
		, org_name					varchar2 default null
		, is_private				boolean default false
		, issue_enabled				boolean default true
	)

	as

		github_api_endpoint			varchar2(4000) := '/user/repos';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_create_repos_json	json.jsonstructobj;

	begin

		json.newjsonobj(github_create_repos_json);
		github_create_repos_json := json.addattr(github_create_repos_json, 'name', repos_name);
		github_create_repos_json := json.addattr(github_create_repos_json, 'description', description);
		github_create_repos_json := json.addattr(github_create_repos_json, 'private', is_private);
		github_create_repos_json := json.addattr(github_create_repos_json, 'has_issues', issue_enabled);
		github_create_repos_json := json.addattr(github_create_repos_json, 'auto_init', true);
		json.closejsonobj(github_create_repos_json);

		if use_org then
			github_api_endpoint := '/orgs/' || org_name || '/repos';
		end if;

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_create_repos_json)
		);

		dbms_output.put_line('Repository id: ' || json.getattrvalue(github.github_api_parsed_result, 'id'));

	end repos_create;

end github_repos;
/