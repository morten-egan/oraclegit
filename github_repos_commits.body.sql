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
	return github.call_result

	as


	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/commits', 'GET');

		if sha is not null then
			github.github_call_request.call_json.put('sha', sha);
		end if;
		if path is not null then
			github.github_call_request.call_json.put('path', path);
		end if;
		if author is not null then
			github.github_call_request.call_json.put('author', author);
		end if;
		if since is not null then
			github.github_call_request.call_json.put('since', since);
		end if;
		if until is not null then
			github.github_call_request.call_json.put('until', until);
		end if;

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_repos_commits;

	function get_commit (
		git_account					varchar2
		, repos_name				varchar2
		, sha 						varchar2
	)
	return github.call_result

	as


	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/commits/' || sha, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_commit;

	function compare_commits (
		git_account					varchar2
		, repos_name				varchar2
		, base 						varchar2
		, head 						varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/compare/' || base || '...' || head, 'GET');

		github.github_call_request.call_json.put('base', base);
		github.github_call_request.call_json.put('head', head);

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end compare_commits;

end github_repos_commits;
/