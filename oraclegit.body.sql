create or replace package body oraclegit.oraclegit

as

	procedure init_schema (
		git_schema 				varchar2
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

	begin

		for codes in get_code_objects loop
			git_write(git_schema, codes.object_type, codes.object_name);
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

	function encode64_clob(
		content 				in 			clob
	) 
	return clob 

	is
		--the chunk size must be a multiple of 48
		chunksize 				integer := 576;
		place 					integer := 1;
		file_size 				integer;
		temp_chunk 				varchar(4000);
		out_clob 				clob;
	begin
		file_size := length(content);
		
		while (place <= file_size) loop
		       temp_chunk := substr(content, place, chunksize);
		       out_clob := out_clob  || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(temp_chunk)));
		       place := place + chunksize;
		end loop;

		return out_clob;
	end encode64_clob;

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
				, is_private => rep_private
			);
		end if;

		commit;

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

	begin

		-- First we get the DDL for the plsql
		ddl_clob := dbms_metadata.get_ddl(
			object_type => obj_type
			, name => obj_name
			, schema => git_schema
		);

	end git_write;

end oraclegit;