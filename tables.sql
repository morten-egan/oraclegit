/* ============================= */
create table oraclegit_env (
	environment_name		varchar2(100)		constraint oraclegit_env_pk primary key
	, environment_value		varchar2(4000)
);

insert into oraclegit_env values ('branch_level_setting', 'PRODMASTER');
insert into oraclegit_env values ('github_issues', 'N');
insert into oraclegit_env values ('privacy_level', 'PUBLIC');
insert into oraclegit_env values ('default_branch', 'DEV');
insert into oraclegit_env values ('multiple_schema_repos', 'N');
insert into oraclegit_env values ('github_wallet_location', 'file:/home/oracle/wallet');
insert into oraclegit_env values ('github_wallet_passwd', 'Manager123');
insert into oraclegit_env values ('github_api_location', 'https://api.github.com');

create table github_organization (
	org_name				varchar2(200)		constraint github_org_pk primary key
);

create table github_account (
	github_username			varchar2(200)		constraint github_account_pk primary key
	, github_password 		varchar2(4000)		constraint github_password_nn not null
	, github_name 			varchar2(4000)
	, github_email			varchar2(4000)
	, org_name				varchar2(200)		constraint github_account_org_ref references github_organization(org_name)
);

create table github_repository (
	repository_name			varchar2(4000)		constraint gh_repos_pk primary key
	, org_name				varchar2(200)		constraint gh_rep_org_ref references github_organization(org_name)
	, repository_owner		varchar2(200)		constraint gh_rep_owner_ref references github_account(github_username)
	, repository_branch		varchar2(200)		default 'DEV'
);

create table repository_schema (
	schema_name				varchar2(200)		constraint rep_schema_pk primary key
	, repository 			varchar2(4000)		constraint schema_rep_ref references github_repository(repository_name)
);

create table repository_objects (
	repository_name			varchar2(4000)		constraint object_rep_ref references github_repository(repository_name)
	, schema_name			varchar2(200)		constraint object_schema_ref references repository_schema(schema_name)
	, object_name			varchar2(200)		constraint object_name_nn not null
	, object_type			varchar2(200)		constraint object_type_nn not null
	, object_path 			varchar2(4000)		constraint object_path_nn not null
	, object_sha 			varchar2(4000)		constraint object_sha_nn not null
);