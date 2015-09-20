create or replace package body oraclegit

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
				dba_objects
			where
				owner = upper(git_schema)
			and
				object_type in ('PROCEDURE', 'FUNCTION', 'PACKAGE')
			order by
				object_name;

		git_object_path			varchar2(4000);

	begin

		for codes in get_code_objects loop
			dbms_scheduler.create_job (
    			job_name        => git_schema || '.GITPUSH_' || substr(codes.object_name, 1, 20),
    			job_type        => 'PLSQL_BLOCK',
    			job_action      => 'BEGIN github.github_get_code(''CREATE'', '''|| git_schema ||''', '''|| codes.object_type ||''', '''|| codes.object_name ||'''); END;',
    			start_date      => SYSTIMESTAMP,
    			enabled         => TRUE,
    			comments        => 'Init schema, push code.'
    		);
    		git_object_path := github_oracle_content.get_object_path(codes.object_name, codes.object_type, git_schema);
			add_object_tracking(rep_name, git_schema, codes.object_name, codes.object_type, git_object_path);
		end loop;

		commit;

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
		where upper(schema_name) = upper(git_schema);

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
		values (upper(track_schema), track_repository);

		commit;

	end add_tracking;

	function get_schema_respository (
		oracle_schema_name 		in 		varchar2
	)
	return varchar2

	as

		repos_return				varchar2(4000);

	begin

		select repository
		into repos_return
		from repository_schema
		where upper(schema_name) = upper(oracle_schema_name);

		return repos_return;

	end get_schema_respository;

	procedure add_github_repository (
		repos_name 					varchar2
		, repos_owner 				varchar2
		, repos_organization		varchar2 default null
		, repos_branch				varchar2 default null
		, repos_issues				varchar2 default 'N'
	)

	as

	begin

		insert into github_repository (repository_name, org_name, repository_owner, repository_branch, issues_enabled)
		values (repos_name, repos_organization, repos_owner, repos_branch, repos_issues);

		commit;

	end add_github_repository;

	procedure add_object_tracking (
		repos_name 					varchar2
		, oracle_schema_name		varchar2
		, obj_name					varchar2
		, obj_type					varchar2
		, obj_path					varchar2
	)

	as

	begin

		insert into repository_objects (repository_name, schema_name, object_name, object_type, object_path)
		values (repos_name, upper(oracle_schema_name), obj_name, obj_type, obj_path);

		commit;

	end add_object_tracking;

	procedure git_enable_schema (
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
		git_passwd 				varchar2(4000);

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
		-- First setup session
		select github_password
		into git_passwd
		from github_account
		where github_username = git_account;

		github_oracle_session.set_github(
			ssl_wallet_location			=>	oraclegit.get_oraclegit_env('github_wallet_location')
			, ssl_wallet_password		=>	oraclegit.get_oraclegit_env('github_wallet_passwd')
			, github_logon_user			=>	git_account
			, github_logon_pass			=>	git_passwd
			, github_repository			=>	new_rep_name
			, github_repository_owner	=>	git_account
		);
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

		-- execute immediate 'grant execute on github_push_type to ' || git_schema;

		-- Grant access to the push queue
		dbms_aqadm.grant_queue_privilege (
   			privilege     =>     'ALL',
   			queue_name    =>     'github.github_push_queue',
   			grantee       =>     git_schema,
   			grant_option  =>     false
   		);

   		commit;

		-- Init objects in schema to repository
		init_schema(git_schema, new_rep_name, git_account);

		exception
			when others then
				rollback;
				raise;

	end git_enable_schema;

	procedure repos_session_setup (
		obj_owner			in 		varchar2
		, obj_type 			in 		varchar2
		, obj_name 			in 		varchar2
	)

	as

		repos_name				varchar2(4000);
		github_acc 				varchar2(4000);
		github_acc_pass			varchar2(4000);

	begin

		if obj_type is not null and obj_name is not null then
			select ghr.repository_name, ghr.repository_owner, ga.github_password
			into repos_name, github_acc, github_acc_pass
			from github_repository ghr, repository_schema rs, github_account ga
			where rs.repository = (
					select ro.repository_name 
					from repository_objects ro 
					where upper(ro.schema_name) = upper(obj_owner)
					and upper(ro.object_type) = upper(obj_type)
					and upper(ro.object_name) = upper(obj_name)
				)
			and rs.repository = ghr.repository_name
			and ghr.repository_owner = ga.github_username;
		else
			select ghr.repository_name, ghr.repository_owner, ga.github_password
			into repos_name, github_acc, github_acc_pass
			from github_repository ghr, repository_schema rs, github_account ga
			where rs.repository = (
					select ro.repository_name 
					from repository_objects ro 
					where upper(ro.schema_name) = upper(obj_owner)
					and rownum = 1
				)
			and rs.repository = ghr.repository_name
			and ghr.repository_owner = ga.github_username;
		end if;

		github_oracle_session.set_github(
			ssl_wallet_location			=>	oraclegit.get_oraclegit_env('github_wallet_location')
			, ssl_wallet_password		=>	oraclegit.get_oraclegit_env('github_wallet_passwd')
			, github_logon_user			=>	github_acc
			, github_logon_pass			=>	github_acc_pass
			, github_repository			=>	repos_name
			, github_repository_owner	=>	github_acc
		);

	end repos_session_setup;

	function is_object_tracked (
		obj_owner					varchar2
		, obj_type 					varchar2
		, obj_name 					varchar2
	)
	return boolean

	as

		track_count				number := 0;

	begin

		select count(*)
		into track_count
		from repository_objects
		where upper(schema_name) = upper(obj_owner)
		and upper(object_name) = upper(obj_name)
		and upper(object_type) = upper(obj_type);

		if track_count > 0 then
			return true;
		else 	
			return false;
		end if;

	end is_object_tracked;

	procedure git_write (
		git_schema					varchar2
		, obj_type					varchar2
		, obj_name					varchar2
		, obj_content				clob
	)

	as

        git_object_path			varchar2(4000) := github_oracle_content.get_object_path(obj_name, obj_type, git_schema);
        repos_name 				varchar2(4000);

	begin

		if oraclegit.get_oraclegit_env('multiple_schema_repos') = 'N' then
			if is_object_tracked(git_schema, obj_type, obj_name) = false then
				select repository
				into repos_name
				from repository_schema
				where upper(schema_name) = upper(git_schema);
				add_object_tracking(repos_name, git_schema, obj_name, obj_type, git_object_path);
			end if;
			repos_session_setup(git_schema, obj_type, obj_name);
			github_oracle_content.push_object(obj_name, obj_type, git_schema, obj_content);
		else
			-- Not support at the moment
			null;
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

	function push_code_extract (
		push_code 			in 		clob
	)
	return number

	as

		cid					number;

	begin

		insert into repository_code_pushes (code_push_id, code_data)
		values (code_push_seq.nextval, push_code)
		returning code_push_id into cid;

		commit;

		return cid;

	end push_code_extract;

	procedure issues_enable_schema (
		oracle_schema_name	in 		varchar2
	)

	as

		repos_exists				varchar2(4000) := null;

	begin

		select repository
		into repos_exists
		from repository_schema
		where upper(schema_name) = upper(oracle_schema_name);

		if repos_exists is not null then
			update github_repository
			set issues_enabled = 'Y'
			where repository_name = repos_exists;

			commit;
		end if;

	end issues_enable_schema;

	function is_issue_enabled (
		oracle_schema_name	in 		varchar2
	)
	return boolean

	as

		is_enabled 					varchar2(1) := 'N';

	begin

		select gr.issues_enabled
		into is_enabled
		from github_repository gr, repository_schema rs
		where upper(rs.schema_name) = upper(oracle_schema_name)
		and rs.repository = gr.repository_name;

		if is_enabled = 'Y' then
			return true;
		else
			return false;
		end if;

		exception
			when others then
				return false;

	end is_issue_enabled;

	procedure github_issue (
		issues_schema 		in 		varchar2
		, issue_title		in 		varchar2
		, issue_body		in 		varchar2
	)

	as

	begin

		repos_session_setup(issues_schema, null, null);
		github_issues.create_issue(
			git_account => github_oracle_session.gh_r_o
			, repos_name => github_oracle_session.gh_r
			, title => issue_title
			, body => issue_body
			, assignee => github_oracle_session.gh_r_o
		);

	end github_issue;

end oraclegit;
/