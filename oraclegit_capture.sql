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
	for i in 1..ora_sql_txt(ddl_text_var) loop        --This portion of code calculates the full DDL text, because ddl_text_var
   full_ddl_text:=full_ddl_text||ddl_text_var(i);  --is just a table of 64 byte pieces of DDL, we need to subtract them
 end loop; 

	dbms_output.put_line(full_ddl_text);

end oraclegit_capture;
/