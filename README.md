# An Extended oraenv Mechanism

Tools to support setting Oracle database client environment

## Overview

This package aims to simplify maintenance of environment settings and also
extended the capability to maintain environment settings for database
instances.

### oraenv

The *oraenv* script is the standard program used to set the environemnt for
Oracle database client access on UNIX like platforms.

It is invoked by sourcing the file (which must be found in `PATH`) having set
values for `ORACLE_SID` and, to avoid prompting, `ORAENV_ASK`:

<pre class=console><code>$ <b>ORACLE_SID=foo ORAENV_ASK=N . oraenv</b>
</code></pre>

### oratab

This file is located as `/etc/oratab` or `var/opt/oracle/oratab` and is used
by the `oraenv` script to determine the `ORACLE_HOME` for a respective
`ORACLE_SID`.

It consists of repeated entries of the form:

*ORACLE_SID*:*ORACLE_HOME*:*start_flag*

For example:

```console
FOO:/opt/oracle/product/19c/dbhome:N
BAR:/opt/oracle/product/21c/dbhome:Y
```

#### dbstart
The *dbstart* program uses the oratab in the folowing way:

This script will start all databases listed in the oratab file
whose third field is a `"Y"`.  If the third field is set to `"Y"` and
there is no `ORACLE_SID` for an entry (the first field is a `*`),
then this script will ignore that entry.

This script requires that ASM `ORACLE_SID`s start with a `+`, and
that non-ASM instance `ORACLE_SID`s do not start with a `+`.

If ASM instances are to be started with this script, it cannot
be used inside an `rc*.d` directory, and should be invoked from
`rc.local` only. Otherwise, the CSS service may not be available
yet, and this script will block init from completing the boot
cycle.

If you want dbstart to auto-start a single-instance database that uses
an ASM server that is auto-started by CRS (this is the default behavior
for an ASM cluster), you must change the database's ORATAB entry to use
a third field of `"W"` and the ASM's ORATAB entry to use a third field of `"N"`.
These values specify that dbstart auto-starts the database only after
the ASM instance is up and running.


#### dbshut 
This script is used to shutdown ORACLE from `/etc/rc(.local)` or *systemd*.
It should ONLY be executed as part of the system boot procedure.

This script will shutdown all databases listed in the oratab file
whose third field is a `"Y"` or `"W"`.  If the third field is set to `"Y"` and
there is no `ORACLE_SID` for an entry (the first field is a `*`),
then this script will ignore that entry.

This script requires that ASM `ORACLE_SID`s start with a `+`, and 
that non-ASM instance `ORACLE_SID`s do not start with a `+`.

## Developing
To develop the package clone or download the repository GNU Autotools are required.

#### GNU Autotools
The [GNU Autotools](https://en.wikipedia.org/wiki/GNU_Autotools) are required
to build and deploy the source packages. 

From Linux these can be installed with yum/dnf:

* autoconf
* automake
* libtool
* rpm-build

## Building RPMS from the Source Tree
Set `%_topdir` in the file `$HOME/.rpmmacros`. For example:

* `%_topdir %{getenv:HOME}/.rpm`

Next run the build script:

* `./build.sh`

The RPM file will be created in the following location, for example:

* `%_topdir/RPMS/noarch/@PACKAGE@-1.1-1.el9.noarch.rpm`

Where 1.1 is the version and 1 is the release. @PACKAGE@ is a documentation
placeholder for the actual name of the package.

Which you can then copy or move as you see fit and install with <b>rpm</b>(8), <b>dnf</b>(8) or <b>yum</b>(8). For example:

<pre class=console><code># <b>dnf -y install @PACKAGE@-1.1-1.el9.noarch.rpm</b>
</code></pre>

To remove the currently installed package version:

<pre class=console><code># <b>dnf -y remove @PACKAGE@</b>
</code></pre>

## Releases and Versions

In the `.spec` file can be found the _version_ and _release_:

```console
Version:    1.1
Release:    1
```

A _version_ of software may change should new programs be added, functionality enhanced, APIs changed or any such enhancement or modification of its behaviour occur.

A _release_ would change (incremented) when there is a change in the way the product is
packaged or delivered (for example, post installation scripts) or its
dependencies change. The release would be reset to 1 when a new _version_ of
the software is built. It is, in effect, the number of times this version of the software was released. 


### Version (and Release) Changes

When you wish to freeze a version of the software and commit the changes, we 
need to change the version number in both the `.spec` and `configure.ac`
files. We make sure that all changes are committed as required and push to the
central repository. Finally we tag the committed code with the version and release and
push the tags to the central repository.

These steps are explained in detail below.

Note that the requirement to change the version number in
both the `.spec` and `configure.ac` files can be reduced to only needing to
change the latter by employing a macro in the former.

#### Change the .spec File 

Change the Version to that which is desired, for example, to create version
1.2:

<pre class=console><code>Version:    <b>1.2</b>
Release:    1
</code></pre>

##### Using a macro
To avoid the need to change two files to update the version number, we can
use RPM's macro feature to extract the version from only the `configure.ac`
file. Our `.spec` file then becomes:

<pre class=console><code>Version:    <b>%(sed -n '/AC_INIT/ s;.*\[\(.*\)\],.*;\1;p' configure.ac)</b>
Release:    1
</code></pre>

And we need only change the version in the file `configure.ac`.

#### Change the configure.ac file

The corresponding version must also be changed in the arguments to the
`AC_INIT()` macro in the `configure.ac` file:

<pre class=console><code>AC_INIT([@PACKAGE@],[<b>1.2</b>],[bugs@developer.com])
</code></pre>

##### Ensure that all changes are committed

Check commits:
<pre class=console><code>$ <b>git status -u</b>
</code></pre>

If necessary, commit:
<pre class=console><code>$ <b>git commit -a -m "Version 1.2 Release 1"</b> 
</code></pre>

<pre class=console><code>$ <b>git push -u origin main</b> 
</code></pre>

#### Tag the commit with the Version and Rlease

Tag the commit:
<pre class=console><code>$ <b>git tag 1.2-1</b> 
</code></pre>

And push it to the central repository:
<pre class=console><code>$ <b>git push --tags</b> 
</code></pre>

Note that tags can be listed with:
<pre class=console><code>$ <b>git tag</b> 
1.1-1
1.1-2
</code></pre>

And a view of the logs of the repository will show our tagged version/release.
In the example below, note that the release 2 of version 1.1 has just been
committed/tagged and is the same as the current HEAD.
<pre class=console><code>$ <b>git log --oneline</b> 
git log --oneline
20645b2 (HEAD -> main, tag: 1.1-2) Version 1.1 Release 2
4f7a5ad (origin/main) README
059509e (tag: 1.1-1) Version 1.1 Release 1
e524994 README updates
3979962 README updates
70a2ec2 Moved libraries to pkgpyexec
5914994 Re-arranged
a6c822d Added verify_only
9924dbf Jo's file added to list of modules
cf323fe Made emrun relocatable
97296b2 First collection of files
a254d09 First commit
</code></pre>


### Build Steps

You don't need to run these if you use the build script, however, these are
shown for completeness.  The build script completes the following steps.

Create the build directories:

<pre><code>for dir in BUILD BUILDROOT RPMS SOURCES SPECS SRPMS
do
    mkdir -p $topdir/$dir
done
</code></pre>

Bootstrap the **autoconf** tools:

* `autoreconf --install`

Then run configure:

* `./configure`

This will create the necsessary <code>Makefile</code> that is required to build the source tarball.
Then we can create the tarball:

* `make dist-gzip`

We can then move the package into the `SOURCES` directory:

* `mv @PACKAGE@-`*vers*`.tar.gz $topdir/SOURCES`

And we also need a copy the spec file to the `SPECS` directory:

* `cp -f @PACKAGE@.spec $topdir/SPECS`

Finally, build the package:

* `rpmbuild -bb $topdir/SPECS/@PACKAGE@.spec`

The RPM file will be created at:

<pre>%\_topdir/RPMS/noarch/@PACKAGE@-<i>m</i>.<i>n</i>-<i>r</i>.el9.noarch.rpm</pre>


## Installing from a Tar Bundle

Download the latest release.

Unzip the package:

<pre>
tar xzf @PACKAGE@-<i>m</i>.<i>n</i>.tar.gz
</pre>

Run `configure`:

```
./configure 
```

If desired to specify an installation destination other than `/usr/local` do so
with the usual configure mechanism:

```
./configure --prefix=/opt/OEMtools 
```

Build the software:
* `make`

and then install it:
* `make install`

### Configuring

Ensure that the *bindir* path derived from the install *prefix* in the `configure`
step is available in the `PATH` environment variable. Using the previous example where the default of `/usr/local/bin` is not chosen:

<pre>
PATH=$PATH:/opt/OEMtools/bin
</pre>

## Authors

* **Simon Anthony** - *Initial work* - * [Simon Anthony](https://github.com/simon-anthony)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

