CREATE OR REPLACE PACKAGE JSON AS
/******************************************************************************
   NAME:       JSON
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.1        04/12/2007             1. Created this package.
******************************************************************************/
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
********************************************************************************/
--------------------------------------------------------------------------------
-- Global Types and records
--------------------------------------------------------------------------------
-- type for JSON Array
type JSONArray is table of varchar2(2000) index by binary_integer;

-- type for all Name/Value Couples in JSON
type gr_JSONnvCouple is record (name varchar2(255), value varchar2(2000));

-- Type for the final JSON generated string
type JSONItem is record ( type varchar2(100),  -- OPENBRACE, OPENHOOK, CLOSEBRACE, CLOSEHOOK, 
	 		  	 		  	   				   -- SEPARATION, AFFECTATION, ATTRNAME, ATTRDATA, ARRAYDATA
											   -- INDENTATION
	 		  	 		  item varchar2(2000), -- the attribute name or value.
						  formated boolean default false); -- true if "item" has been already formatted.				  
type JSONStructObj is table of JSONItem index by binary_integer;

--------------------------------------------------------------------------------
-- Global variables and constants
--------------------------------------------------------------------------------
-- Package Version
g_package_version constant varchar2(100) := '1.1';
-- 
g_openBrace       	 varchar2(2) := '{';
g_closeBrace 	 varchar2(2) := '}';
g_openBracket 	 	 varchar2(2) := '[ ';
g_closeBracket  	 varchar2(2) := ' ]';
g_stringDelimiter 	 varchar2(1) := '"';
g_Affectation 		 varchar2(3) := ': ';
g_separation 	 	 varchar2(3) := ', ';
g_CR				 varchar2(1) := Chr(10); -- used to indent the JSON object correctly
g_spc				 varchar2(2) := '  ';	 -- used to indent the JSON object correctly
g_js_comment_open	 varchar2(20) := '/*-secure-\n'; -- used to prevent from javascript hijacking
g_js_comment_close	 varchar2(20) := '\n*/';	 	 -- used to prevent from javascript hijacking

g_indent varchar2(2000) := null;  -- count the recursive imbrications for object 
		  				 	   	  -- +2 spaces when calling openObj 
								  -- -2 spaces when calling closeObj

--------------------------------------------------------------------------------
-- Public proc. and  funct. signatures
--------------------------------------------------------------------------------
procedure newJSONObj(p_obj in out nocopy JSONStructObj, p_doindetation boolean default true, p_secure boolean default false);
procedure closeJSONObj(p_obj in out nocopy JSONStructObj);
function addAttr(p_obj JSONStructObj, n varchar2, v varchar2, p_formated boolean default false) return JSONStructObj;
function addAttr(p_obj JSONStructObj, n varchar2, pbool boolean, p_formated boolean default false) return JSONStructObj;
function addAttr(p_obj JSONStructObj, n varchar2, p_objValue JSONStructObj) return JSONStructObj;
function addArray(p_tab JSONArray, p_format boolean default false) return JSONStructObj;
function addArray(p_obj JSONStructObj, p_table JSONArray, p_formated boolean default false) return JSONStructObj;
function array2String(p_tab JSONArray) return varchar2;
function JSON2String(p_obj in out nocopy JSONStructObj, p_only_an_array boolean default false) return clob;
function String2JSON(p_str clob, pStrDelimiter varchar2 default g_stringDelimiter) return JSONStructObj;
procedure HTMLdumpJSONObj(p_obj in out nocopy JSONStructObj);
function getAttrValue( p_obj JSONStructObj, pname varchar2, pdecode boolean default true, 
		 			   pOutputStrDelimiter varchar2 default g_stringDelimiter,
					   pOutPutSeparator varchar2 default replace(g_separation, ' ', null)) return varchar2;
function getAttrArray( p_obj JSONStructObj, pname varchar2, pdecode boolean default true) return JSONArray;
function setAttrSimpleValue(p_obj JSONStructObj, pname varchar2, pvalue varchar2, pformated boolean default false) return JSONStructObj;
function setAttrSimpleValue(p_obj JSONStructObj, pname varchar2, pbool boolean, pformated boolean default false) return JSONStructObj;
function validateJSONObj(p_obj in out nocopy JSONStructObj, pvalidate boolean default false) return pls_integer;
procedure print(p_str varchar2);
function getVersion return varchar2;
procedure streamOutput(pobj JSONStructObj);
procedure test;

procedure getJsonObjFromJsonObjArr( p_obj in JSONStructObj, jsonDocCount out pls_integer, f_obj out JSONStructObj);
function getComplexValue( p_obj JSONStructObj, pidx pls_integer, p_ArrayOrObject varchar2 default 'ARRAY') return varchar2;
function getComplexValueAsArray( p_obj JSONStructObj, pidx pls_integer, p_ArrayOrObject varchar2 default 'ARRAY') return JSONArray;

function listToJsonArrayString(p_arr JSONArray) return varchar2;

END JSON;
/
