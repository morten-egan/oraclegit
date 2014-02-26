create or replace package body github_repos_collaborators

as

	function list_collaborators (
		git_account					varchar2
		, repos_name				varchar2
	)
	return github.call_result

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/collaborators', 'GET');

		github.talk(
			github_account => git_account
		);

		return github.github_response_result;

	end list_collaborators;

	function check_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	)
	return boolean

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/collaborators/' || collaborator, 'GET');

		github.talk(
			github_account => git_account
		);

		if github.github_call_status_code = 204 then
			return true;
		else
			return false;
		end if;

	end check_collaborator;

	procedure add_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/collaborators/' || collaborator, 'PUT');

		github.talk(
			github_account => git_account
		);

	end add_collaborator;

	procedure remove_collaborator (
		git_account					varchar2
		, repos_name				varchar2
		, collaborator 				varchar2
	)

	as

	begin

		github.init_talk('/repos/' || git_account || '/' || repos_name || '/collaborators/' || collaborator, 'DELETE');

		github.talk(
			github_account => git_account
		);

	end remove_collaborator;

end github_repos_collaborators;
/