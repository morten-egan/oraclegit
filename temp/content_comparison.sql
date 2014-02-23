FUNCTION get_clob_from_base64_string (p_clob CLOB)
RETURN clob

IS
	l_chunk clob; --Chunks of decoded blob that'll be appended
	l_result clob; --Final blob result to be returned
	l_rawout RAW (32767); --Decoded raw data from first pass decode
	l_rawin RAW (32767); --Encoded raw data chunk
	l_amt NUMBER DEFAULT 7700;
	--Default length of data to decode
	l_offset NUMBER DEFAULT 1;
	--Default Offset of data to decode
	l_tempvarchar VARCHAR2 (32767);
BEGIN
	BEGIN
		DBMS_LOB.createtemporary (l_result, FALSE, DBMS_LOB.CALL);
		DBMS_LOB.createtemporary (l_chunk, FALSE, DBMS_LOB.CALL);
		LOOP
			DBMS_LOB.READ (p_clob, l_amt, l_offset, l_tempvarchar);
				l_offset := l_amt + l_offset;
				l_rawin := UTL_RAW.cast_to_raw (l_tempvarchar);
				l_rawout := UTL_ENCODE.base64_decode (l_rawin);
				l_chunk := utl_raw.cast_to_varchar2(l_rawout);
			DBMS_LOB.append (l_result, l_chunk);
		END LOOP;
		
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
	END;

	return l_result;

end get_clob_from_base64_string;
/

function from_base64(t in varchar2) return varchar2 is
begin
  return utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw    (t)));
end from_base64;


declare
s varchar2(4000) := 'CiAgQ1JFQVRFIE9SIFJFUExBQ0UgUFJPQ0VEVVJFICJPUkFDTEVHSVQiLiJM\nSVZFX1BST0MiIAoKYXMKCmJlZ2luCgogIGRibXNfb3V0cHV0LnB1dF9saW5l\nKCdJIGFtIHByb2MnKTsKICAKZW5kIGxpdmVfcHJvYzs=\n';
function from_base64(t in varchar2) return varchar2 is
begin
  return utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw    (t)));
end from_base64;
begin

s := replace(s,chr(10));
s := replace(s,chr(13));
dbms_output.put_line(from_base64(s));
end;
/


declare

  clobOriginal     clob;
  clobInBase64     clob := 'CiAgQ1JFQVRFIE9SIFJFUExBQ0UgUFJPQ0VEVVJFICJPUkFDTEVHSVQiLiJM\nSVZFX1BST0MiIAoKYXMKCmJlZ2luCgogIGRibXNfb3V0cHV0LnB1dF9saW5l\nKCdJIGFtIHByb2MnKTsKICAKZW5kIGxpdmVfcHJvYzs=\n';
  substring        varchar2(2000);
  n                pls_integer := 0;
  substring_length pls_integer := 2000;

  function to_base64(t in varchar2) return varchar2 is
  begin
    return utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(t)));
  end to_base64;

  function from_base64(t in varchar2) return varchar2 is
  begin
    return utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(t)));
  end from_base64;

begin

  n := 0;
  clobOriginal := null;

  /*then we do the very same thing backwards - decode base64*/
  while true loop 

    substring := dbms_lob.substr(clobInBase64,
                                 least(substring_length, substring_length * n + 1 - length(clobInBase64)),
                                 substring_length * n + 1);  
    if substring is null then
      exit;
    end if;  
    clobOriginal := clobOriginal || from_base64(substring);  
    n := n + 1;  
  end loop; 

  dbms_output.put_line(clobOriginal);

end;


declare
myjson json.jsonstructobj;
begin

-- Set wallet parameters for the session
github.set_session_wallet('file:/home/oracle/wallet', 'Manager123');

-- Set github account for session
github.set_logon_info('morten-egan', 'Manager002');

-- Get the contents of an object path
myjson := github_repos_content.get_content(
git_account => 'morten-egan'
, repos_name => 'github_utl_test'
, path => 'Hello.txt'
);

-- With the response json we ask for the SHA. If not set, file does not exists
dbms_output.put_line('SHA of existing file: ' || json.getattrvalue(myjson, 'content'));

dbms_output.put_line(utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(json.getattrvalue(myjson, 'content')))));

end;
/