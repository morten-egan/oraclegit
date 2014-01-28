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
		github_api_json := json.addattr(github_api_json, 'content', github.encode64_clob(content));
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

end github_repos_content;
/