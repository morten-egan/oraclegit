create or replace package body github_oracle_content

as

	function get_object_path (
		object_name	 			in 			varchar2
		, object_type			in 			varchar2
		, object_owner 			in 			varchar2 default user
	)
	return varchar2

	as

		suffix					varchar2(50) := '.sql';
		full_path				varchar2(1000);

	begin

		if object_type = 'PACKAGE_SPEC' then
			suffix := '.spec.sql';
			return lower(object_owner || '/package/' || object_name || suffix);
		elsif object_type = 'PACKAGE_BODY' then
			suffix := '.body.sql';
			return lower(object_owner || '/package/' || object_name || suffix);
		else
			return lower(object_owner || '/' || object_type || '/' || object_name || suffix);
		end if;

	end get_object_path;

	procedure push_object (
		object_name	 			in 			varchar2
		, object_type			in 			varchar2
		, object_owner 			in 			varchar2 default user
		, object_content		in 			clob default null
	)

	as

		github_path				varchar2(4000) := get_object_path(object_name, object_type, object_owner);
		check_push_response		github.call_result;
		object_content_r		clob;
		github_content_val		clob;
		github_content_sha		varchar2(4000);

	begin

		if object_content is null then
			object_content_r := github.encode64_clob(dbms_metadata.get_ddl(upper(object_type), upper(object_name), object_owner));
		else
			object_content_r := github.encode64_clob(object_content);
		end if;
		
		check_push_response := github_repos_content.get_content(
				git_account => github_oracle_session.gh_r_o
				, repos_name => github_oracle_session.gh_r
				, path => github_path
			);

		if github.github_call_status_code = 200 then
			-- object path already exists
			-- Update instead of create, but before we update check if it has changed
			github_content_sha := check_push_response.result.get('sha').get_string;
			github_content_val := check_push_response.result.get('content').get_string;
			-- Cleanup content for comparison
			github_content_val := replace(replace(github_content_val, chr(10)), chr(13));
			if object_content_r != github_content_val then
				-- New content do the update
				github_repos_content.update_file (
					git_account => github_oracle_session.gh_r_o
					, repos_name => github_oracle_session.gh_r
					, path => github_path
					, message => github_oracle_session.gh_p_m
					, content => object_content_r
					, sha => github_content_sha
				);
			end if;
		else
			-- Object does not exist, create it
			github_repos_content.create_file (
				git_account => github_oracle_session.gh_r_o
				, repos_name => github_oracle_session.gh_r
				, path => github_path
				, message => github_oracle_session.gh_p_m
				, content => object_content_r
			);
		end if;

	end push_object;

	procedure push_schema_code(
		split_packages			in 			boolean default true
	)

	as

		cursor get_plsql_objects is 
			select 
				object_name
				, object_type 
			from 
				user_objects
			where 
				object_type in ('PROCEDURE','FUNCTION','PACKAGE')
			;

	begin

		for obj in get_plsql_objects loop
			if obj.object_type = 'PACKAGE' and split_packages then
				push_object(obj.object_name, 'PACKAGE_SPEC');
				push_object(obj.object_name, 'PACKAGE_BODY');
			else
				push_object(obj.object_name, obj.object_type);
			end if;
		end loop;

	end push_schema_code;

	function compare_object (
		object_name				in 			varchar2
		, object_type			in 			varchar2
		, object_owner			in 			varchar2 default user
	)
	return varchar2

	as

		github_path				varchar2(4000) := get_object_path(object_name, object_type, object_owner);
		check_push_response		github.call_result;
		object_content			clob;
		github_content_val		clob;
	
	begin

		object_content := github.encode64_clob(dbms_metadata.get_ddl(upper(object_type), upper(object_name), object_owner));

		check_push_response := github_repos_content.get_content(
				git_account => github_oracle_session.gh_r_o
				, repos_name => github_oracle_session.gh_r
				, path => github_path
			);

		if github.github_call_status_code = 200 then
			github_content_val := check_push_response.result.get('content').get_string;
			github_content_val := replace(replace(github_content_val, chr(10)), chr(13));
			if object_content != github_content_val then
				return 'Object ' || object_owner || '.' || object_name || ' is different from the repository version';
			else
				return 'Object ' || object_owner || '.' || object_name || ' is equal to repository version';
			end if;
		else
			return 'Object ' || object_owner || '.' || object_name || ' not pushed to repository: ' || github_oracle_session.gh_r;
		end if;

	end compare_object;

end github_oracle_content;
/