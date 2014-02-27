create or replace package body github_issues_milestones

as

	function list_milestones (
		git_account					varchar2
		, repos_name				varchar2
		, state 					varchar2 default 'open'
		, sort 						varchar2 default 'due_date'
		, direction 				varchar2 default 'asc'
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/milestones', 'GET');

		github.github_call_request.call_json.put('state', state);
		github.github_call_request.call_json.put('sort', sort);
		github.github_call_request.call_json.put('direction', direction);

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_milestones;

	function get_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/milestones/' || milestone_id, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_milestone;

	procedure create_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, title						varchar2
		, state						varchar2 default 'open'
		, description				varchar2 default null
		, due_on					varchar2 default null
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/milestones', 'POST');

		github.github_call_request.call_json.put('title', title);
		github.github_call_request.call_json.put('state', state);
		if description is not null then
			github.github_call_request.call_json.put('description', description);
		end if;
		if due_on is not null then
			github.github_call_request.call_json.put('due_on', due_on);
		end if;

		github.talk(
			github_account => git_account
		);

	end create_milestone;

	procedure update_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
		, title						varchar2 default null
		, state						varchar2 default 'open'
		, description				varchar2 default null
		, due_on					varchar2 default null
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/milestones/' || milestone_id, 'PATCH');

		if title is not null then
			github.github_call_request.call_json.put('title', title);
		end if;
		if state is not null then
			github.github_call_request.call_json.put('state', state);
		end if;
		if description is not null then
			github.github_call_request.call_json.put('description', description);
		end if;
		if due_on is not null then
			github.github_call_request.call_json.put('due_on', due_on);
		end if;

		github.talk(
			github_account => git_account
		);

	end update_milestone;

	procedure delete_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/milestones/' || milestone_id, 'DELETE');

		github.talk(
			github_account => git_account
		);

	end delete_milestone;

end github_issues_milestones;
/