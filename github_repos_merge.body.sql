create or replace package body github_repos_merge

as

	procedure repos_merge (
		git_account					varchar2
		, repos_name				varchar2
		, base 						varchar2
		, head						varchar2
		, commit_message			varchar2 default null
	)

	as

		github_api_endpoint			varchar2(4000) := '/repos/' || git_account || '/' || repos_name || '/merges';
		github_api_endpoint_method	varchar2(100) := 'POST';
		github_api_json				json.jsonstructobj;

	begin

		json.newjsonobj(github_api_json);
		github_api_json := json.addattr(github_api_json, 'base', base);
		github_api_json := json.addattr(github_api_json, 'head', head);
		github_api_json := json.addattr(github_api_json, 'commit_message', commit_message);
		json.closejsonobj(github_api_json);

		github.talk(
			github_account => git_account
			, api_endpoint => github_api_endpoint
			, endpoint_method => github_api_endpoint_method
			, api_data => json.json2string(github_api_json)
		);

	end repos_merge;

end github_repos_merge;
/