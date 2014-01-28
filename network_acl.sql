BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'github_acl.xml', 
    description  => 'ACL definition for Github.com access',
    principal    => 'ORACLEGIT',
    is_grant     => TRUE, 
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);

  COMMIT;

dbms_network_acl_admin.add_privilege (
			acl	 => 'github_acl.xml',
			principal	 => 'ORACLEGIT',
			is_grant	 => true,
			privilege	 => 'resolve'
		);
		commit;

		dbms_network_acl_admin.assign_acl (
			acl          => 'github_acl.xml',
			host         => 'api.github.com',
			lower_port	 => 443,
			upper_port	 => null
		);
		commit;

  COMMIT;
END;
/