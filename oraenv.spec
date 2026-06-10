%define _prefix /usr/local

Name:		%(sed -n '/AC_INIT/ s;.*\[\(.*\)\],.*,.*;\1;p' configure.ac)
Version:	%(sed -n '/AC_INIT/ s;.*,\[\(.*\)\],.*;\1;p' configure.ac)
Release:	1%{?dist}
Summary:	Utilities for Setting Oracle Database environment 

Group:		Productivity/Database/Tools
License:	GPL
URL:		www.oracle.com
Vendor:		SA
Packager:	Simon Anthony
Source0:	%{name}-%{version}.tar.gz

Requires: bash
BuildRequires: bash, autoconf, automake


%global debug_package %{nil}

%description
Supporting scripts and tools for Oracle environment settings for databse clients


%prep
%setup -q


%build
%configure \
	--prefix=%{_prefix} \
	--bindir=%_bindir \
	--sbindir=%_sbindir \
	--datadir=%_datadir \
	--sysconfdir=%_sysconfdir \
	--libdir=%_libdir \
	--includedir=%_includedir \
	--localstatedir=%{_localstatedir} \
	--libexecdir=%{_libexecdir} \
	--mandir=%{_prefix}/share/man 
make %{?_smp_mflags}


%install
[ %buildroot != "/" ] && rm -rf %buildroot
make DESTDIR=%buildroot install


%clean
[ %buildroot != "/" ] && rm -rf %buildroot


%post

%preun
cp -p %{_bindir}/oraenv %{_bindir}/oraenv.bak
cp -p %{_bindir}/coraenv %{_bindir}/coraenv.bak
cp -p %{_bindir}/dbhome %{_bindir}/dbhome.bak


%postun
mv %{_bindir}/oraenv.bak %{_bindir}/oraenv
mv %{_bindir}/coraenv.bak %{_bindir}/coraenv
mv %{_bindir}/dbhome.bak %{_bindir}/dbhome


%files
%{_bindir}/oraenv
%{_bindir}/dbhome
%{_bindir}/coraenv
%attr(4750,oracle,oinstall)      %{_bindir}/oratab
%{_sysconfdir}/profile.d/*
%{_mandir}/man?/*


%changelog

