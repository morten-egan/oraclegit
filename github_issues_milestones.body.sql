create or replace package body github_issues_milestones

as

	function list_milestones (
		git_account					varchar2
		, repos_name				varchar2
		, state 					varchar2 default 'open'
		, sort 						varchar2 default 'due_date'
		, direction 				varchar2 default 'asc'
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/milestones';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'state', state);
		github_api_json := json.addattr(github_api_json, 'sort', sort);
		github_api_json := json.addattr(github_api_json, 'direction', direction);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

		return github.github_api_parsed_result;

	end list_milestones;

	function get_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/milestones/' || milestone_id;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

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

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/milestones';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'title', title);
		github_api_json := json.addattr(github_api_json, 'state', state);
		if description is not null then
			github_api_json := json.addattr(github_api_json, 'description', description);
		end if;
		if due_on is not null then
			github_api_json := json.addattr(github_api_json, 'due_on', due_on);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
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

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/milestones/' || milestone_id;
		github_api_endpoint_method	varchar2(100) := 'PATCH';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		if title is not null then
			github_api_json := json.addattr(github_api_json, 'title', title);
		end if;
		if state is not null then
			github_api_json := json.addattr(github_api_json, 'state', state);
		end if;
		if description is not null then
			github_api_json := json.addattr(github_api_json, 'description', description);
		end if;
		if due_on is not null then
			github_api_json := json.addattr(github_api_json, 'due_on', due_on);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end update_milestone;

	procedure delete_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/milestones/' || milestone_id;
		github_api_endpoint_method	varchar2(100) := 'DELETE';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

	end delete_milestone;

end github_issues_milestones;
/