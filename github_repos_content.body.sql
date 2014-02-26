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

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/contents/' || path, 'PUT');

		github.github_call_request.call_json.put('message', message);
		github.github_call_request.call_json.put('committer', github.github_committer_hash);
		github.github_call_request.call_json.put('content', content);
		if branch is not null then
			github.github_call_request.call_json.put('branch', branch);
		end if;

		github.talk(
			github_account => git_account
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

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/contents/' || path, 'PUT');

		github.github_call_request.call_json.put('message', message);
		github.github_call_request.call_json.put('committer', github.github_committer_hash);
		github.github_call_request.call_json.put('content', content);
		github.github_call_request.call_json.put('sha', sha);
		if branch is not null then
			github.github_call_request.call_json.put('branch', branch);
		end if;

		github.talk(
			github_account => git_account
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

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/contents/' || path, 'DELETE');

		github.github_call_request.call_json.put('message', message);
		github.github_call_request.call_json.put('committer', github.github_committer_hash);
		github.github_call_request.call_json.put('sha', sha);
		if branch is not null then
			github.github_call_request.call_json.put('branch', branch);
		end if;

		github.talk(
			github_account => git_account
		);

	end delete_file;

	function get_content (
		git_account					varchar2
		, repos_name				varchar2
		, path						varchar2
		, ref 						varchar2 default null
	)
	return github.call_result

	as

	begin

		if ref is not null then
			null;
		end if;

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/contents/' || path, 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_content;

	function get_archive_link (
		git_account					varchar2
		, repos_name				varchar2
		, archive_format			varchar2 default 'tarball'
		, ref 						varchar2 default 'master'
	)
	return varchar2

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/' || archive_format || '/' || ref, 'GET');

		github.talk(
			github_account => git_account
		);

		-- Now we have a header with the link to the archive
		return github.github_response_result.result.get('Location').to_char;

	end get_archive_link;

	function get_readme (
		git_account					varchar2
		, repos_name				varchar2
		, ref 						varchar2 default 'master'
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/readme', 'GET');

		github.github_call_request.call_json.put('ref', ref);

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end get_readme;

end github_repos_content;
/