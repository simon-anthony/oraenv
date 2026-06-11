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

This file is located as `/etc/oratab` or `var/opt/oracle/oratab`.

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
there is no `ORACLE_SID` for an entry (the first field is a `\*`),
then this script will ignore that entry.

This script requires that ASM `ORACLE_SID`s start with a `+`, and
that non-ASM instance `ORACLE_SID`s do not start with a `+`.

If ASM instances are to be started with this script, it cannot
be used inside an `rc\*.d` directory, and should be invoked from
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
there is no ORACLE_SID for an entry (the first field is a `\*`),
then this script will ignore that entry.

This script requires that ASM `ORACLE_SID`s start with a `+`, and 
that non-ASM instance `ORACLE_SID`s do not start with a `+`.
