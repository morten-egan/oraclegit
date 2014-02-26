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

	begin

		if use_org then
			github.init_talk('/orgs/' || org_name || '/repos', 'POST');
		else
			github.init_talk('/user/repos', 'POST');
		end if;

		github.github_call_request.call_json.put('name', repos_name);
		if description is not null then
			github.github_call_request.call_json.put('description', description);
		end if;
		if homepage is not null then
			github.github_call_request.call_json.put('homepage', homepage);
		end if;
		github.github_call_request.call_json.put('private', private);
		github.github_call_request.call_json.put('has_issues', has_issues);
		github.github_call_request.call_json.put('has_wiki', has_wiki);
		github.github_call_request.call_json.put('has_downloads', has_downloads);
		if team_id is not null then
			github.github_call_request.call_json.put('team_id', team_id);
		end if;
		github.github_call_request.call_json.put('auto_init', auto_init);
		if gitignore_template is not null then
			github.github_call_request.call_json.put('gitignore_template', gitignore_template);
		end if;

		github.talk(
			github_account => git_account
		);

	end repos_create;

	function repos_get (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account ||'/' || repos_name, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end repos_get;

	function repositories (
		git_account					varchar2
		, repos_type 				varchar2 default 'owner'
		, repos_sort				varchar2 default 'full_name'
		, repos_direction			varchar2 default 'asc'
	)
	return github.call_result

	as

	begin

		github.init_talk('/users/' || git_account ||'/repos', 'GET');

		github.github_call_request.call_json.put('type', repos_type);
		github.github_call_request.call_json.put('sort', repos_sort);
		github.github_call_request.call_json.put('direction', repos_direction);

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end repositories;

	procedure repos_edit (
		git_account					varchar2
		, repos_name				varchar2
		, description				varchar2 default null
		, homepage					varchar2 default null
		, private 					boolean default false
		, has_issues				boolean default true
		, has_wiki					boolean default true
		, has_downloads				boolean default true
		, default_branch 			varchar2 default null
	)

	as

	begin

		github.init_talk('/repos/' || git_account ||'/' || repos_name, 'PATCH');

		github.github_call_request.call_json.put('name', repos_name);
		if description is not null then
			github.github_call_request.call_json.put('description', description);
		end if;
		if homepage is not null then
			github.github_call_request.call_json.put('homepage', homepage);
		end if;
		github.github_call_request.call_json.put('private', private);
		github.github_call_request.call_json.put('has_issues', has_issues);
		github.github_call_request.call_json.put('has_wiki', has_wiki);
		github.github_call_request.call_json.put('has_downloads', has_downloads);
		if default_branch is not null then
			github.github_call_request.call_json.put('default_branch', default_branch);
		end if;

		github.talk(
			github_account => git_account
		);

	end repos_edit;

	function repos_contributors (
		git_account					varchar2
		, repos_name				varchar2
		, anon 						varchar2 default '1'
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/contributors', 'GET');

		github.github_call_request.call_json.put('anon', anon);

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end repos_contributors;

	function repos_languages (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/languages', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end repos_languages;

	function repos_teams (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/teams', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end repos_teams;

	function repos_tags (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/tags', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end repos_tags;

	function repos_branches (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/branches', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end repos_branches;

	function repos_branch_get (
		git_account					varchar2
		, repos_name				varchar2
		, branch 					varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/branches/' || branch, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end repos_branch_get;

	procedure repos_delete (
		git_account					varchar2
		, repos_name				varchar2
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name, 'DELETE');

		github.talk(
			github_account => git_account
		);

	end repos_delete;

end github_repos;
/