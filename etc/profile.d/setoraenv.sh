# vim:syntax=sh:sw=4:ts=4:
################################################################################
# setoraenv: interactive invocation of oraenv
#
################################################################################
# Copyright (C) 2026
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License or, (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not see <http://www.gnu.org/licenses/>>
#

readoraenv() {
	typeset -r prog="readoraenv"
	local var= val=

	[ -r "$1" ] || return
	while IFS="=" read -r var val
	do
		set -a
		eval $var=$val
		set +x
	done < <(sed -n '/^[A-Z_]\{1,\}=/ {
		s;\([^=]*\)="\([^"]*\)";\1="";
		s%\([^=]*\)=\([^;]*\)[\;&|].*%\1=\2%
		p; }' $1)
}

writeoraenv() {
	typeset -r prog="writeoraenv"
	local eflg= fflg= opt= errflg= OPTIND=1
	local var= val=

	while getopts "ef" opt 2>&-
	do
		case $opt in
		e)	eflg=y ;;
		f)	fflg=y ;;
		\?)	errflg=y
		esac
	done
	shift $(( OPTIND - 1 )) 

	[ $# -eq 1 ] || errflg=y
	[ $errflg ] && { echo "usage: $prog [-e] <file>" >&2; return 2; }

	local envfile=$HOME/`basename $1` 

	[ -r "$1" ] || return 1
	> $envfile || return

	echo writing $envfile ...
	while IFS="=" read -r var val
	do
		if [ $eflg ]
		then
			eval echo $var=\$$var ${fflg:+export $var} | tee -a $envfile
		else
			eval echo $var=$val ${fflg:+export $var} | tee -a $envfile
		fi
	done < <(sed -n '/^[A-Z_]\{1,\}=/ {
		s;\([^=]*\)="\([^"]*\)";\1="";
		s%\([^=]*\)=\([^;]*\)[\;&|].*%\1=\2%
		p; }' $1)
}

setoraenv() {
	typeset -r prog="setoraenv"
	local iflg= uflg= sflg= lflg= eflg= oflg= wflg= opt= errflg= OPTIND=1
	local oracle_sid=
	local envdir="${ENVDIR:-/etc/opt/oracle/env}"
	local envfile=
	local suffix="env"
	
	while getopts "ius:leow" opt 2>&-
	do
		case $opt in
		i)	iflg=y
			[ $sflg ] && errflg=y
			;;
		u)	uflg=y
			;;
		s)	sflg=y	
			oracle_sid="$OPTARG"
			[ $iflg ] && errflg=y
			;;
		l)	lflg=y	# consider oracle_sid local
			;;
		e)	eflg=y	# source an envfile
			envfile=y
			;;
		o)	oflg=y	# oraenv settings will take preference over envfile
			;;
		w)	wflg=y	# write resulting envfile 
			;;
		\?)	errflg=y
		esac
	done
	shift $(( OPTIND - 1 )) 

	[ $# -eq 0 ] || errflg=y
	[ -n "$uflg" -a -z "$iflg" ] && errflg=y
	[ -n "$eflg" -a -z "$sflg" ] && errflg=y # -e requires -s
	[ -n "$wflg" -a -z "$eflg" ] && errflg=y # -w requires -e 
	[ -n "$oflg" -a -z "$eflg" ] && errflg=y # -o requires -e 

	[ $errflg ] && { echo "usage: $prog [-l] [-i[-u]|-s <sid> [-e[-o][-w]]" >&2; return 2; }

	local oratab=`ls /etc/oratab /var/opt/oracle/oratab 2>&-`

    [ -x /usr/local/bin/oraenv ] || { echo "$prog: no oraenv in local bin" >&2; return 1; }
	[ -n "$oratab" -a -r "$oratab" ] || { echo "$prog: no oratab" >&2; return 1; }

	if [ $iflg ]
	then
		[ -x /usr/local/bin/ckitem ] || { echo "$prog: valtools package not installed" >&2; return 1; }
		local file=`mktemp`

		awk -F: '
			/^[ ]*#/ { next; }
			$1 ~ /[A-Za-z0-9]+/ { printf("%s\t%s\n", $1, $2); }' /etc/oratab > $file

		oracle_sid=`ckitem ${uflg:+-u} -o -p "Choose an instance" -f $file` || return
		echo oracle_sid is $oracle_sid
		rm -f $file
	elif [ $sflg ]
	then
		oracle_sid=`awk -F: '$1 == "'$oracle_sid'" { printf("%s", $1); quit; }' $oratab`
		if [ "$envfile" ]
		then
			envfile=`grep -l ORACLE_SID=''$oracle_sid'[\ ;$]' $envdir/*.$suffix`
			if [ "${envfile#*.$suffix}" ] # too many matches
			then
				echo "ORACLE_SID '$oracle_sid' found in too many files: $envfile" >&2
				return 1
			fi
		fi
	else # fail
		return 1
	fi

	if [ -n "$oracle_sid" ]
	then 
		[ -n "$eflg" -a -n "$oflg" ] && readoraenv $envfile
		export ORACLE_SID="$oracle_sid" ORAENV_ASK=NO
		. oraenv 
		[ -n "$eflg" -a -z "$oflg" ] && readoraenv $envfile
	else
		echo "$prog: specified SID not in $oratab"
		return 1
	fi
	[ $wflg ] && writeoraenv ${oflg:+-e} $envfile
	if [ ! "$lflg" ]
	then
		# ORACLE_SID is only for local instances with BEQ connection
		[ -f $ORACLE_HOME/dbs/hc_$ORACLE_SID.dat ] || unset ORACLE_SID # is instance local?
	fi
	[ $oracle_sid ] || return 1
}

typeset -fx setoraenv readoraenv writeoraenv
