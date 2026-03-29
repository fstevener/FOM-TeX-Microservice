#!/usr/bin/bash

FILE="/usr/fomtextemplate/deine_inhalte/Kapitel.tex"
WORKDIR="/usr/fomtextemplate"

echo "Watching $FILE ..."

LTIME=$(stat -c %Y "$FILE")

while true
do
    ATIME=$(stat -c %Y "$FILE")

    if [[ "$ATIME" != "$LTIME" ]]
    then
        echo "Änderung erkannt..."

        # 🟡 WICHTIG: warten, bis Windows fertig gespeichert hat
        sleep 1

        # 🔁 nochmal prüfen (verhindert halbfertige Dateien)
        ATIME2=$(stat -c %Y "$FILE")
        if [[ "$ATIME2" != "$ATIME" ]]; then
            echo "Datei wird noch geschrieben – überspringe..."
            continue
        fi

        echo "Starte saubere Kompilierung..."

        cd $WORKDIR

        # 🔴 CLEAN BUILD (extrem wichtig!)
        rm -f *.aux *.bbl *.blg *.toc *.lof *.lot *.out *.log

        # optional: Word Count
        texcount "$FILE" > word_count.log

        # 🔥 force compile
        arara -v *.tex

        if [ $? -eq 0 ]; then
            echo "✅ Kompilierung erfolgreich"
        else
            echo "❌ Fehler bei Kompilierung"
        fi

        echo "Word Count:"
        texcount "$FILE" -quiet -brief

        LTIME=$ATIME2
    fi

    sleep 1
done

# #!/usr/bin/bash

# # https://superuser.com/questions/181517/how-to-execute-a-command-whenever-a-file-changes
# # Thanks to VDR and Pablo A

# ### Set initial time of file

# LTIME=`stat -c %Z /usr/fomtextemplate/deine_inhalte/Kapitel.tex`

# while true    
# do
# 	ATIME=`stat -c %Z /usr/fomtextemplate/deine_inhalte/Kapitel.tex`

# 	if [[ "$ATIME" != "$LTIME" ]]
# 	then
# 		texcount /usr/fomtextemplate/deine_inhalte/Kapitel.tex > word_count.log
# 		arara *.tex
# 		LTIME=$ATIME
# 		echo "Word Count: "
# 		texcount /usr/fomtextemplate/deine_inhalte/Kapitel.tex -quiet -brief
# 	fi
# 	# sleep 2
# done
