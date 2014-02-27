create or replace package body github_issues_assignees

as

	function list_assignees (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/assignees', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_assignees;

	function check_assignee (
		git_account					varchar2
		, repos_name				varchar2
		, assignee 					varchar2
	)
	return boolean

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/assignees/' || assignee, 'GET');

		github.talk(
			github_account => git_account
		);

		if github.github_call_status_code = 204 then
			return true;
		else
			return false;
		end if;

	end check_assignee;

end github_issues_assignees;
/