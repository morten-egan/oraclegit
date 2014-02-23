create or replace package body github_oracle_session

as

	procedure set_github (
		ssl_wallet_location			in			varchar2 default null
		, ssl_wallet_password		in 			varchar2 default null
		, github_logon_user			in 			varchar2 default null
		, github_logon_pass 		in			varchar2 default null
		, github_repository 		in			varchar2 default null
		, github_repository_owner	in 			varchar2 default null
	)

	as

	begin

		if ssl_wallet_location is not null then
			ssl_w_l := ssl_wallet_location;
		end if;

		if (ssl_w_p is null and ssl_wallet_password is not null) or (ssl_w_p is not null and ssl_wallet_password is not null) then
			ssl_w_p := ssl_wallet_password;
		end if;

		if github_logon_user is not null then
			gh_l_u := github_logon_user;
		end if;

		if github_logon_pass is not null then
			gh_l_p := github_logon_pass;
		end if;

		if github_repository is not null then
			gh_r := github_repository;
		end if;

		if github_repository_owner is not null then
			gh_r_o := github_repository_owner;
		end if;

		github.set_session_wallet(ssl_w_l, ssl_w_p);
		github.set_logon_info(gh_l_u, gh_l_p);

	end set_github;

	procedure set_message (
		push_message				in			varchar2 default 'Auto push from github_utl'
	)

	as

	begin

		if push_message is not null then
			gh_p_m := push_message;
		else
			gh_p_m := 'Auto push from github_utl';
		end if;

	end set_message;

end github_oracle_session;
/