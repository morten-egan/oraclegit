create or replace package body github_issues_comments

as

	function list_issue_comments (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id					number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/comments', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_issue_comments;

	function list_repository_comments (
		git_account					varchar2
		, repos_name				varchar2
		, sort 						varchar2 default 'created'
		, direction					varchar2 default 'asc'
		, since						varchar2 default null
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/comments', 'GET');

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

	end list_repository_comments;

	function get_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/comments/' || comment_id, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_comment;

	procedure create_comment (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id					number
		, body						varchar2
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/comments', 'POST');

		github.github_call_request.call_json.put('body', body);

		github.talk(
			github_account => git_account
		);

	end create_comment;

	procedure edit_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
		, body						varchar2
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/comments/' || comment_id, 'PATCH');

		github.github_call_request.call_json.put('body', body);

		github.talk(
			github_account => git_account
		);

	end edit_comment;

	procedure delete_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/comments/' || comment_id, 'DELETE');

		github.talk(
			github_account => git_account
		);

	end delete_comment;

end github_issues_comments;
/