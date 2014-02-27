create or replace package body github_issues

as

	procedure create_issue (
		git_account					varchar2
		, repos_name				varchar2
		, title						varchar2
		, body						clob default null
		, assignee					varchar2 default null
		, milestone 				number default null
		, labels 					varchar2 default null
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues', 'POST');

		github.github_call_request.call_json.put('title', title);
		if body is not null then
			github.github_call_request.call_json.put('body', body);
		end if;
		if assignee is not null then
			github.github_call_request.call_json.put('assignee', assignee);
		end if;
		if milestone is not null then
			github.github_call_request.call_json.put('milestone', milestone);
		end if;
		if labels is not null then
			github.github_call_request.call_json.put('labels', labels);
		end if;

		github.talk(
			github_account => git_account
		);

	end create_issue;

	procedure edit_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_number				number
		, title						varchar2
		, body						clob default null
		, assignee					varchar2 default null
		, state 					varchar2 default null
		, milestone 				number default null
		, labels 					varchar2 default null
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_number, 'PATCH');

		github.github_call_request.call_json.put('title', title);
		if body is not null then
			github.github_call_request.call_json.put('body', body);
		end if;
		if assignee is not null then
			github.github_call_request.call_json.put('assignee', assignee);
		end if;
		if state is not null then
			github.github_call_request.call_json.put('state', state);
		end if;
		if milestone is not null then
			github.github_call_request.call_json.put('milestone', milestone);
		end if;
		if labels is not null then
			github.github_call_request.call_json.put('labels', labels);
		end if;

		github.talk(
			github_account => git_account
		);

	end edit_issue;

	function get_single_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_number				number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_number, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_single_issue;

	function get_repository_issues (
		git_account					varchar2
		, repos_name				varchar2
		, milestone 				varchar2 default null
		, state						varchar2 default null
		, assignee					varchar2 default null
		, creator					varchar2 default null
		, mentioned					varchar2 default null
		, labels 					varchar2 default null
		, sort 						varchar2 default null
		, direction 				varchar2 default null
		, since 					varchar2 default null
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues', 'GET');

		if milestone is not null then
			github.github_call_request.call_json.put('milestone', milestone);
		end if;
		if state is not null then
			github.github_call_request.call_json.put('state', state);
		end if;
		if assignee is not null then
			github.github_call_request.call_json.put('assignee', assignee);
		end if;
		if creator is not null then
			github.github_call_request.call_json.put('creator', creator);
		end if;
		if mentioned is not null then
			github.github_call_request.call_json.put('mentioned', mentioned);
		end if;
		if labels is not null then
			github.github_call_request.call_json.put('labels', labels);
		end if;
		if sort is not null then
			github.github_call_request.call_json.put('sort', sort);
		end if;
		if direction is not null then
			github.github_call_request.call_json.put('direction', direction);
		end if;
		if since is not null then
			github.github_call_request.call_json.put('since', since);
		end if;

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_repository_issues;

end github_issues;
/