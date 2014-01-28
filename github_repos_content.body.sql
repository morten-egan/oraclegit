create or replace package body github_repos_content

as

	procedure create_file (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, message					varchar2
		, content 					clob
		, branch					varchar2 default null
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/contents/' || path;
		github_api_endpoint_method	varchar2(100) := 'PUT';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'message', message);
		github_api_json := json.addattr(github_api_json, 'committer', github.github_committer_hash);
		github_api_json := json.addattr(github_api_json, 'content', content);
		if branch is not null then
			github_api_json := json.addattr(github_api_json, 'branch', branch);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end create_file;

	procedure update_file (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, message					varchar2
		, content 					clob
		, sha 						varchar2
		, branch					varchar2 default null
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/contents/' || path;
		github_api_endpoint_method	varchar2(100) := 'PUT';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'message', message);
		github_api_json := json.addattr(github_api_json, 'committer', github.github_committer_hash);
		github_api_json := json.addattr(github_api_json, 'content', content);
		github_api_json := json.addattr(github_api_json, 'sha', sha);
		if branch is not null then
			github_api_json := json.addattr(github_api_json, 'branch', branch);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end update_file;

	procedure delete_file (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, message					varchar2
		, sha 						varchar2
		, branch					varchar2 default null
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/contents/' || path;
		github_api_endpoint_method	varchar2(100) := 'DELETE';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'message', message);
		github_api_json := json.addattr(github_api_json, 'committer', github.github_committer_hash);
		github_api_json := json.addattr(github_api_json, 'sha', sha);
		if branch is not null then
			github_api_json := json.addattr(github_api_json, 'branch', branch);
		end if;
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end delete_file;

	function get_content (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, ref 						varchar2 default null
	)
	return json.jsonstructobj

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/contents/' || path;
		github_api_endpoint_method	varchar2(100) := 'GET';
		github_api_json				json.jsonstructobj;

	begin

		if ref is not null then
			null;
		end if;

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
		);

		return github.github_api_parsed_result;

	end get_content;

end github_repos_content;
/