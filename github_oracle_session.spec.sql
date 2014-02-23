create or replace package github_oracle_session

as

	/** Github -> Oracle -> Github Session functions. This package is used to setup your
	* oracle session to work with a GitHub session. This should always be run before you start
	* using any of the API packages. If not, you need to run the setup procedures from the main
	* github package yourself.
	* @author Morten Egan (github.com/morten-egan)
	* @project OracleGit
	* @version 0.1.0
	*/

	ssl_w_l			varchar2(4000);
	ssl_w_p 		varchar2(4000) := null;
	gh_l_u 			varchar2(4000);
	gh_l_p 			varchar2(4000);
	gh_r 			varchar2(4000);
	gh_r_o 			varchar2(4000);
	gh_p_m			varchar2(4000) := 'Auto push from github_utl';

	/** Setup session variables for current oracle session
	* @author Morten Egan
	* @param ssl_wallet_location The location of the oracle wallet containing the Github ssl certificates
	* @param ssl_wallet_password The password to the wallet
	* @param github_logon_user The user that we logon to github
	* @param github_logon_pass The password of the logon user
	* @param github_repository The repository we want to work on 
	* @param github_repository_owner The owner of the repository we work on 
	*/
	procedure set_github (
		ssl_wallet_location			in			varchar2 default null
		, ssl_wallet_password		in 			varchar2 default null
		, github_logon_user			in 			varchar2 default null
		, github_logon_pass 		in			varchar2 default null
		, github_repository 		in			varchar2 default null
		, github_repository_owner	in 			varchar2 default null
	);

	/** Set the commit message to use when pushing content to repository
	* @author Morten Egan
	* @param push_message The commit message to use when commiting content
	*/
	procedure set_message (
		push_message				in			varchar2 default 'Auto push from github_utl'
	);

end github_oracle_session;
/