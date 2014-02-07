create or replace package body github_tables

as

	function repositories (
		git_account					varchar2 default github.get_session_github_user
		, repos_type 				varchar2 default 'owner'
		, repos_sort				varchar2 default 'full_name'
		, repos_direction			varchar2 default 'asc'
	)
	return repos_tab
	pipelined

	as

		table_data					json.jsonstructobj;
		row_result					github_repository;
		repos_count					number;
		row_working_data_raw		clob;
		row_working_data 			json.jsonstructobj;

		-- HACK
		butt_ugly_hack				clob;
		butt_ugly_hack_json			json.jsonstructobj;

	begin

		if git_account is not null then
			-- So apparently there is a bug in the json library, that I cannot understand. When there is an inline
			-- json that ends with an boolean value, it refuses to recognize the ending brace. So for now, and untill
			-- I fix that one, I do a butt ugly hack:
	
			table_data := github_repos.repositories(git_account, repos_type, repos_sort, repos_direction);
			butt_ugly_hack := github.github_api_raw_result;
			butt_ugly_hack := replace(butt_ugly_hack, '"site_admin":true', '"site_admin":true,"t1":"t1"');
			butt_ugly_hack := replace(butt_ugly_hack, '"site_admin":false', '"site_admin":false,"t1":"t1"');
			butt_ugly_hack := replace(butt_ugly_hack, '"pull":true', '"pull":true,"t1":"t1"');
			butt_ugly_hack := replace(butt_ugly_hack, '"pull":false', '"pull":false,"t1":"t1"');
			table_data := json.string2json(butt_ugly_hack);
			json.getJsonObjFromJsonObjArr(table_data, repos_count, butt_ugly_hack_json);

			for x in 1..repos_count loop
				row_working_data_raw := json.getAttrValue(butt_ugly_hack_json, 'AV_' || x);
				row_working_data := json.string2json(row_working_data_raw);
				row_result.repos_id := json.getAttrValue(row_working_data, 'id');
				row_result.repos_name := json.getAttrValue(row_working_data, 'name');
				row_result.repos_full_name := json.getAttrValue(row_working_data, 'full_name');
				row_result.repos_owner := '42';
				row_result.repos_description := json.getAttrValue(row_working_data, 'description');
				row_result.repos_created := sysdate;
				row_result.repos_updated := sysdate;

				pipe row (row_result);
			end loop;
		end if;

		return;

	end repositories;

end github_tables;
/