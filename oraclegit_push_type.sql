create or replace type oraclegit_push_type as object (
	object_owner			varchar2(150)
	, object_type			varchar2(150)
	, object_name			varchar2(150)
)
/

-- Event flow queues
begin
	dbms_aqadm.create_queue_table(
		queue_table        => 'oraclegit_push_dll_q_tab',
		queue_payload_type => 'oraclegit_push_type',
		multiple_consumers => true,
		comment            => 'queue table for oraclegit ddl events'
	);

	dbms_aqadm.create_queue (
		queue_name  => 'oraclegit_push_queue',
		queue_table => 'oraclegit_push_dll_q_tab'
	);

	dbms_aqadm.start_queue (
		queue_name => 'oraclegit_push_queue'
	);
end;
/

create or replace trigger oraclegit_capture_ddl
after 
	create 
or 
	alter 
or 
	drop
on 
	database

declare

	enqueue_options			dbms_aq.enqueue_options_t;
	message_properties		dbms_aq.message_properties_t;
	message_handle			raw(16);
	queue_msg				oraclegit_push_type;

begin

	if ora_dict_obj_owner != 'SYS' then
		queue_msg := oraclegit_push_type(ora_dict_obj_owner, ora_dict_obj_type, ora_dict_obj_name);
		message_properties.delay := 600;

		dbms_aq.enqueue(
			queue_name			=> 'oraclegit_push_queue',
			enqueue_options		=> enqueue_options,
			message_properties	=> message_properties,
			payload				=> queue_msg,
			msgid				=> message_handle
		);

		commit;
	end if;

end oraclegit_capture;
/

create or replace procedure get_oraclegit_ddl_push (
	push_msg			in		oraclegit_push_type
)

as

	repos_name			varchar2(4000);
	repos_owner			varchar2(4000);
	github_account		varchar2(4000);
	github_password		varchar2(4000);

begin

	-- So here we should lookup, which github repository to push this to.
	-- Find session settings, set them and do push.
	-- Also we only push allowed objects
	if oraclegit.is_tracked(push_msg.object_owner) then
		-- We track this schema, so we should push if object type is correct
		if push_msg.object_type in ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE_SPEC', 'PACKAGE_BODY') then
			-- Setup env for this repository
			github_oracle_session.set_github(
				ssl_wallet_location			=>	oraclegit.get_oraclegit_env('github_wallet_location')
				, ssl_wallet_password		=>	oraclegit.get_oraclegit_env('github_wallet_passwd')
				, github_logon_user			=>	github_account
				, github_logon_pass			=>	github_password
				, github_repository			=>	repos_name
				, github_repository_owner	=>	repos_owner
			);
		end if;
	end if;

end get_oraclegit_ddl_push;
/

begin
	
	dbms_scheduler.create_program (
		program_name => 'ORACLEGIT_DDL_PUSH_RCV'
		, program_action=> 'GET_ORACLEGIT_DDL_PUSH'
		, program_type => 'STORED_PROCEDURE'
		, number_of_arguments => 1
		, enabled => FALSE
	);

	dbms_scheduler.define_metadata_argument (
		program_name => 'ORACLEGIT_DDL_PUSH_RCV'
		, argument_position => 1
		, metadata_attribute => 'EVENT_MESSAGE'
	);

	dbms_scheduler.enable ('ORACLEGIT_DDL_PUSH_RCV');

	dbms_scheduler.create_job (
		job_name => 'ORACLEGIT_PUSH_JOB'
		, program_name => 'ORACLEGIT_DDL_PUSH_RCV'
		, start_date => localtimestamp
		, event_condition => 'tab.user_data.object_name is not null'
		, queue_spec => 'oraclegit_push_queue'
		, enabled => true
	);

end;
/

