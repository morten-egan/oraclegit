create or replace package body github_issues_comments

as

	function list_issue_comments (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id					number
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/comments';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end list_issue_comments;

	function list_repository_comments (
		git_account					varchar2
		, repos_name				varchar2
		, sort 						varchar2 default 'created'
		, direction					varchar2 default 'asc'
		, since						varchar2 default null
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/comments';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		if sort is not null then
			github_api_json := json.addattr(github_api_json, 'sort', sort);
		end if;
		if direction is not null then
			github_api_json := json.addattr(github_api_json, 'direction', direction);
		end if;
		if since is not null then
			github_api_json := json.addattr(github_api_json, 'since', since);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

		return github.github_api_parsed_result;

	end list_repository_comments;

	function get_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/comments/' || comment_id;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end get_comment;

	procedure create_comment (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id					number
		, body						varchar2
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/comments';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'body', body);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end create_comment;

	procedure edit_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
		, body						varchar2
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/comments/' || comment_id;
		github_api_endpoint_method	varchar2(100) := 'PATCH';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'body', body);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end edit_comment;

	procedure delete_comment (
		git_account					varchar2
		, repos_name				varchar2
		, comment_id				number
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/comments/' || comment_id;
		github_api_endpoint_method	varchar2(100) := 'DELETE';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

	end delete_comment;

end github_issues_comments;
/