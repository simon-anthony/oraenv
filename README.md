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


