create or replace type github_push_type as object (
	object_event			varchar2(500)
	, object_owner			varchar2(150)
	, object_type			varchar2(150)
	, object_name			varchar2(150)
	, code_id				number
)
/

-- Event flow queues
begin
	dbms_aqadm.create_queue_table(
		queue_table        => 'github_push_dll_q_tab',
		queue_payload_type => 'github_push_type',
		multiple_consumers => true,
		comment            => 'queue table for github ddl events'
	);

	dbms_aqadm.create_queue (
		queue_name  => 'github_push_queue',
		queue_table => 'github_push_dll_q_tab'
	);

	dbms_aqadm.start_queue (
		queue_name => 'github_push_queue'
	);
end;
/

create or replace procedure get_github_ddl_push (
	push_msg			in		github_push_type
)

as

	push_content		clob;

begin

	if push_msg.object_type in ('PROCEDURE', 'FUNCTION', 'PACKAGE_SPEC', 'PACKAGE_BODY') then
		select code_data
		into push_content
		from repository_code_pushes
		where code_push_id = push_msg.code_id;

		oraclegit.git_write(push_msg.object_owner, push_msg.object_type, push_msg.object_name, push_content);

		-- Once done, we can delete push data
		delete from repository_code_pushes
		where code_push_id = push_msg.code_id;

		commit;
	end if;

end get_github_ddl_push;
/

begin
	
	dbms_scheduler.create_program (
		program_name => 'GITHUB_DDL_PUSH_RCV'
		, program_action=> 'get_github_ddl_push'
		, program_type => 'STORED_PROCEDURE'
		, number_of_arguments => 1
		, enabled => FALSE
	);

	dbms_scheduler.define_metadata_argument (
		program_name => 'GITHUB_DDL_PUSH_RCV'
		, argument_position => 1
		, metadata_attribute => 'EVENT_MESSAGE'
	);

	dbms_scheduler.enable ('GITHUB_DDL_PUSH_RCV');

end;
/

begin

	dbms_scheduler.create_job (
		job_name => 'GITHUB_PUSH_JOB'
		, program_name => 'GITHUB_DDL_PUSH_RCV'
		, start_date => localtimestamp
		, queue_spec => 'github_push_queue'
		, enabled => false
	);

	dbms_scheduler.set_attribute('GITHUB_PUSH_JOB','parallel_instances',TRUE);

	dbms_scheduler.enable('GITHUB_PUSH_JOB');

end;
/

create or replace procedure github_get_code (
	obj_event 			varchar2
	, obj_owner 		varchar2
	, obj_type 			varchar2
	, obj_name 			varchar2
	, code_id			number
)

as

	enqueue_options			dbms_aq.enqueue_options_t;
	message_properties		dbms_aq.message_properties_t;
	message_handle			raw(16);
	queue_msg				github_push_type;

begin

	if obj_type = 'PACKAGE' then
		queue_msg := github_push_type(obj_event, obj_owner, 'PACKAGE_SPEC', obj_name, code_id);
		dbms_aq.enqueue(
			queue_name			=> 'github.github_push_queue',
			enqueue_options		=> enqueue_options,
			message_properties	=> message_properties,
			payload				=> queue_msg,
			msgid				=> message_handle
		);

		queue_msg := github_push_type(obj_event, obj_owner, 'PACKAGE_BODY', obj_name, code_id);
		dbms_aq.enqueue(
			queue_name			=> 'github.github_push_queue',
			enqueue_options		=> enqueue_options,
			message_properties	=> message_properties,
			payload				=> queue_msg,
			msgid				=> message_handle
		);

		commit;
	else
		queue_msg := github_push_type(obj_event, obj_owner, obj_type, obj_name, code_id);
		dbms_aq.enqueue(
			queue_name			=> 'github.github_push_queue',
			enqueue_options		=> enqueue_options,
			message_properties	=> message_properties,
			payload				=> queue_msg,
			msgid				=> message_handle
		);

		commit;
	end if;

end github_get_code;
/

grant execute on github_get_code to public;
create public synonym github_get_code for github.github_get_code;

create or replace trigger github_capture_ddl
after 
	create 
or 
	alter 
--or 
--	drop
on 
	database

declare

begin

	if ora_dict_obj_owner != 'SYS' then
		if oraclegit.is_tracked(ora_dict_obj_owner) then
			if ora_dict_obj_type = 'PACKAGE' then
				dbms_scheduler.create_job (
	    			job_name        => ora_dict_obj_owner || '.GITPUSHS_' || substr(ora_dict_obj_name, 1, 20),
	    			job_type        => 'PLSQL_BLOCK',
	    			job_action      => 'DECLARE objcode clob; objcodeid number; BEGIN objcode := dbms_metadata.get_ddl(''PACKAGE_SPEC'', '''|| ora_dict_obj_name ||'''); objcodeid := oraclegit.push_code_extract(objcode); github.github_get_code('''|| ora_sysevent ||''', '''|| ora_dict_obj_owner ||''', ''PACKAGE_SPEC'', '''|| ora_dict_obj_name ||''', objcodeid); END;',
	    			start_date      => SYSTIMESTAMP,
	    			enabled         => TRUE,
	    			comments        => 'Push code.'
	    		);
	    	elsif ora_dict_obj_type = 'PACKAGE BODY' then
	    		dbms_scheduler.create_job (
	    			job_name        => ora_dict_obj_owner || '.GITPUSHB_' || substr(ora_dict_obj_name, 1, 20),
	    			job_type        => 'PLSQL_BLOCK',
	    			job_action      => 'DECLARE objcode clob; objcodeid number; BEGIN objcode := dbms_metadata.get_ddl(''PACKAGE_BODY'', '''|| ora_dict_obj_name ||'''); objcodeid := oraclegit.push_code_extract(objcode); github.github_get_code('''|| ora_sysevent ||''', '''|| ora_dict_obj_owner ||''', ''PACKAGE_BODY'', '''|| ora_dict_obj_name ||''', objcodeid); END;',
	    			start_date      => SYSTIMESTAMP,
	    			enabled         => TRUE,
	    			comments        => 'Push code.'
	    		);
			else
				dbms_scheduler.create_job (
	    			job_name        => ora_dict_obj_owner || '.GITPUSH_' || substr(ora_dict_obj_name, 1, 20),
	    			job_type        => 'PLSQL_BLOCK',
	    			job_action      => 'DECLARE objcode clob; objcodeid number; BEGIN objcode := dbms_metadata.get_ddl('''|| ora_dict_obj_type ||''', '''|| ora_dict_obj_name ||'''); objcodeid := oraclegit.push_code_extract(objcode); github.github_get_code('''|| ora_sysevent ||''', '''|| ora_dict_obj_owner ||''', '''|| ora_dict_obj_type ||''', '''|| ora_dict_obj_name ||''', objcodeid); END;',
	    			start_date      => SYSTIMESTAMP,
	    			enabled         => TRUE,
	    			comments        => 'Push code.'
	    		);
	    	end if;
		end if;
	end if;

end github_capture_ddl;
/