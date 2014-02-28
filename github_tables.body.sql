create or replace package body github_tables

as

	function repository_languages (
		repos_name 					varchar2
		, git_account				varchar2 default github.get_session_github_user
	)
	return repos_lang_tab
	pipelined

	as

		table_data					github.call_result;
		row_result					github_repos_lang;
		keys						json_list;

	begin

		table_data := github_repos.repos_languages(git_account, repos_name);
		keys := table_data.result.get_keys;

		if table_data.result.count > 0 then
			for i in 1..table_data.result.count loop
				row_result.repos_name := repos_name;
				row_result.repos_lang := keys.get(i).get_string;
				row_result.lang_bytes := table_data.result.get(row_result.repos_lang).get_number;
				pipe row(row_result);
			end loop;
		end if;

		return;

	end repository_languages;

	function repositories (
		git_account					varchar2 default github.get_session_github_user
		, repos_type 				varchar2 default 'owner'
		, repos_sort				varchar2 default 'full_name'
		, repos_direction			varchar2 default 'asc'
	)
	return repos_tab
	pipelined

	as

		table_data					github.call_result;
		row_result					github_repository;
		row_data					json;

	begin

		if git_account is not null then
	
			table_data := github_repos.repositories(git_account, repos_type, repos_sort, repos_direction);

			for rows in 1..table_data.result_list.count loop
				row_data := json(table_data.result_list.get(rows));
				row_result.repos_id := json_ext.get_number(row_data, 'id');
				row_result.repos_name := json_ext.get_string(row_data, 'name');
				row_result.repos_full_name := json_ext.get_string(row_data, 'full_name');
				row_result.repos_owner := json_ext.get_string(row_data, 'owner.login');
				row_result.repos_description := json_ext.get_string(row_data, 'description');
				row_result.repos_created := sysdate;
				row_result.repos_updated := sysdate;

				pipe row (row_result);
			end loop;
		end if;

		return;

	end repositories;

	function repository_issues (
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
	return repos_issues_tab
	pipelined

	as

		table_data					github.call_result;
		row_result					github_issue;
		row_data					json;

	begin

		table_data := github_issues.get_repository_issues (
			git_account => git_account
			, repos_name => repos_name
			, milestone => milestone
			, state => state
			, assignee => assignee
			, creator => creator
			, mentioned => mentioned
			, labels => labels
			, sort => sort
			, direction => direction
			, since => since
		);

		for rows in 1..table_data.result_list.count loop
			row_data := json(table_data.result_list.get(rows));

			row_result.issue_id := json_ext.get_number(row_data, 'number');
			row_result.api_url := json_ext.get_string(row_data, 'url');
			row_result.html_url := json_ext.get_string(row_data, 'html_url');
			row_result.state := json_ext.get_string(row_data, 'state');
			row_result.title := json_ext.get_string(row_data, 'title');
			row_result.body := json_ext.get_string(row_data, 'title');
			row_result.created_by := json_ext.get_string(row_data, 'user.login');
			row_result.assignee := json_ext.get_string(row_data, 'assignee.login');
			row_result.comments := json_ext.get_number(row_data, 'comments');
			row_result.created := sysdate;
			row_result.updated := sysdate;
			row_result.closed := sysdate;

			pipe row (row_result);
		end loop;

	end repository_issues;

	function repository_contributors (
		git_account					varchar2
		, repos_name				varchar2
		, anon 						varchar2 default '1'
	)
	return repos_contributor_tab
	pipelined

	as

		table_data					github.call_result;
		row_result					repos_contributor;
		row_data					json;

	begin

		table_data := github_repos.repos_contributors(
			git_account => git_account
			, repos_name => repos_name
			, anon => anon
		);

		for rows in 1..table_data.result_list.count loop
			row_data := json(table_data.result_list.get(rows));

			row_result.user_name := json_ext.get_string(row_data, 'login');
			row_result.url := json_ext.get_string(row_data, 'url');
			row_result.contributions := json_ext.get_number(row_data, 'contributions');

			pipe row (row_result);
		end loop;

	end repository_contributors;

	function repository_branches (
		git_account					varchar2
		, repos_name				varchar2
	)
	return repos_branch_tab
	pipelined

	as

		table_data					github.call_result;
		row_result					repos_branch;
		row_data					json;

	begin

		table_data := github_repos.repos_branches(
			git_account => git_account
			, repos_name => repos_name
		);

		for rows in 1..table_data.result_list.count loop
			row_data := json(table_data.result_list.get(rows));

			row_result.branch_name := json_ext.get_string(row_data, 'name');
			row_result.commit_sha := json_ext.get_string(row_data, 'commit.sha');
			row_result.commit_url := json_ext.get_string(row_data, 'commit.url');

			pipe row (row_result);
		end loop;

	end repository_branches;

	function repository_contents (
		git_account					varchar2
		, repos_name				varchar2
		, path 						varchar2 default '/'
	)
	return repos_content_obj_tab
	pipelined

	as

		table_data					github.call_result;
		row_result					repos_content_obj;
		row_data					json;

	begin

		table_data := github_repos_content.get_content(
			git_account => git_account
			, repos_name => repos_name
			, path => path
		);

		for rows in 1..table_data.result_list.count loop
			row_data := json(table_data.result_list.get(rows));

			row_result.content_type := json_ext.get_string(row_data, 'type');
			row_result.content_name := json_ext.get_string(row_data, 'name');
			row_result.content_path := json_ext.get_string(row_data, 'path');
			row_result.github_sha := json_ext.get_string(row_data, 'sha');
			row_result.url := json_ext.get_string(row_data, 'url');

			pipe row (row_result);
		end loop;

	end repository_contents;

end github_tables;
/