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

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/merges', 'POST');

		github.github_call_request.call_json.put('base', base);
		github.github_call_request.call_json.put('head', head);
		github.github_call_request.call_json.put('commit_message', commit_message);

		github.talk(
			github_account => git_account
		);

	end repos_merge;

end github_repos_merge;
/