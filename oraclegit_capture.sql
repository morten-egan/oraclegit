create or replace trigger oraclegit_capture
after create or alter or drop
on database

declare
ddl_data clob;
begin

	if oraclegit.oraclegit.is_tracked(ora_dict_obj_owner) then
		if ora_dict_obj_type in ('PACKAGE', 'PROCEDURE', 'FUNCTION', 'PACKAGE_BODY', 'PACKAGE_SPEC') then
			ddl_data := dbms_metadata.get_ddl(
				object_type => ora_dict_obj_type
				, name => ora_dict_obj_name
				, schema => ora_dict_obj_owner
			);

			dbms_output.put_line(ddl_data);
			-- Git write object
			-- oraclegit.git_write(ora_dict_obj_owner, ora_dict_obj_type, ora_dict_obj_name, ddl_data);
		end if;
	end if;

end oraclegit_capture;
/