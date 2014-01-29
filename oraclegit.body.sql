create or replace package body oraclegit.oraclegit

as

	procedure init_schema (
		git_schema 				varchar2
		, rep_name 				varchar2
		, rep_account			varchar2
	)

	as

		cursor get_code_objects is 
			select 
				object_name
				, object_type
				, object_id
			from 
				all_objects
			where
				owner = upper(git_schema)
			and
				object_type in ('PROCEDURE', 'FUNCTION', 'PACKAGE')
			order by
				object_name;

		ddl_clob				clob;
		git_object_path			varchar2(4000);
		content_json			json.jsonstructobj;
		commited_sha			varchar2(4000);

	begin

		for codes in get_code_objects loop
			git_object_path := lower(git_schema) || '/' || lower(codes.object_type) || '/' || lower(codes.object_name) || '.oraclegit.sql';

			ddl_clob := dbms_metadata.get_ddl(
				object_type => codes.object_type
				, name => codes.object_name
				, schema => git_schema
			);
	
			-- Encode data in base64 for github push
			ddl_clob := github.encode64_clob(ddl_clob);

			-- Push to github
			github_repos_content.create_file(
				git_account => rep_account
				, repos_name => rep_name
				, path => git_object_path
				, message => 'Commit of: ' || obj_type || '.' || obj_name || '.'
				, content => ddl_clob
			);

			-- Save the SHA for the commit for next update
			content_json := json.String2JSON(json.getAttrValue(github.github_api_parsed_result, 'content'));
			commited_sha := json.getattrvalue(content_json, 'sha');

			-- Add the object for tracking
			add_object_tracking(rep_name, git_schema, obj_name, obj_type, git_object_path, commited_sha);
		end loop;

	end init_schema;

	function is_tracked (
		git_schema				varchar2
	)
	return boolean

	as

		schema_count			number;

	begin

		select count(*)
		into schema_count
		from repository_schema
		where schema_name = upper(git_schema);

		if schema_count > 0 then
			return true;
		else
			return false;
		end if;

	end is_tracked;

	function org_count
	return number

	as

		orgs				number := 0;

	begin

		select count(*)
		into orgs
		from github_organization;

		return orgs;

	end org_count;

	function get_one_org
	return varchar2

	as

		oneorg 				varchar2(200);

	begin

		select org_name
		into oneorg
		from github_organization;

		return oneorg;

	end get_one_org;

	function repos_exists (
		repository 					varchar2
	)
	return boolean

	as

		repos_count			number := 0;

	begin

		select count(*)
		into repos_count
		from github_repository
		where upper(repository_name) = upper(repository);

		if repos_count > 0 then
			return true;
		else
			return false;
		end if;

	end repos_exists;

	function get_oraclegit_env (
		env_name					varchar2
	)
	return varchar2

	as

		env_val				varchar2(4000) := null;

	begin

		select environment_value
		into env_val
		from oraclegit_env
		where upper(environment_name) = upper(env_name);

		return env_val;

	end get_oraclegit_env;

	procedure add_tracking (
		track_schema				varchar2
		, track_repository			varchar2
	)

	as

	begin

		insert into repository_schema (schema_name, repository)
		values (track_schema, track_repository);

		commit;

	end add_tracking;

	procedure add_github_repository (
		repos_name 					varchar2
		, repos_owner 				varchar2
		, repos_organization		varchar2 default null
		, repos_branch				varchar2 default null
	)

	as

	begin

		insert into github_repository (repository_name, org_name, repository_owner, repository_branch)
		values (repos_name, repos_organization, repos_owner, repos_branch);

		commit;

	end add_github_repository;

	procedure add_object_tracking (
		repos_name 					varchar2
		, oracle_schema_name		varchar2
		, obj_name					varchar2
		, obj_type					varchar2
		, obj_path					varchar2
		, obj_sha					varchar2
	)

	as

	begin

		insert into repository_objects (repository_name, schema_name, object_name, object_type, object_path, object_sha)
		values (repos_name, oracle_schema_name, obj_name, obj_type, obj_path, obj_sha);

		commit;

	end add_object_tracking;

	procedure git_enable (
		git_account					varchar2
		, git_schema				varchar2 default user
		, git_repository_name		varchar2 default null
		, git_repository_desc		varchar2 default null
		, git_organization			varchar2 default null
	)

	as

		git_enable_exc			exception;
		schema_count			number;
		pragma exception_init(git_enable_exc, -20001);

		use_org					boolean := false;
		default_org				varchar2(200) := null;
		create_rep				boolean := false;
		new_rep_name			varchar2(200) := null;
		rep_private				boolean := false;

	begin

		-- Check if git_organization is set accordingly
		-- If null, and we have more than one org, we fail.
		-- If null and we only have one, create under that org
		-- If null and no org set, create under specified account
		if git_organization is null and oraclegit.org_count = 1 then
			use_org := true;
			default_org := get_one_org;
		elsif git_organization is null and oraclegit.org_count > 1 then
			raise_application_error( -20001, 'Invalid or missing organization.');
		elsif git_organization is not null then
			use_org := true;
			default_org := git_organization;
		end if;

		-- Check if repository name is null. If null we want a repository
		-- that has the same name as the schema we want to track
		if git_repository_name is null and repos_exists(git_schema) then
			raise_application_error( -20001, 'Repository: ' || git_schema || ' already exists.');
		elsif git_repository_name is null then
			new_rep_name := git_schema;
			create_rep := true;
		elsif not repos_exists(git_repository_name) then
			create_rep := true;
			new_rep_name := git_repository_name;
		end if;


		if is_tracked(upper(git_schema)) and create_rep and get_oraclegit_env('multiple_schema_repos') = 'N' then
			raise_application_error( -20001, 'Already registered. Multiple registrations of same schema not allowed.');
		elsif is_tracked(upper(git_schema)) and get_oraclegit_env('multiple_schema_repos') = 'N' then
			raise_application_error( -20001, 'Already registered. Multiple registrations of same schema not allowed.');
		end if;

		-- If we get to here, we can register schema and create repository if needed.
		-- First create if we have to
		if create_rep then
			if get_oraclegit_env('privacy_level') = 'PUBLIC' then 
				rep_private := false;
			elsif get_oraclegit_env('privacy_level') = 'PRIVATE' then 
				rep_private := true;
			else 
				rep_private := false;
			end if;
			github_repos.repos_create (
				git_account => git_account
				, repos_name => new_rep_name
				, use_org => use_org
				, org_name => default_org
				, private => rep_private
				, auto_init => true
			);

			-- Add the repository to OracleGit
			if use_org then
				add_github_repository(new_rep_name, git_account, default_org);
			else
				add_github_repository(new_rep_name, git_account);
			end if;
		end if;

		-- Add the schema to tracking
		add_tracking(git_schema, new_rep_name);

		-- Init objects in schema to repository
		init_schema(git_schema, new_rep_name, git_account);

		exception
			when others then
				rollback;
				raise;

	end git_enable;

	procedure git_write (
		git_schema				varchar2
		, obj_type				varchar2
		, obj_name				varchar2
	)

	as

		g_acc					varchar2(4000);
		g_rep					varchar2(4000);

		ddl_clob				clob;
        git_object_path			varchar2(4000) := lower(git_schema) || '/' || lower(obj_type) || '/' || lower(obj_name) || '.oraclegit.sql';

        cursor get_acc_rep is
        	select ghr.repository_name, ghr.repository_owner
			from github_repository ghr, repository_schema rs
			where rs.schema_name = git_schema
			and rs.repository = ghr.repository_name;

		content_json			json.jsonstructobj;
		commited_sha			varchar2(4000);

	begin

		-- First we get the DDL for the plsql
		ddl_clob := dbms_metadata.get_ddl(
			object_type => obj_type
			, name => obj_name
			, schema => git_schema
		);

		-- Encode data in base64 for github push
		ddl_clob := github.encode64_clob(ddl_clob);

		if oraclegit.get_oraclegit_env('multiple_schema_repos') = 'N' then
			-- Only one repository for one schema
			open get_acc_rep;
			fetch get_acc_rep into g_rep, g_acc;
			close get_acc_rep;
			-- Push the content to github
			github_repos_content.create_file(
				git_account => g_acc
				, repos_name => g_rep
				, path => git_object_path
				, message => 'Commit of: ' || obj_type || '.' || obj_name || '.'
				, content => ddl_clob
			);

			-- Save the SHA for the commit for next update
			content_json := json.String2JSON(json.getAttrValue(github.github_api_parsed_result, 'content'));
			commited_sha := json.getattrvalue(content_json, 'sha');

			-- Add the object for tracking
			add_object_tracking(g_rep, git_schema, obj_name, obj_type, git_object_path, commited_sha);
		else
			for x in get_acc_rep loop
				github_repos_content.create_file(
					git_account => x.repository_owner
					, repos_name => x.repository_name
					, path => git_object_path
					, message => 'Commit of: ' || obj_type || '.' || obj_name || '.'
					, content => ddl_clob
				);
			end loop;
		end if;

	end git_write;

	procedure add_github_account (
		git_account 				varchar2
		, git_passwd 				varchar2
		, git_full_name 			varchar2 default null
		, git_email_address			varchar2 default null
		, organization 				varchar2 default null
	)

	as

	begin

		insert into github_account (github_username, github_password, github_name, github_email, org_name)
		values (git_account, git_passwd, git_full_name, git_email_address, organization);

		commit;

	end add_github_account;

end oraclegit;
/