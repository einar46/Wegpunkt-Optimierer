#!/bin/bash
# Wegpunkt-Optimierer starten (macOS)
# ----------------------------------
# Diese Datei liegt im Hauptordner des Projekts (neben index.html).
# Doppelklick genügt: startet automatisch einen lokalen Webserver in diesem
# Ordner (nötig für den Modus "Echtes Wegenetz", der Internetzugriff braucht)
# und öffnet den Wegpunkt-Optimierer im Standardbrowser.
#
# Einmalig nach dem Herunterladen im Terminal:  chmod +x starten-mac.command
# Beim allerersten Start ggf. per Rechtsklick → „Öffnen“ bestätigen.
#
# Zum Beenden: dieses Terminal-Fenster einfach schließen (oder Strg+C).

cd "$(dirname "$0")" || exit 1

# Freien Port ab 8000 aufwärts suchen (falls z. B. noch ein alter Server läuft)
PORT=8000
while lsof -i :"$PORT" -sTCP:LISTEN -t >/dev/null 2>&1; do
  PORT=$((PORT + 1))
done

echo "Ordner: $(pwd)"
echo "Starte lokalen Server auf Port $PORT ..."
echo ""

python3 -m http.server "$PORT" &
SERVER_PID=$!
trap 'echo ""; echo "Server wird beendet ..."; kill $SERVER_PID 2>/dev/null' EXIT

sleep 1
open "http://localhost:$PORT/"

echo "Server läuft: http://localhost:$PORT/"
echo "Falls sich der Browser nicht automatisch öffnet, den Link von Hand aufrufen."
echo "Dieses Fenster offen lassen, solange du den Optimierer benutzt."
echo ""

wait "$SERVER_PID"
