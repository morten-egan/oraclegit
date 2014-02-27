create or replace package body github_issues_events

as

	function list_issue_events (
		git_account					varchar2
		, repos_name				varchar2
		, issue_number 				number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_number || '/events', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_issue_events;

	function list_repos_events (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/events', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_repos_events;

	function get_event (
		git_account					varchar2
		, repos_name				varchar2
		, event_id					number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/events/' || event_id, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_event;

end github_issues_events;
/