#!/bin/bash

version="0.1.2" # wird mit --version auf der console ausgegeben
GUI=yad
filter=0

. gettext.sh

TEXTDOMAIN=myservers
export TEXTDOMAIN
TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAINDIR

progtitle=$(eval_gettext "running MySQL/MariaDB instances")

#Versionsinfo auf der Console ausgeben, dann beenden
if [[ $1 = "--version" || $1 = "-v" ]]; then
    eval_gettext "$(basename $0) version $version"; echo
    echo "Copyright 2019, 2022 Michael John
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law."
    exit
fi

if [[ $1 = "--help" || $1 = "-h" ]]; then # || $1 = "" 
    echo "Aufruf: $(basename $0) [OPTIONEN]
      --file DATEI           diese Benutzerkonfigurationsdatei verwenden
      --gui                  zeigt die Übersicht als yad-Dialog an
      -h, --help             zeigt eine Kurzfassung des Aufrufs
      -v, --version          zeige Programmversion an"
    exit
fi

#Überprüfen ob der User root ist
#if (( $EUID != 0 )); then
#    echo "Please run as root"
#    $($GUI --error --width=200 --title "myservers - Fehler" --text "Please run as root" 2> >(grep -v 'GtkDialog' >&2))
#    exit
#fi

#Überprüfen ob yad installiert ist
#Später durch detect_gui() ersetzen
if ! [ -x "$(command -v $GUI)" ]; then
    eval_gettext 'Error: $GUI is not installed.'; echo
    exit 1
fi

eval_gettext "$(basename $0) version $version"
echo

if [[ $1 = "--file" ]]; then
	if [[ $2 = "" ]]; then
		eval_gettext "No file given, exiting."; echo
		exit
	else
		file=$2
	fi
else
	#file="$HOME/myservers.conf"
	file="./myservers.conf"
fi

while IFS=: read -r f1 f2 f3 f4 f5 f6 f7
do
        # display fields using f1, f2,..,f7
		printf -v USERPASS 'Username: %s, Password: ***, Host: %s, DB: %s\n' "$f1" "$f3" "$f4"
		if [[ $1 != "--gui" ]]; then
			#OUTPUT+=$USERPASS
		#else
			echo $USERPASS
		fi
	echo
	if grep -q "#" <<<"$f1"; then
		eval_gettext "...skipped."
		echo
		break
	else
		OUTPUT+="Host: $f3 DB: $f4"
		OUTPUT+=$'\t \n'
		#UPTIME="$(mysql -u $f1 -p$f2 -h $f3 -D $f4 -B -N -e "show status where variable_name='uptime';" | sed 's/\t/: /g')"
		UPTIME="$(mysql -u $f1 -p$f2 -h $f3 -D $f4 -B -N -e "SELECT CONCAT(
            FLOOR(TIME_FORMAT(SEC_TO_TIME(variable_value), '%H') / 24), 'd ',
            MOD(TIME_FORMAT(SEC_TO_TIME(variable_value), '%H'), 24), 'h ',
            TIME_FORMAT(SEC_TO_TIME(variable_value), '%im %ss')
        ) from information_schema.GLOBAL_STATUS 
where VARIABLE_NAME='Uptime';")"
		OUTPUT+="Uptime: $UPTIME"
		OUTPUT+=$'\n \n'
		RESULT="$(mysql -u $f1 -p$f2 -h $f3 -D $f4 -B -N -e "select variable_name, IF(variable_value IS NULL or variable_value = '', '(empty)', variable_value) variable_value from information_schema.global_variables where variable_name like 'version%' order by variable_name;")"
		if [[ $1 != "--gui" ]]; then echo "$RESULT"; fi
			OUTPUT+="$RESULT"
			#OUTPUT+=$'\n'
		fi
		OUTPUT+=$'\n \n \n'
	#echo "================================================================"
	echo
done <"$file"

#exit
IFS=$'\t\n'
zen_dat_opts=( --width="800" --height="500"
    #--title="$(basename $0) - Laufende MySQL/MariaDB Instanzen - Filter auf ${filters[$filter]}"
    --title="$(basename $0) - $progtitle"
    --text="" --center --window-icon="myservers.png"
    --list --column="Name" --column="Wert"  
    --print-column="1" --separator="\t" --grid-lines=hor
    #--button=" Mount!add":1 --button=" Unmount!remove":2 --button=" Filter!gtk-preferences":4 
    --button=" Schließen!gtk-cancel":3 )

#dat=$(df ${filters[$filter]} |grep -v 'auf' | sort )

if [[ $1 = "--gui" ]] || [[ $3 = "--gui" ]]; then
	volume=$( $GUI "${zen_dat_opts[@]}" ${OUTPUT} 2> >(grep -v 'GtkDialog' >&2) )
	#echo "Volume: $volume, Returncode: $?"
fi
