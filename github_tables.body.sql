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
		lang_idx					varchar2(4000);

	begin

		table_data := github_repos.repos_languages(git_account, repos_name);

		for i in 1..table_data.result.count loop
			if table_data.result(i).type = 'ATTRNAME' then
				row_result.repos_name := repos_name;
				row_result.repos_lang := replace(table_data.result(i).item, '"');
				row_result.lang_bytes := json.getAttrValue(table_data.result, row_result.repos_lang);
				pipe row(row_result);
			end if;
		end loop;

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
		row_raw 					clob;
		row_json					json.jsonstructobj;
		inner_raw					clob;
		inner_json					json.jsonstructobj;

	begin

		if git_account is not null then
			-- So apparently there is a bug in the json library, that I cannot understand. When there is an inline
			-- json that ends with an boolean value, it refuses to recognize the ending brace. So for now, and untill
			-- I fix that one, I do a butt ugly hack:
	
			table_data := github_repos.repositories(git_account, repos_type, repos_sort, repos_direction);

			for rows in 1..table_data.result_count loop
				row_raw := json.getAttrValue(table_data.result, 'AV_' || rows);
				row_json := json.string2json(row_raw);
				row_result.repos_id := json.getAttrValue(row_json, 'id');
				row_result.repos_name := json.getAttrValue(row_json, 'name');
				row_result.repos_full_name := json.getAttrValue(row_json, 'full_name');
				-- Get inner owner
				inner_raw := json.getAttrValue(row_json, 'owner');
				inner_json := json.string2json(inner_raw);
				row_result.repos_owner := json.getAttrValue(inner_json, 'login');
				row_result.repos_description := json.getAttrValue(row_json, 'description');
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
		row_raw 					clob;
		row_json					json.jsonstructobj;
		inner_raw					clob;
		inner_json					json.jsonstructobj;

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

		for rows in 1..table_data.result_count loop
			/* row_raw := json.getAttrValue(table_data.result, 'AV_' || rows);
			row_json := json.string2json(row_raw);

			row_result.issue_id := json.getAttrValue(row_json, 'number');
			row_result.api_url := json.getAttrValue(row_json, 'url');
			row_result.html_url := json.getAttrValue(row_json, 'html_url'); */
			row_result.issue_id := 0;

			pipe row (row_result);
		end loop;

	end repository_issues;

end github_tables;
/