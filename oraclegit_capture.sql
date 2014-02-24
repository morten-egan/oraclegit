create or replace trigger oraclegit_capture
after create or alter or drop
on database

declare
ddl_text_var dbms_standard.ora_name_list_t;
 full_ddl_text clob;
ddl_data clob;
begin

	/* ddl_data := dbms_metadata.get_ddl(
		object_type => ora_dict_obj_type
		, name => ora_dict_obj_name
		, schema => ora_dict_obj_owner
	);

	dbms_output.put_line(ddl_data); */
	

	dbms_output.put_line(ora_sysevent);

end oraclegit_capture;
/