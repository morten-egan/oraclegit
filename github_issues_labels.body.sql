create or replace package body github_issues_labels

as

	function list_repos_labels (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/labels', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_repos_labels;

	function get_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/labels/' || label, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_label;

	procedure create_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
		, color						varchar2
	)

	as


	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/labels', 'POST');

		github.github_call_request.call_json.put('label', label);
		github.github_call_request.call_json.put('color', color);

		github.talk(
			github_account => git_account
		);

	end create_label;

	procedure update_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
		, color						varchar2
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/labels/' || label, 'PATCH');

		github.github_call_request.call_json.put('label', label);
		github.github_call_request.call_json.put('color', color);

		github.talk(
			github_account => git_account
		);

	end update_label;

	procedure delete_label (
		git_account					varchar2
		, repos_name				varchar2
		, label 					varchar2
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/labels/' || label, 'DELETE');

		github.talk(
			github_account => git_account
		);

	end delete_label;

	function list_issue_labels (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_issue_labels;

	procedure add_labels_to_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, labels 					json_list
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels', 'POST');

		github.talk(
			github_account => git_account
		);

	end add_labels_to_issue;

	procedure remove_label_from_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, label 					varchar2
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels/' || label, 'DELETE');

		github.talk(
			github_account => git_account
		);

	end remove_label_from_issue;

	procedure replace_all_labels_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
		, labels 					json_list
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels', 'PUT');

		github.talk(
			github_account => git_account
		);

	end replace_all_labels_issue;

	procedure remove_labels_issue (
		git_account					varchar2
		, repos_name				varchar2
		, issue_id 					number
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/issues/' || issue_id || '/labels', 'DELETE');

		github.talk(
			github_account => git_account
		);

	end remove_labels_issue;

	function labels_from_milestone (
		git_account					varchar2
		, repos_name				varchar2
		, milestone_id				number
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/milestones/' || milestone_id || '/labels', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end labels_from_milestone;

end github_issues_labels;
/