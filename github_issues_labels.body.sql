create or replace package body github_issues_labels

as

	function list_repos_labels (
		git_account					varchar2
		, repos_name				varchar2
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/labels';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end list_repos_labels;

	function get_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/labels/' || label;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end get_label;

	procedure create_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
		, color						varchar2
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/labels';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'label', label);
		github_api_json := json.addattr(github_api_json, 'color', color);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end create_label;

	procedure update_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
		, color						varchar2
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/labels/' || label;
		github_api_endpoint_method	varchar2(100) := 'PATCH';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'label', label);
		github_api_json := json.addattr(github_api_json, 'color', color);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end update_label;

	procedure delete_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/labels/' || label;
		github_api_endpoint_method	varchar2(100) := 'DELETE';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end delete_label;

	function list_issue_labels (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end list_issue_labels;

	procedure add_labels_to_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, labels 					json.jsonarray
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.listToJsonArrayString(labels)
		);

	end add_labels_to_issue;

	procedure remove_label_from_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, label 					varchar2
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels/' || label;
		github_api_endpoint_method	varchar2(100) := 'DELETE';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

	end remove_label_from_issue;

	procedure replace_all_labels_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, labels 					json.jsonarray
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels';
		github_api_endpoint_method	varchar2(100) := 'PUT';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.listToJsonArrayString(labels)
		);

	end replace_all_labels_issue;

	procedure remove_labels_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels';
		github_api_endpoint_method	varchar2(100) := 'DELETE';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

	end remove_labels_issue;

	function labels_from_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/milestones/' || milestone_id || '/labels';
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end labels_from_milestone;

end github_issues_labels;
/