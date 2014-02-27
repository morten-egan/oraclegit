create or replace package body github_repos_releases

as

	function list_releases (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/releases', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_releases;

	function get_release (
		git_account					varchar2
		, repos_name				varchar2
		, release_id				number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/releases/' || release_id, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

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

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/releases', 'POST');

		github.github_call_request.call_json.put('tag_name', tag_name);
		github.github_call_request.call_json.put('target_commitish', target_commitish);
		if name is not null then
			github.github_call_request.call_json.put('name', name);
		end if;
		if body is not null then
			github.github_call_request.call_json.put('body', body);
		end if;
		github.github_call_request.call_json.put('draft', draft);
		github.github_call_request.call_json.put('prerelease', prerelease);

		github.talk(
			github_account => git_account
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

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/releases/' || release_id, 'PATCH');

		if tag_name is not null then
			github.github_call_request.call_json.put('tag_name', tag_name);
		end if;
		if target_commitish is not null then
			github.github_call_request.call_json.put('target_commitish', target_commitish);
		end if;
		if name is not null then
			github.github_call_request.call_json.put('name', name);
		end if;
		if body is not null then
			github.github_call_request.call_json.put('body', body);
		end if;
		github.github_call_request.call_json.put('draft', draft);
		github.github_call_request.call_json.put('prerelease', prerelease);

		github.talk(
			github_account => git_account
		);

	end edit_release;

	procedure delete_release (
		git_account					varchar2
		, repos_name				varchar2
		, release_id				number
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/releases/' || release_id, 'DELETE');

		github.talk(
			github_account => git_account
		);

	end delete_release;

end github_repos_releases;
/