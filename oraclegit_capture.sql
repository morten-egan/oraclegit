create or replace trigger oraclegit.oraclegit_capture
after ddl
on database

declare

begin

	if oraclegit.is_tracked(ora_dict_obj_owner) then
		if ora_dict_obj_type in ('PACKAGE', 'PROCEDURE', 'FUNCTION', 'PACKAGE_BODY', 'PACKAGE_SPEC') then
			-- Git write object
			oraclegit.git_write(ora_dict_obj_owner, ora_dict_obj_type, ora_dict_obj_name);
		end if;
	end if;

end oraclegit_capture;
/