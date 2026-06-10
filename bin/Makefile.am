bin_PROGRAMS = oratab

SUFFIXES = .sh .py

do_subst = sed \
	-e 's;[@]BASEDIR[@];$(prefix);g' \
	-e 's;[@]SBINDIR[@];$(sbindir);g' \
	-e 's;[@]BINDIR[@];$(bindir);g' \
	-e 's;[@]LIBDIR[@];$(libdir);g' \
	-e 's;[@]DATADIR[@];$(datadir);g' \
	-e 's;[@]LIBEXECDIR[@];$(libexecdir);g'  \
	-e 's;[@]SYSCONFDIR[@];$(sysconfdir);g' \
	-e 's;[@]LOCALSTATEDIR[@];$(localstatedir);g' \
	-e 's;[@]PACKAGE[@];$(PACKAGE);g' \
	-e 's;[@]PREFIX[@];$(prefix);g' \
	-e 's;[@]PYTHON_VERSION[@];$(PYTHON_VERSION);g' \
	-e 's;[@]EMCLI_DIR[@];$(emclibindir);g'

.sh:
	@$(do_subst) < $< > $@
	@chmod +x $@

.py:
	@$(do_subst) < $< > $@
	@chmod +x $@

bin_SCRIPTS = \
	oraenv \
	dbhome \
	coraenv 

CLEANFILES = $(bin_SCRIPTS)

EXTRA_DIST = \
	oraenv.sh \
	dbhome.sh \
	coraenv.sh 
