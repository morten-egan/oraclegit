create or replace package github_oracle_content

as

	/** Github -> Oracle -> Github Helper functions. This package abstracts a lot of the basic
	* functionality that exists in the github api packages, into more usable functions inside
	* of the Oracle database.
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	/** Build a github object path for an oracle object
	* @author Morten Egan
	* @param object_name The name of the Oracle object to push
	* @param object_type Type of object. This will define the path of the object
	* @param object_owner Owner of the object
	* @return The github path of the object
	*/
	function get_object_path (
		object_name	 			in 			varchar2
		, object_type			in 			varchar2
		, object_owner 			in 			varchar2 default user
	)
	return varchar2;

	/** Push database object to repository. It will either create a new file, or update
	* an existing file in the github repository
	* @author Morten Egan
	* @param object_name The name of the Oracle object to push
	* @param object_type Type of object. This will define the path of the object
	* @param object_owner Owner of the object
	*/
	procedure push_object (
		object_name	 			in 			varchar2
		, object_type			in 			varchar2
		, object_owner 			in 			varchar2 default user
		, object_content		in 			clob default null
	);

	/** Push all plsql code from the current schema
	* @author Morten Egan
	* @param split_packages True if spec and body should be seperate. Default true
	*/
	procedure push_schema_code(
		split_packages			in 			boolean default true
	);

	/** Compare a database object with the github repository version
	* @author Morten Egan
	* @param object_name The name of the Oracle object to push
	* @param object_type Type of object. This will define the path of the object
	* @param object_owner Owner of the object
	*/
	function compare_object (
		object_name				in 			varchar2
		, object_type			in 			varchar2
		, object_owner			in 			varchar2 default user
	)
	return varchar2;

end github_oracle_content;
/