nobase_dist_sysconf_DATA = profile.d/setoraenv.sh 

do_subst = sed -i \
	-e 's;[@]BASEDIR[@];$(prefix);g' \
	-e 's;[@]SBINDIR[@];$(sbindir);g' \
	-e 's;[@]BINDIR[@];$(bindir);g' \
	-e 's;[@]LIBDIR[@];$(libdir);g' \
	-e 's;[@]PKGDATADIR[@];$(pkgdatadir);g' \
	-e 's;[@]LIBEXECDIR[@];$(libexecdir);g'  \
	-e 's;[@]DATADIR[@];$(datadir);g' \
	-e 's;[@]SYSCONFDIR[@];$(sysconfdir);g' \
	-e 's;[@]LOCALSTATEDIR[@];$(localstatedir);g' \
	-e 's;[@]PACKAGE[@];$(PACKAGE);g' \
	-e 's;[@]PREFIX[@];$(prefix);g' \
	-e 's;[@]PYTHON_VERSION[@];$(PYTHON_VERSION);g'

install-data-hook:
	cd $(DESTDIR)/$(sysconfdir) ;\
	for file in $(nobase_dist_sysconf_DATA) ;\
	do \
		$(do_subst) $$file ;\
	done 


