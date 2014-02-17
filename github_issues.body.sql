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

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'title', title);
		if body is not null then
			github_api_json := json.addattr(github_api_json, 'body', body);
		end if;
		if assignee is not null then
			github_api_json := json.addattr(github_api_json, 'assignee', assignee);
		end if;
		if milestone is not null then
			github_api_json := json.addattr(github_api_json, 'milestone', milestone);
		end if;
		if labels is not null then
			github_api_json := json.addattr(github_api_json, 'labels', labels);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
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

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_number;
		github_api_endpoint_method	varchar2(100) := 'PATCH';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'title', title);
		if body is not null then
			github_api_json := json.addattr(github_api_json, 'body', body);
		end if;
		if assignee is not null then
			github_api_json := json.addattr(github_api_json, 'assignee', assignee);
		end if;
		if state is not null then
			github_api_json := json.addattr(github_api_json, 'state', state);
		end if;
		if milestone is not null then
			github_api_json := json.addattr(github_api_json, 'milestone', milestone);
		end if;
		if labels is not null then
			github_api_json := json.addattr(github_api_json, 'labels', labels);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end edit_issue;

	function get_single_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_number				number
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_number;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

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

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		if milestone is not null then
			github_api_json := json.addattr(github_api_json, 'milestone', milestone);
		end if;
		if state is not null then
			github_api_json := json.addattr(github_api_json, 'state', state);
		end if;
		if assignee is not null then
			github_api_json := json.addattr(github_api_json, 'assignee', assignee);
		end if;
		if creator is not null then
			github_api_json := json.addattr(github_api_json, 'creator', creator);
		end if;
		if mentioned is not null then
			github_api_json := json.addattr(github_api_json, 'mentioned', mentioned);
		end if;
		if labels is not null then
			github_api_json := json.addattr(github_api_json, 'labels', labels);
		end if;
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

		return github.github_response_result;

	end get_repository_issues;

end github_issues;
/