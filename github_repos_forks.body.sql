create or replace package body github_repos_forks

as

	function list_forks (
		git_account					varchar2
		, repos_name				varchar2
		, sort						varchar2 default 'newest'
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/forks', 'GET');

		github.github_call_request.call_json.put('sort', sort);

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_forks;

	procedure create_fork (
		git_account					varchar2
		, repos_name				varchar2
		, organization 				varchar2 default null
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/forks', 'POST');

		github.github_call_request.call_json.put('organization', organization);

		github.talk(
			github_account => git_account
		);

	end create_fork;

end github_repos_forks;
/