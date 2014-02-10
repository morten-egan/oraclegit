CREATE OR REPLACE PACKAGE BODY JSON AS
/******************************************************************************
   NAME:       JSON
   PURPOSE:    Output in JSON format (http://www.json.org) for oracle
   			   Javascript Simple Object Notation
			   
			   /!\ the values are encoded according to JSON specifications language.
			   Passing an heaxdecimal value in a string must be done with 
			   the following syntax :
			   
			   'someString...someString...#hex[four hexa digits] ... someString...'

   REVISIONS:
   Ver        Date        Author  Description
   ---------  ----------  ------  ---------------------------------------------
   0.1        03/07/2007  PGL     Created this package body.
   1.0        03/12/2007  PGL     Add basic object validation.
   1.1        11/03/2008  PGL     - Add some stuff to prevent from javascript 
   			  			  		  Hijacking, prototype framework compatible : 
								  /*-secure-\n{...json object...}\n*/		/*
								  - Add procedure to send appropriate mime type 
								    for Web output "application/json"
								  - printing enhancement.
								  - suppress global variable g_output_type.
								  - bug corrections in String2Json func.
								  - Add procedure to stream out the json object
								  - Suppress indentation for better perf on
								  	long json objects.
								  - Refactor terms to match on the english terms
								  - bug correction in getAttrValue, add param
								  	pOutPutStringDelimiter and pOutPutSeparator
									that allow to format the output of the 
									function.
								  - Add function getAttrArray that return an
								  	array of values in an plsql array of varchar2
								  - Add Array2String utility.
								  - Add License informations 
								  
******************************************************************************

/******************************************************************************
        This program is published under the GNU LGPL License 
                http://www.gnu.org/licenses/lgpl.html
*******************************************************************************
 This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
********************************************************************************

******************************************************************************
-- TODO
   	   - Implement a complete function validatejsonobj that parses the object
	   	 and verify its structure.
	   - Implement correctly indentation.
	   
******************************************************************************/
--------------------------------------------------------------------------------
-- Internal Types and records
--------------------------------------------------------------------------------
-- type for special char table
type specialCharReplace is record (pattern varchar(4), changeTo varchar2(2));
type specialChar is table of specialCharReplace index by binary_integer;

--------------------------------------------------------------------------------
-- Internal variables and constants
--------------------------------------------------------------------------------
tSpcChr specialChar;

x_type_no_defined Exception;
msg_type_no_defined constant varchar2(255) := 'Type of item "%1" not supported in this package.';
x_invalid_object Exception;
msg_invalid_object constant varchar2(255) := 'Invalid JSON object. Check syntax at item #%1...';

--g_doindetation boolean := false; -- true for doing indentation

g_secure  boolean := false; -- true for securing object by adding javascript comments
		   		   	  		 -- prevent form javascript hijacking.

nullObj JSONStructObj; -- Null JSONObject : never intialized.

--------------------------------------------------------------------------------
-- Internal Procedures and functions
--------------------------------------------------------------------------------

/*
procedure my_customized_print(p_str varchar2) is
begin
	 -- this my customized output comment these line above to put your's.
	 affiche.p(p_str);
	 
	 -- dbms_output.put_line(p_str);
	 htp.p(p_str);
	 
	 -- end of customization.
end my_customized_print;
*/
--------------------------------------------------------------------------------
-- Procedure that can be customize to print the JSON result string 
-- in a table, in a file, ont the web with your own procedure, with dbms_output,
-- WRITE YOUR OWN CUSTOM OUTPUT HERE
--------------------------------------------------------------------------------
procedure print(p_str varchar2) is
begin
     -- this my customized output comment these line above to put your's.
	 -- htp.print(p_str);
	 dbms_output.put_line(p_str);
	 -- end of customization.
end print;

--------------------------------------------------------------------------------
-- Procedure that sends the appropriate maime type for web output.
--------------------------------------------------------------------------------
procedure sendJsonMime is
begin
     print('application/json');
end sendJsonMime;

--------------------------------------------------------------------------------
-- Procedure that streams the Json Structure to ouput.
--------------------------------------------------------------------------------
procedure streamOutput(pobj JSONStructObj) is
i number;
begin
	i := pobj.first;
	while (i is not null) loop
	  print(pobj(i).item);
	  i := pobj.next(i);
	end loop;
end streamOutput;

--------------------------------------------------------------------------------
-- set the right number of spaces to indent JSON object correctly.
--------------------------------------------------------------------------------
-- procedure indent(p_what varchar2 default '+') is
-- begin
--   if (g_doindetation) then 
-- 	  if (p_what = '+') then
-- 	    g_indent := g_indent || g_spc;
-- 	  else 
-- 	    g_indent := substr(g_indent, - length(g_spc));
-- 	  end if;
--   end if;
-- end indent;


--------------------------------------------------------------------------------
-- returns a boolean converted in a string: true => 'true', false => 'false'
--------------------------------------------------------------------------------
function bool2str(boolean_in in boolean) return varchar2
is
begin
   if (boolean_in) then
      return 'true';
   end if;
   return 'false';
end bool2str;

--------------------------------------------------------------------------------
-- returns true if the string can be converted to a number
--------------------------------------------------------------------------------
function isNumber(p_str varchar2 default null) return boolean is
  n number;
begin
  n := to_number(p_str);
  return true;
exception
  when others then
  return false;
end isNumber;

--------------------------------------------------------------------------------
-- returns the deencoded string according to JSON encoding specification
--------------------------------------------------------------------------------
function decodeValue(p_str varchar2 default null) return varchar2 is
  my_str varchar2(2000) := p_str;
  i pls_integer;
begin
	 i := tSpcChr.first;
	 while (i is not null) loop
	 	   -- formating according to JSON specs.
	 	   my_str := replace(my_str, tSpcChr(i).changeTo, tSpcChr(i).pattern);
		   i := tSpcChr.next(i);
	 end loop;
     -- removing the string delimiter
	 if (substr(my_str, 1, 1) = g_stringDelimiter ) then
	 	my_str := substr(my_str, 2);
	 end if;
	 if (substr(my_str, -1) = g_stringDelimiter ) then
	 	my_str := substr(my_str, 1, length(my_str)-1);
	 end if;
  return my_str;
end decodeValue;

--------------------------------------------------------------------------------
-- returns the encoded string according to JSON specification langage
--------------------------------------------------------------------------------
function formatValue(p_str varchar2 default null) return varchar2 is
  my_str varchar2(2000) := p_str;
  i pls_integer;
begin
   -- if the string is null we have to put ''.
   if (my_str is null) then
     my_str := '''''';
   elsif (lower(my_str) in ('true', 'false')) then
     -- format a boolean without quote.
	 my_str := my_str;
   elsif (not isNumber(my_str)) then
     -- format a string
	 i := tSpcChr.first;
	 while (i is not null) loop
	 	   -- formating according to JSON specs.
	 	   my_str := replace(my_str, tSpcChr(i).pattern, tSpcChr(i).changeTo);
		   i := tSpcChr.next(i);
	 end loop;
     -- adding the string delimiter
     my_str := g_stringDelimiter || my_str || g_stringDelimiter;
   else 
     -- format a number
	 my_str := replace(my_str, ',', '.');
   end if;
  return my_str;
end formatValue;

--------------------------------------------------------------------------------
-- Returns a JSON Item for our JSON structure 
--------------------------------------------------------------------------------
function addItem(p_type varchar2, p_item varchar2, p_formated boolean default false) return JSONItem is
  my_item JSONItem;
begin
  -- structure controls
  if ( p_type not in ( 'OPENBRACE', 'OPENBRACKET', 
  	   		  	  	   'CLOSEBRACE', 'CLOSEBRACKET', 
					   'SEPARATION', 'AFFECTATION', 
					   'ATTRNAME', 'ATTRDATA', 'ARRAYDATA',
					   'INDENTATION')
	 ) then
    raise x_type_no_defined;
  end if;
  my_item.type := p_type;
  my_item.item := p_item;
  my_item.formated := p_formated;
  return my_item;
exception
  when x_type_no_defined then
  print(replace(msg_type_no_defined, '%1', p_type));
  return null;
end addItem;

--------------------------------------------------------------------------------
-- opens object
--------------------------------------------------------------------------------
function openObj return JSONItem is 
begin
-- 	indent('+');
	return addItem('OPENBRACE', g_CR || g_openBrace);
end openObj;
  
--------------------------------------------------------------------------------
-- Closes object
--------------------------------------------------------------------------------
function closeObj return JSONItem is
begin
--	indent('-');
	-- dealing with indentation
-- 	if (g_doindetation) then
-- 	   return addItem('CLOSEBRACE', g_CR || g_closeBrace);
-- 	end if;
	return addItem('CLOSEBRACE', g_closeBrace);
end closeObj;
  
--------------------------------------------------------------------------------
-- opens array
--------------------------------------------------------------------------------
function openArray return JSONItem is
begin
	return addItem('OPENBRACKET', g_openBracket);
end openArray;
  
--------------------------------------------------------------------------------
-- Closes array
--------------------------------------------------------------------------------
function closeArray return JSONItem is
begin
	return addItem('CLOSEBRACKET', g_closeBracket);
end closeArray;
        
		
--------------------------------------------------------------------------------
-- Inits special char table for coding and decoding value.
--------------------------------------------------------------------------------
procedure initSpecCharTable is
begin
  	 tSpcChr(1).pattern := '\';
	 tSpcChr(2).pattern := '/';
	 tSpcChr(3).pattern := g_stringDelimiter;
	 tSpcChr(4).pattern := chr(8);  -- backspace
	 tSpcChr(5).pattern := chr(12); -- form feed
	 tSpcChr(6).pattern := chr(10); -- new line
	 tSpcChr(7).pattern := chr(13); -- carriage return
	 tSpcChr(8).pattern := chr(9); 	-- tablulation
	 tSpcChr(9).pattern := '#hex';  -- four hexadecimal digit
	 --
	 tSpcChr(1).changeTo := '\\';
	 tSpcChr(2).changeTo := '\/';
	 tSpcChr(3).changeTo := '\'||g_stringDelimiter;
	 tSpcChr(4).changeTo := '\b'; -- backspace
	 tSpcChr(5).changeTo := '\f'; -- form feed
	 tSpcChr(6).changeTo := '\n'; -- new line
	 tSpcChr(7).changeTo := '\r'; -- carriage return
	 tSpcChr(8).changeTo := '\t'; -- tablulation
	 tSpcChr(9).changeTo := '\u'; -- four hexadecimal digit
end initSpecCharTable;

--------------------------------------------------------------------------------
-- Inits package environment.
--------------------------------------------------------------------------------
procedure newJSONObj(p_obj in out nocopy JSONStructObj, p_doindetation boolean default true, p_secure boolean default false) is
  i pls_integer := 1;
begin
	 -- init special char table
	 initSpecCharTable;
	 -- init json object.
	 p_obj.delete;
-- 	 if (p_doindetation) then
-- 	    g_doindetation := true;
-- 	 	p_obj(1) := addItem('INDENTATION', g_indent);
-- 		i := 2;
--      else
-- 	   g_doindetation := false;
-- 	 end if;
	 if (p_secure) then
	    g_secure := true;
	 end if;
	 p_obj(i) := openObj();
end newJSONObj;

--------------------------------------------------------------------------------
-- Returns the first item where the problem is, else return 0
--------------------------------------------------------------------------------
function validateJSONObj(p_obj in out nocopy JSONStructObj, pvalidate boolean default false) return pls_integer is
  i pls_integer;
  isBracketOpened boolean := false;
  isBracketOpened 	  boolean := false;
  x_invalid_structure exception;
  IdxElmtErr pls_integer := 0;
		------------------------------------------------------------------------
		-- Returns 0 if syntax {...} is correct, else returns the last incorrect 
		-- element.
		------------------------------------------------------------------------
		function validateStructure(p_elmt_type varchar2 default 'BRACE') return number is
		   cntOpndBrcks pls_integer := 0;
		   x_counter_not_0 exception;
		begin
			i := p_obj.first;
			while (i is not null) loop
			  case p_obj(i).type 
			  when 'OPEN'||p_elmt_type then
		  	  	  cntOpndBrcks := cntOpndBrcks + 1;
			  when 'CLOSE'||p_elmt_type then
		  	  	  cntOpndBrcks := cntOpndBrcks - 1;
			  else
			    null;
			  end case;
			  -- if the counter count down under 0 => structure problem : 
			  -- object is already close whether the structure isn't parsed at all.
			  if (cntOpndBrcks < 0) then
			     raise x_counter_not_0;
			  end if;
			  i := p_obj.next(i);
			end loop;
			-- if the counter is upper than 0 => structure problem : 
			-- one or more brackets still opened. 
			if (cntOpndBrcks > 0) then
			   -- when we are here, i is null so initializing i = p_obj.count.
			   i := p_obj.count;
			   raise x_counter_not_0;
			end if;
			return 0;
		exception
		  when x_counter_not_0 then
		    return i;
		end validateStructure;
		------------------------------------------------------------------------
begin
	-- see if formatting have to be done 
	i := p_obj.first;
	while (i is not null) loop
	  if( not p_obj(i).formated and p_obj(i).type in ('ATTRNAME', 'ATTRDATA', 'ARRAYDATA') ) then
	    p_obj(i).item := formatValue(p_obj(i).item);
	    p_obj(i).formated := true;
	  end if;
	  i := p_obj.next(i);
	end loop;
	
	--
	-- General Validation : counting and comparing opened and closed brackets and brackets.
	--
	if (pvalidate) then
		IdxElmtErr := validateStructure('BRACE');
		if ( IdxElmtErr != 0 ) then
		  raise x_invalid_structure;
		end if;
		IdxElmtErr := validateStructure('BRACKET');
		if ( IdxElmtErr != 0 ) then
		  raise x_invalid_structure;
		end if;	
		--
	end if;
	return 0;
exception
  when x_invalid_structure then
    return IdxElmtErr;
end validateJSONObj;

--------------------------------------------------------------------------------
-- Closes the JSON Object
--------------------------------------------------------------------------------
procedure closeJSONObj(p_obj in out nocopy JSONStructObj) is
  i pls_integer;
  status pls_integer;
begin
	-- adding closing bracket
	p_obj(p_obj.last+1) := closeObj;
	-- when closing object, removing trailing ','
	i := p_obj.last;
	while (i is not null) loop
	  if( p_obj(i).type = 'SEPARATION' ) then
	    -- if the futher item of the list is not in these type ('ATTRNAME', 'ATTRDATA', 'ARRAYDATA')
		-- we have to trash the comma.
		if ( p_obj.exists(p_obj.next(i)) and p_obj(p_obj.next(i)).type not in ('ATTRNAME', 'ATTRDATA', 'ARRAYDATA') ) then
	       p_obj.delete(i);
		   exit;
		end if;
	  end if;
	  i := p_obj.prior(i);
	end loop;
	status := validateJSONObj(p_obj);
	if ( status != 0) then
		 raise x_invalid_object;
	end if;
exception
  when x_invalid_object then
  print(replace(msg_invalid_object, '%1', status));
end closeJSONObj;


--------------------------------------------------------------------------------
-- modify a JSON object to remove indentation elements
--------------------------------------------------------------------------------
function removeIndent(p_obj JSONStructObj) return JSONStructObj is
  my_obj JSONStructObj := p_obj;
  i pls_integer;
begin
	i := my_obj.first;
	while (i is not null) loop
	  if (my_obj(i).type = 'INDENTATION' ) then
		  my_obj.delete(i);
	  end if;
	  i := my_obj.next(i);
	end loop;
	return my_obj;
end removeIndent;


--------------------------------------------------------------------------------
-- Returns a the values of an array in varchar2 type from the JSON Structure
--------------------------------------------------------------------------------
function getComplexValue( p_obj JSONStructObj, pidx pls_integer, p_ArrayOrObject varchar2 default 'ARRAY') 
return varchar2 is
  my_obj JSONStructObj := p_obj;
  ln_count_OpenBracket pls_integer := 1;
  my_value varchar2(32000);
  j pls_integer := pidx;
  lv_what varchar2(10);
begin
    -- see what we are attempting to retrieve...
    if (p_ArrayOrObject = 'ARRAY') then
	  lv_what := 'BRACKET';
	else
	  lv_what := 'BRACE';
	end if;
	--
	while (j is not null) loop
	  if(my_obj(j).type = 'OPEN'||lv_what) then
	    ln_count_OpenBracket := ln_count_OpenBracket + 1;
	  elsif (my_obj(j).type = 'CLOSE'||lv_what) then
	    ln_count_OpenBracket := ln_count_OpenBracket - 1;
	  end if;
	  my_value := my_value || my_obj(j).item;
	  if (ln_count_OpenBracket = 0) then
	    my_value := substr(my_value, 1, length(my_value) -1);
	    exit;
	  end if;
	  j := my_obj.next(j);
	end loop;
	return my_value;
  exception
  when others then
     return null;
end getComplexValue;

--------------------------------------------------------------------------------
-- Returns a the values of an array in JSONArray type from the JSON Structure
--------------------------------------------------------------------------------
function getComplexValueAsArray( p_obj JSONStructObj, pidx pls_integer, p_ArrayOrObject varchar2 default 'ARRAY') 
return JSONArray is
  my_obj JSONStructObj := p_obj;
  ln_count_OpenBracket pls_integer := 1;
  my_value JSONArray;
  blank_tab JSONArray;
  i number := 1; -- index of the array of values which are extracted from jsonStruct.
  j pls_integer := pidx;
  lv_what varchar2(10);
begin
    -- see what we are attempting to retrieve : object or Array ?
    if (p_ArrayOrObject = 'ARRAY') then
      -- Array
	  lv_what := 'BRACKET';
	else
	  -- object
	  lv_what := 'BRACE';
	end if;
	--
	while (j is not null) loop
	  if(my_obj(j).type = 'OPEN'||lv_what) then
	    ln_count_OpenBracket := ln_count_OpenBracket + 1;
	  elsif (my_obj(j).type = 'CLOSE'||lv_what) then
	    ln_count_OpenBracket := ln_count_OpenBracket - 1;
	  end if;
	  -- Retrieving only the data
	  if ( my_obj(j).type = 'ARRAYDATA' ) then
	     -- removing the string delimiter
	  	 my_value(i) := replace(my_obj(j).item, g_stringDelimiter, null);
		 i := i + 1;
	  end if;
	  if (ln_count_OpenBracket = 0) then
	    exit;
	  end if;
	  j := my_obj.next(j);
	end loop;
	return my_value;
  exception
  when others then
     return blank_tab;
end getComplexValueAsArray;

--------------------------------------------------------------------------------
-- Set a value to an attribut
--------------------------------------------------------------------------------
function setAttrSimpleValue(p_obj JSONStructObj, pname varchar2, pvalue varchar2, pformated boolean default false) return JSONStructObj is
  my_obj JSONStructObj := p_obj;
  i pls_integer;
  j pls_integer;
  value_found boolean := false;
begin
	i := my_obj.first;
	while (i is not null) loop
	  if (lower(my_obj(i).item) = g_stringDelimiter||lower(pname)||g_stringDelimiter and my_obj(i).type = 'ATTRNAME') then
	     -- the arrtibute exists.
		 j := my_obj.next(i);
		 while (j is not null) loop
		   if (my_obj(j).type = 'ATTRDATA') then
		     -- we have found the value to be replaced
			 if (pformated) then
			 	my_obj(j).item := pvalue;
			 else
			    my_obj(j).item := formatValue(pvalue);
			 end if;
			 my_obj(j).formated := not pformated;
			 -- exiting this loop;
			 value_found := true;
			 exit;
		   end if;
		   j := my_obj.next(j);
		 end loop;
	  end if;
	  if (value_found) then
	    exit;
	  end if;
	  i := my_obj.next(i);
	end loop;
    return my_obj;
end setAttrSimpleValue;

--------------------------------------------------------------------------------
-- Set a value to an attribut
--------------------------------------------------------------------------------
function setAttrSimpleValue(p_obj JSONStructObj, pname varchar2, pbool boolean, pformated boolean default false) return JSONStructObj is
  val varchar2(10) := bool2str(pbool);
begin
	return setAttrSimpleValue(p_obj, pname, val, pformated);
end setAttrSimpleValue;


--------------------------------------------------------------------------------
-- Returns an array of value of an attribute.
--------------------------------------------------------------------------------
function getAttrArray( p_obj JSONStructObj, pname varchar2, pdecode boolean default true) 
return JSONArray is
  blank_tab JSONArray; -- null array used for exceptions
  my_obj JSONStructObj := p_obj;
  i pls_integer;
  -----------------------------------------------------------------
  function returnvalue(pidx pls_integer, pdec boolean default true) return JSONArray is
    j pls_integer := pidx;
	FirstNextVal pls_integer := my_obj.next(j);
	SecondNextVal pls_integer := my_obj.next(FirstNextVal);
	ThirdNextVal pls_integer := my_obj.next(SecondNextVal);
	-- due to removing INDENTATION, the index may not be 2,3,4,5... but 2,4,5,8,...
	-- so we can't access to the structure with j, j+1, j+2,... 
	-- We'd better access by j, my_obj.next(j), my_obj.next(my_obj.next(j)), ...
	my_tab_value JSONArray;
  begin
	if (my_obj(j).type = 'ATTRNAME' ) then
	  if (my_obj(SecondNextVal).type = 'OPENBRACKET') then
	    -- This is a table
		-- from ThirdNextVal to first closing bracket for this level [...[...]...], extracting array values
		my_tab_value := getComplexValueAsArray(my_obj, ThirdNextVal, 'ARRAY');
	  elsif (my_obj(SecondNextVal).type = 'OPENBRACE') then
	    -- This is an object
		-- from ThirdNextVal to first closing bracket for this level {...{...}...}, extracting object values
		my_tab_value := getComplexValueAsArray(my_obj, ThirdNextVal, 'OBJECT');
	  end if;
	  return my_tab_value;
	else
	  -- not an ATTRNAME returning a null array
	  return blank_tab;
	end if;
  exception
  when others then
     return blank_tab;
  end returnvalue;
  ----------------------------------------------------------------
begin
	-- remove indentation
	my_obj := removeIndent(my_obj);
	i := my_obj.first;
	while (i is not null) loop
	  if (upper(my_obj(i).item) = upper(g_stringDelimiter || replace(pname, g_stringDelimiter, null ) || g_stringDelimiter)) then
		  return returnvalue(i, pdecode);
	  end if;
	  i := my_obj.next(i);
	end loop;
	-- if we go here, the value for pname doesn't exist in p_obj, returning a null array.
    return blank_tab;
exception
  when no_data_found then
     return blank_tab;
end getAttrArray;

--------------------------------------------------------------------------------
-- Returns the value of an attribut. This can be an simple value or an array
--------------------------------------------------------------------------------
function getAttrValue( p_obj JSONStructObj, pname varchar2, pdecode boolean default true, 
		 			   pOutputStrDelimiter varchar2 default g_stringDelimiter,
					   pOutPutSeparator varchar2 default replace(g_separation, ' ', null)) return varchar2 is
  my_obj JSONStructObj := p_obj;
  i pls_integer;
  -----------------------------------------------------------------
  function returnvalue(pidx pls_integer, pdec boolean default true) return varchar2 is
    j pls_integer := pidx;
	FirstNextVal pls_integer := my_obj.next(j);
	SecondNextVal pls_integer := my_obj.next(FirstNextVal);
	ThirdNextVal pls_integer := my_obj.next(SecondNextVal);
	-- due to removing INDENTATION, the index may not be 2,3,4,5... but 2,4,5,8,...
	-- so we can't access to the structure with j, j+1, j+2,... 
	-- We'd better access by j, my_obj.next(j), my_obj.next(my_obj.next(j)), ...
	my_tab_value varchar2(32000);
  begin
	if (my_obj(j).type = 'ATTRNAME' ) then
	  -- see if the value is a table, an object or a simple value.
	  if (my_obj(SecondNextVal).type = 'ATTRDATA') then
	    -- this is a simple attribut
		if (pdec) then
		   initSpecCharTable;
		   my_tab_value := decodeValue(my_obj(SecondNextVal).item);
		else
		    my_tab_value := my_obj(SecondNextVal).item;
		end if;
	  elsif (my_obj(SecondNextVal).type = 'OPENBRACKET') then
	    -- This is a table
		-- from ThirdNextVal to first closing bracket for this level [...[...]...], extracting array values
		my_tab_value := getComplexValue(my_obj, ThirdNextVal, 'ARRAY');
	  elsif (my_obj(SecondNextVal).type = 'OPENBRACE') then
	    -- This is an object
		-- from ThirdNextVal to first closing bracket for this level {...{...}...}, extracting object values
		my_tab_value := getComplexValue(my_obj, ThirdNextVal, 'OBJECT');
	  end if;
	  -- see if custom separator and delimiter have been passed : formating return value.
	  -- for example if we received pOutputStrDelimiter= ' and  pOutPutSeparator= | 
	  -- we replace "," by '|'.
	  my_tab_value := replace(
	  			   	  		  replace(my_tab_value, g_stringDelimiter, pOutputStrDelimiter),
							  pOutputStrDelimiter||replace(g_separation, ' ', null)||pOutputStrDelimiter,
							  pOutputStrDelimiter||pOutPutSeparator||pOutputStrDelimiter
							  );
	  return my_tab_value;
	else
	  -- not an ATTRNAME returning null
	  return null;
	end if;
  exception
  when others then
     return null;
  end returnvalue;
  ----------------------------------------------------------------
begin
	-- remove indentation
	my_obj := removeIndent(my_obj);
	i := my_obj.first;
	while (i is not null) loop
	  if (upper(my_obj(i).item) = upper(g_stringDelimiter || replace(pname, g_stringDelimiter, null ) || g_stringDelimiter)) then
		  return returnvalue(i, pdecode);
	  end if;
	  i := my_obj.next(i);
	end loop;
	-- if we go here, the value for pname doesn't exist in p_obj.
    return null;
exception
  when no_data_found then
     return null;
end getAttrValue;


--------------------------------------------------------------------------------
-- Returns a JSON object with a varchar2 value
--------------------------------------------------------------------------------
function addAttr(p_obj JSONStructObj, n varchar2, v varchar2, p_formated boolean default false) return JSONStructObj is
	my_obj JSONStructObj := p_obj;
begin
-- 	if (g_doindetation) then
-- 	   my_obj(my_obj.last+1) := addItem('INDENTATION', g_CR || g_indent);
-- 	end if;
	my_obj(my_obj.last+1) := addItem('ATTRNAME', n);
	my_obj(my_obj.last+1) := addItem('AFFECTATION', g_Affectation);
	my_obj(my_obj.last+1) := addItem('ATTRDATA', v, p_formated);
	my_obj(my_obj.last+1) := addItem('SEPARATION', g_separation);
  return my_obj;
end addAttr;

--------------------------------------------------------------------------------
-- Returns a JSON object with a boolean value
--------------------------------------------------------------------------------
function addAttr(p_obj JSONStructObj, n varchar2, pbool boolean, p_formated boolean default false) return JSONStructObj is
  val varchar2(10) := bool2str(pbool);
begin
  return addAttr(p_obj, n, val, p_formated);
end addAttr;

--------------------------------------------------------------------------------
-- Returns a JSON object : The value could be an object
--------------------------------------------------------------------------------
function addAttr(p_obj JSONStructObj, n varchar2, p_objValue JSONStructObj) return JSONStructObj is
	my_obj JSONStructObj := p_obj;
    i pls_integer;
begin
-- 	if (g_doindetation) then
-- 	   my_obj(my_obj.last+1) := addItem('INDENTATION', g_CR || g_indent);
-- 	end if;
	my_obj(my_obj.last+1) := addItem('ATTRNAME', n);
	my_obj(my_obj.last+1) := addItem('AFFECTATION', g_Affectation);
	i := p_objValue.first;
	while (i is not null) loop
	  my_obj(my_obj.last+1) := addItem( p_objValue(i).type, p_objValue(i).item, p_objValue(i).formated);
	  i := p_objValue.next(i);
	end loop;
	my_obj(my_obj.last+1) := addItem('SEPARATION', g_separation);
  return my_obj;
end addAttr;

--------------------------------------------------------------------------------
-- Returns a JSON array of a plsql table (JSONArray type)
--------------------------------------------------------------------------------
function addArray(p_obj JSONStructObj, p_table JSONArray, p_formated boolean default false) return JSONStructObj is
   my_obj JSONStructObj := p_obj;
  i pls_integer;
  j pls_integer;
begin
    j := my_obj.first;
	-- if no object has been passed, that because the array is embeded
	if (j is null) then
	  j := 1;
	else 
	  j := my_obj.last+1;
	end if;
	--
	--my_obj(j) := addItem('INDENTATION', g_CR || g_indent);
    my_obj(j) := openArray;
	i := p_table.first;
	j := my_obj.last+1;
	while (i is not null) loop
	  if (i != p_table.first) then
	    my_obj(j) := addItem('SEPARATION', g_separation);
		j := j + 1;
	  end if;
	  my_obj(j) := addItem('ARRAYDATA', p_table(i), p_formated);
	  j := j + 1;
	  i := p_table.next(i);
	end loop;
	my_obj(my_obj.last+1) := closeArray;
	return my_obj;
end addArray;

--------------------------------------------------------------------------------
-- Returns a JSON array 
--------------------------------------------------------------------------------
function addArray(p_tab JSONArray, p_format boolean default false) return JSONStructObj is
begin
  return addArray(p_obj => nullObj, p_table => p_tab, p_formated =>p_format);
end addArray;

--------------------------------------------------------------------------------
-- Returns the JSON array into a string
--------------------------------------------------------------------------------
function array2String(p_tab JSONArray) return varchar2 is
  i pls_integer;
  myStrObj varchar2(32000);
begin
	-- fetching all the table
	i := p_tab.first;	   
	while (i is not null) loop
	  myStrObj := myStrObj || p_tab(i);
	  i := p_tab.next(i);
	end loop;
	return myStrObj;
end array2String;

--------------------------------------------------------------------------------
-- Returns the JSON object into a string
--------------------------------------------------------------------------------
function JSON2String(p_obj in out nocopy JSONStructObj, p_only_an_array boolean default false) return clob is
  i pls_integer;
  myStrObj clob;
begin
    if (p_only_an_array) then
	   -- the object only contains an array so remove { and }.
		i := p_obj.first;
		while (i is not null) loop
		  if( p_obj(i).type = 'OPENBRACE' ) then
		    p_obj.delete(i);
			exit;
		  end if;
		  i := p_obj.next(i);
		end loop;
		--
		i := p_obj.last;
		while (i is not null) loop
		  if( p_obj(i).type = 'CLOSEBRACE' ) then
		    p_obj.delete(i);
			exit;
		  end if;
		  i := p_obj.prior(i);
		end loop;
	end if;
	-- fetching all the object
	i := p_obj.first;	   
	while (i is not null) loop
	  myStrObj := myStrObj || p_obj(i).item;
	  i := p_obj.next(i);
	end loop;
	-- anti hijacking comments
	if (g_secure) then
	  myStrObj := g_js_comment_open || myStrObj || g_js_comment_close;
	end if;
	return myStrObj;
end JSON2String;

--------------------------------------------------------------------------------
-- Return a list as a simple json array
--------------------------------------------------------------------------------
function listToJsonArrayString(p_arr JSONArray) return varchar2
as
arr_string varchar2(32000);
begin
	arr_string := g_openBracket;
	for i in 1..p_arr.count loop
		arr_string := arr_string || g_stringDelimiter || p_arr(i) || g_stringDelimiter || g_separation;
	end loop;
	arr_string := substr(arr_string, 1, length(arr_string) - 2);
	arr_string := arr_string || g_closeBracket;

	return arr_string;
end listToJsonArrayString;

--------------------------------------------------------------------------------
-- Extract json docs from array of json docs
--------------------------------------------------------------------------------
procedure getJsonObjFromJsonObjArr( p_obj in JSONStructObj, jsonDocCount out pls_integer, f_obj out JSONStructObj) 
is
  my_obj JSONStructObj := p_obj;
  fixed_obj JSONStructObj;
  temp_obj JSONStructObj;
  ln_count_OpenBracket pls_integer := 0;
  my_value JSONArray;
  blank_tab JSONArray;
  i number := 1; -- index of the array of values which are extracted from jsonStruct.
  j pls_integer := 1;
  
  main_open varchar2(20) := 'OPENBRACKET';
  main_start pls_integer;
  main_close varchar2(20) := 'CLOSEBRACKET';
  main_end pls_integer;
  lv_what varchar2(10);
  in_doc boolean := false;
begin

	jsonDocCount := 0;

	json.newjsonobj(fixed_obj);
	json.newjsonobj(temp_obj);

	lv_what := 'BRACE';
    
	while (j is not null) loop
	  -- dbms_output.put_line('C as of now: ' || ln_count_OpenBracket);
	  if ln_count_OpenBracket >= 1 then
	  	in_doc := true;
	  end if;
	  if(my_obj(j).type = main_open) then
	  	main_start := j;
	  end if;
	  if(my_obj(j).type = main_close) then
	  	main_end := j;
	  end if;

	  -- dbms_output.put_line(my_obj(j).type);
	  if(my_obj(j).type = 'OPEN'||lv_what) then
	  	-- dbms_output.put_line('Got open');
	    ln_count_OpenBracket := ln_count_OpenBracket + 1;
	  elsif (my_obj(j).type = 'CLOSE'||lv_what) then
	  	-- dbms_output.put_line('Got close');
	    ln_count_OpenBracket := ln_count_OpenBracket - 1;
	  end if;

	  if ln_count_OpenBracket >= 1 then
	  	-- Add to temp obj for replacement
		temp_obj(i) := my_obj(j);
		i := i + 1;
	  end if;

	  -- dbms_output.put_line('C as of now: ' || ln_count_OpenBracket);
	  if (ln_count_OpenBracket = 0 and in_doc) then
	    jsonDocCount := jsonDocCount + 1;
	    json.closejsonobj(temp_obj);
	    fixed_obj := addAttr(fixed_obj, 'AV_' || jsonDocCount, temp_obj);
	    json.newjsonobj(temp_obj);
	    in_doc := false;
	    i := 1;
	  end if;
	  j := my_obj.next(j);
	end loop;
	-- Handle objs
	json.closejsonobj(fixed_obj);
	f_obj := fixed_obj;
  exception
  when others then
     raise;
end getJsonObjFromJsonObjArr;

--------------------------------------------------------------------------------
-- Returns a JSON object with a string
--------------------------------------------------------------------------------
function String2JSON(p_str clob, pStrDelimiter varchar2 default g_stringDelimiter) return JSONStructObj is
  Obj JSONStructObj;
  tmpStr clob := p_str;
  buf clob;
  i pls_integer := 1;
  CutPosition pls_integer := 1;
  my_tabTmp JSONArray;
  x_bad_JSONstruct exception;
  
  haveSeen_attrname boolean := false;
  we_are_in_a_table boolean := false;
  chrTmp varchar2(1);
  typeTmp varchar2(20);
  itemTmp varchar2(2000);
begin
	-- defining string delimiter 
	g_stringDelimiter := pStrDelimiter;
	
    -- formatting the string 
	-- suppress CR
	tmpStr := replace (tmpStr, g_CR, ' ');
	
	-- Suppress anti-hijacking comments
	tmpStr := replace (tmpStr, g_js_comment_open, ' ');
	tmpStr := replace (tmpStr, g_js_comment_close, ' ');
		
	-- turning to null the spacing before and afters symbols 
	g_openBrace := replace(g_openBrace, ' ', null);
	g_closeBrace := replace(g_closeBrace, ' ', null);
	g_openBracket := replace(g_openBracket, ' ', null);
	g_closeBracket := replace(g_closeBracket, ' ', null);
	g_Affectation := replace(g_Affectation, ' ', null);
	g_separation := replace(g_separation, ' ', null);

    -- suppress indentation, and non usefull spaces
	while (  instr(tmpStr, '  ') > 0 ) loop
		  tmpStr := replace (tmpStr, '  ', ' ');
	end loop;	

	-- replace backSlash + StringDelimiter with a sequence of easy identifiable characters 
	tmpStr := replace(tmpStr, '\'||g_stringDelimiter, '\§');
	
	-- placing the string into the jsonS tructure
	i := 1;
	--
	-- BUG : Seems to have an infinite loop when the json object is not correct ??
	-- 	   	 that's why there is the condition : "and i < 1000"
	-- I have to correct that sucking bug...
	--
	while (length(tmpStr) > 0  and i < 10000) loop
		    -- removing first spaces
		while (  substr(tmpStr,1,1) = ' ' ) loop
			  tmpStr := substr(tmpStr,2, length(tmpStr));
		end loop;	
		-- now : it's ' or { or [
		chrTmp := substr(tmpStr,1,1);
		if ( chrTmp = g_openBrace) then
		  Obj(i) := openObj;
		  haveSeen_attrname := false;
		  tmpStr := substr(tmpStr, 2);
		  
		elsif (chrTmp = g_openBracket) then
		  Obj(i) := openArray;
		  we_are_in_a_table := true;
		  tmpStr := substr(tmpStr, 2);
		  
		elsif (chrTmp = g_closeBrace) then
		  Obj(i) := closeObj;
		  tmpStr := substr(tmpStr, 2);
		  
		elsif (chrTmp = g_closeBracket) then
		  Obj(i) := closeArray;
		  we_are_in_a_table := false;
		  tmpStr := substr(tmpStr, 2);
		  
		elsif (chrTmp = g_stringDelimiter) then
		  if (haveSeen_attrname or we_are_in_a_table) then
			  if (haveSeen_attrname) then
			    typeTmp := 'ATTRDATA';
				haveSeen_attrname := false;
			  end if;
			  if (we_are_in_a_table) then
			    typeTmp := 'ARRAYDATA';
			  end if;
		  else
		    typeTmp := 'ATTRNAME';
			haveSeen_attrname := true;
		  end if;
		  Obj(i) := addItem(typeTmp , substr(tmpStr, 1, instr(tmpStr, g_stringDelimiter, 2)), true);
		  tmpStr := substr(tmpStr, instr(tmpStr, g_stringDelimiter, 2)+1);
		  
		elsif (chrTmp = g_Affectation) then
		  Obj(i) := addItem('AFFECTATION', g_Affectation, false);
		  tmpStr := substr(tmpStr, 2);
		  
		elsif (chrTmp = g_separation) then
		  Obj(i) := addItem('SEPARATION', g_separation, false);
		  tmpStr := substr(tmpStr, 2);
		  
		else
		  -- if the data is a number, there's no string delimiter
		  if (haveSeen_attrname or we_are_in_a_table) then
			  if (haveSeen_attrname) then
			    typeTmp := 'ATTRDATA';
				haveSeen_attrname := false;
			  end if;
			  if (we_are_in_a_table) then
			    typeTmp := 'ARRAYDATA';
			  end if;
			  -- see if we are at the end of a table or an objet => no separation !
			  if (instr(tmpStr, g_separation, 1) = 0 ) then
			    if (instr(tmpStr, g_closeBracket, 1) = 0 ) then
				  if (instr(tmpStr, g_closeBrace, 1) = 0 ) then
				    -- bad struture !
				    raise x_bad_JSONstruct;
				  else
					-- last data before ending an object
					itemTmp := substr(tmpStr, 1, instr(tmpStr, g_closeBrace, 1)-1);
					tmpStr := substr(tmpStr, instr(tmpStr, g_closeBrace, 1));
				  end if;
				else
				  -- last data before ending an array
				  itemTmp := substr(tmpStr, 1, instr(tmpStr, g_closeBracket, 1)-1);
				  tmpStr := substr(tmpStr, instr(tmpStr, g_closeBracket, 1));
				end if;
			  else
			    -- Some data
				itemTmp := substr(tmpStr, 1, instr(tmpStr, g_separation, 1)-1);
				tmpStr := substr(tmpStr, instr(tmpStr, g_separation, 1));
			  end if;
			  
		  	 Obj(i) := addItem( typeTmp, replace(itemTmp, '\§', '\'||g_stringDelimiter), true);
		  end if;
		  
		end if;
		i := i+1;
    end loop;	

	return Obj;
exception
  when x_bad_JSONstruct then
    print('Bad JSON structure : missing "'||g_openBrace||'" or "'||g_closeBrace||'".');
	return nullObj;
end String2JSON;

--------------------------------------------------------------------------------
-- Dumping pl/sql structure using print routine.
--------------------------------------------------------------------------------
procedure HTMLdumpJSONObj(p_obj in out nocopy JSONStructObj) is
  i pls_integer;
begin
	print('<style>
	#dump {font-size:9px;}
	#dump table {border:1px dashed #cccccc;}
	#dump table tr td{text-align:center;}
	#idx, #nok {color:red;font-size:7px;}
	#type, #ok {color:green;font-size:7px;}
	#formated {color:blue;}
	#item {color:black; font-weight:bold; font-size:11px;}
	</style>');
	print('<table id="dump"><tr>');
	i := p_obj.first;
	while (i is not null) loop
	  print('<td><table>');
	  print('<tr><td id="idx">'||i||'</td></tr>');
	  print('<tr><td id="type">'||p_obj(i).type||'</td></tr>');
	  print('<tr><td id="formated">'||bool2str(p_obj(i).formated)||'</td></tr>');
	  print('<tr><td id="item">'||p_obj(i).item||'</td></tr>');
	  print('</table></td>');
	i := p_obj.next(i);
	end loop;
	print('</tr></table>');
end HTMLdumpJSONObj;

--------------------------------------------------------------------------------
-- Printing the version of this package
--------------------------------------------------------------------------------
function getVersion return varchar2 is
begin
  return g_package_version;
end getVersion;

--------------------------------------------------------------------------------
-- Testing this package
--------------------------------------------------------------------------------
procedure test is
  my_str    varchar2(255) := '", '||chr(8)||', '||chr(9)||', '||chr(10)||', '||chr(12)||', '||chr(13)||', /, \, #hexABCD ';
  my_tab 	JSONArray;
  my_obj    JSONStructObj;
  my_obj2   JSONStructObj;
  my_objInStr varchar2(8000);
  val number;
	  --------------------------------------------------------------------------------
	  function assertDifferent( calculated_value number, ref_value number, 
	  		   				Ok_msg varchar2 default 'OK', error_msg varchar2) 
	  return varchar2 is
	  begin
	    if (calculated_value != ref_value) then
		  return 'result : '|| calculated_value||'. <span id="ok">'||ok_msg||'</span>';
		end if;
		return 'result : '|| calculated_value||'.<span id="nok">'||error_msg||'</span>';
	  end assertDifferent;
	  --------------------------------------------------------------------------------
	  function assertEqual( calculated_value number, ref_value number, 
	  		   				Ok_msg varchar2 default 'OK', error_msg varchar2) 
	  return varchar2 is
	  begin
	    if (calculated_value = ref_value) then
		  return 'result : '|| calculated_value||'.<span id="ok">'||ok_msg||'</span>';
		end if;
		return 'result : '|| calculated_value||'.<span id="nok">'||error_msg||'</span>';
	  end assertEqual;
	  --------------------------------------------------------------------------------
begin
  print('<h2>JSON PL/SQL Package - '||getVersion||'</h2>');
  --
  -- Value encoded
  --
  newJSONObj(my_obj);
  Print('<hr><h5>Testing the decoder</h5><br>');
  Print('values => '||my_str||'<br>');
  Print('encoded values => '||formatValue(my_str));
  --
  -- simple object
  --
  Print('<hr><h5>simple object</h5><br>');
  newJSONObj(my_obj);
  my_obj := addAttr(my_obj, 'FirstName', 'Pierre-Gilles/"levallois"\');
  my_obj := addAttr(my_obj, 'UserID', '1234');
  closeJSONObj(my_obj);
  print(JSON2String(my_obj));
  print('<br>');
  HTMLdumpJSONObj(my_obj);
  --
  -- Simple table
  --
  Print('<hr><h5>simple table</h5><br>');
  my_tab(1):= 'a';
  my_tab(my_tab.last+1):= 'b';
  my_tab(my_tab.last+1):= 'c';
  my_tab(my_tab.last+1):= 'd';
  my_tab(my_tab.last+1):= '1';
  my_tab(my_tab.last+1):= '2';
  my_tab(my_tab.last+1):= '3';
  my_tab(my_tab.last+1):= '-1,1';
  my_tab(my_tab.last+1):= '2e2';
  newJSONObj(my_obj);
  my_obj := addArray(my_obj, my_tab);
  closeJSONObj(my_obj);
  print(JSON2String(my_obj, true));
  --
  -- Complex object
  --
  print('<hr><h5>Complex object</h5><br>');
  newJSONObj(my_obj);
  my_obj := addAttr(my_obj, 'Table', addArray(my_tab));
  closeJSONObj(my_obj);
  print(JSON2String(my_obj));
  --
  -- Complex object 2
  --  
  print('<hr><h5>Complex object 2</h5><br>');  
  newJSONObj(my_obj);
  my_obj := addAttr(my_obj, 'UserID', '1234');
  my_obj := addAttr(my_obj, 'Table', addArray(my_tab));
	  newJSONObj(my_obj2);
	  my_obj2 := addAttr(my_obj2, 'email', 'me@mydomin.com');
	  my_obj2 := addAttr(my_obj2, 'adr', '1, rue de Paris 69001 Lyon');
	  closeJSONObj(my_obj2);
  my_obj := addAttr(my_obj, 'Addresses', my_obj2);
  closeJSONObj(my_obj);
  print(JSON2String(my_obj));
  --
  -- testing Decoding function and getters
  --
  print('<hr><h5>testing Decoding function and getters</h5><br>');
  print('<hr>Object is :');
  print(JSON2String(my_obj)||'<br>');
  HTMLdumpJSONObj(my_obj);
  print('<hr>Trying to get UserID''s value with getAttrValue() : <br>'); 
  print(getAttrValue(my_obj, 'UserID'));
  print('<br>Trying to get adr''s value with getAttrValue() : <br>'); 
  print(getAttrValue(my_obj, 'adr'));
  print('<br>Trying to get a table with getAttrValue() : <br>'); 
  print(getAttrValue(my_obj, 'table'));
  
  print('<br>Trying to get the same table with getAttrValue() and delimiter = " and separator = | : <br>'); 
  print(getAttrValue(my_obj, 'table', true, '"', '|'));

  print('<br>Trying to get the same table with getAttrArray()'); 
  my_tab := getAttrArray(my_obj,'table', true);
  for i in my_tab.first..my_tab.last loop
    print('my_tab('||i||')='||my_tab(i)||'<br/>');
  end loop;
    
  print('<br>Trying to get an object (Addresses) with getAttrValue() : <br>'); 
  print(getAttrValue(my_obj, 'Addresses'));
  
  print('<hr><h5>testing setAttrSimpleValue</h5><br>');
  print('<br>Trying to set UserID''s value with "4321" :<br>'); 
  my_obj := setAttrSimpleValue(my_obj,'UserID', '4321');
  HTMLdumpJSONObj(my_obj);
  print('<br>Trying to set email''s value with "webmaster@laclasse.com" :<br>'); 
  my_obj := setAttrSimpleValue(my_obj,'email', 'webmaster@laclasse.com');
  HTMLdumpJSONObj(my_obj);
  
  --
  --   Testing String2JSON
  --
  Print('<hr><h5>Testing the deserializer String2JSON</h5><br>');
  my_objInStr := '{"id":"25820","img":"picto_img.gif","checksum":"8744","txt":"<a href=\"javascript:go2(25820, ''597f5f4533730c881ddd96d4b8d63e02'');\" class=\"docUrlF\">test</a>","nature":"ELT","draggable":1,"imgopen":"folderopen.gif","imgclose":"folder.gif","imgselected":"page.gif","imgopenselected":"folderopen.gif","imgcloseselected":"folder.gif","open":true,"check":0,"canhavechildren":false,"acceptdrop":true,"last":false,"editable":true,"checkbox":true,"ondropajax":true,"droplink":"http://ias.erasme.lan/pls/education/!ajax_server.service?serviceName=service_deplacer&p_rendertype=none"}';
  print(my_objInStr||'<br>');
  my_obj := String2JSON(my_objInStr, '"');
  print('Here is the object after calling String2JSON<br>');
  HTMLdumpJSONObj(my_obj);
  print('<hr>Trying to get nature''s value with getAttrValue() : <br>'); 
  print(getAttrValue(my_obj, 'nature'));
  --
  --   Testing String2JSON with array
  --
  Print('<hr><h5>Testing the deserializer String2JSON with array</h5><br>');
  my_objInStr := '{''3B'':[''ACCOMPAGNEMENT TRAVAIL PERSONNEL''],''3C'':[''PHYSIQUE-CHIMIE''],''4C'':[''PHYSIQUE-CHIMIE''],''4A'':[''PHYSIQUE-CHIMIE''],''4B'':[''PHYSIQUE-CHIMIE''],''6D'':[''PHYSIQUE-CHIMIE'']}';
  print(my_objInStr||'<br>');
  my_obj := String2JSON(my_objInStr, '''');
  print('Here is the object after calling String2JSON<br>');
  HTMLdumpJSONObj(my_obj);
  print('<hr>Trying to get 3B''s value with getAttrValue() : <br>'); 
  print(getAttrValue(my_obj, '3B'));
  --
  -- Testing validation function
  --
  print('<hr><h5>testing validation function</h5><br>');
  my_objInStr := '{"id":"25820","img":"picto_img.gif"';
  print('<br>Here is an incorrect Json Object : '||my_objInStr||'<br>');
  my_obj := String2JSON(my_objInStr, '"');
  HTMLdumpJSONObj(my_obj);
  print('Now calling validateJSONObj<br>');
  print('Result of json validation : '||assertDifferent(validateJSONObj(my_obj, true),0, 'The validateJSONObj function is correct.', 'This should not be 0 because the object is inccorect.'));
  
  my_objInStr := '"id":"25820","img":"picto_img.gif"}';
  print('<br><br>Here is an incorrect Json Object : '||my_objInStr||'<br>');
  my_obj := String2JSON(my_objInStr, '"');
  HTMLdumpJSONObj(my_obj);
  print('Now calling validateJSONObj<br>');
  print('Result of json validation : '||assertDifferent(validateJSONObj(my_obj, true),0, 'The validateJSONObj function is correct.', 'This should not be 0 because the object is inccorect.'));
  
  my_objInStr := '{"id":"25820","img": ["picto_img.gif",}';
  print('<br><br>Here is an incorrect Json Object : '||my_objInStr||'<br>');
  my_obj := String2JSON(my_objInStr, '"');
  HTMLdumpJSONObj(my_obj);
  print('Now calling validateJSONObj<br>');
  print('Result of json validation : '||assertDifferent(validateJSONObj(my_obj, true),0, 'The validateJSONObj function is correct.', 'This should not be 0 because the object is inccorect.'));
 
  my_objInStr := '{"id":"25820","imgs" : { img1 : "picto_img.gif", "width" : 100, "height" : 200 }, }';
  print('<br><br>Here is an incorrect Json Object : '||my_objInStr||'<br>');
  my_obj := String2JSON(my_objInStr, '"');
  HTMLdumpJSONObj(my_obj);
  print('Now calling validateJSONObj<br>');
  print('Result of json validation : '||assertDifferent(validateJSONObj(my_obj, true),0, 'The validateJSONObj function is correct.', 'This should not be 0 because the object is inccorect.'));
exception
  when others then
    print(sqlerrm);
end test;

END JSON;
/
