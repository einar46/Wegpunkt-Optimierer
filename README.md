# Wegpunkt-Optimierer

Findet die kürzeste Reihenfolge, um viele Wegpunkte in **einer durchgehenden Tour** abzulaufen, z. B. alle Stempelstellen eines Wanderabzeichens, Gipfel, Hütten oder Geocaches. Gerechnet wird auf dem echten Wegenetz aus OpenStreetMap. Das Ergebnis geht als GPX direkt nach Garmin Basecamp oder auf das Navigationsgerät.

Der Optimierer ist **eine einzelne HTML-Datei**. Er läuft komplett im Browser, ohne Installation und ohne Konto. Deine GPX-Dateien werden nirgends hochgeladen. Nur im Modus „Echtes Wegenetz“ holt der Browser Kartendaten von den öffentlichen Overpass-Servern.

**Anleitung:** [Bedienung](docs/optimierer-bedienung.md) · [Technische Dokumentation](docs/optimierer-technik.md)

## Was er kann

- **Optimierung:** Problem des Handlungsreisenden (TSP) mit Multi-Start Nearest-Neighbor, 2-opt, Or-opt und Iterated Local Search mit Double-Bridge-Störung. Als offener Weg (Start und Ziel frei) oder als Rundtour.
- **Zwei Distanzmodelle:** Luftlinie zur schnellen Orientierung oder echtes Wegenetz. Beim Wegenetz kommen die OSM-Wege über die Overpass API, die kürzesten Wege per Dijkstra. Jeder Wegpunkt wird rechtwinklig an den nächsten Weg angebunden.
- **Einstellbar:** Straßentypen ausschließen oder bestrafen (z. B. Bundesstraßen), Belag, SAC-Skala, Wegsichtbarkeit, Wegzustand, Bonus für ausgeschilderte Wanderrouten.
- **Große Gebiete:** kompaktes Wegenetz im Speicher, Kachel-Zwischenspeicher im Browser (IndexedDB), abgebrochene Downloads lassen sich fortsetzen. Erprobt mit 430 Punkten auf ca. 25.000 km².
- **Ausgaben:**
  - Track für die Navigation
  - Route für Basecamp, auch eine eigene „Route für Neuberechnung“ mit wenigen, eindeutig einrastenden Punkten
  - Aufteilung in Teilstrecken
  - Entfernungsliste (CSV) und Distanzmatrix (JSON)
- **Ehrliche Kilometer:** Die Strecke wird aufgeschlüsselt in einmal gelaufenes Wegenetz plus Hin- und Rückweg auf Stichwegen.

## Start

**Variante 1 – online (am einfachsten):** <https://einar46.github.io/Wegpunkt-Optimierer/> öffnen. Der Optimierer läuft dann direkt im Browser, auch im Modus „Echtes Wegenetz“.

**Variante 2 – lokal:** Repository herunterladen (grüner Knopf „Code“ → „Download ZIP“) und entpacken. Dann:

- **macOS:** Doppelklick auf `starten-mac.command`. Einmalig vorher im Terminal `chmod +x starten-mac.command` ausführen. Beim ersten Start eventuell per Rechtsklick → „Öffnen“ bestätigen.
- **Windows:** Doppelklick auf `starten-windows.bat`. Dafür muss [Python](https://www.python.org/downloads/) installiert sein (beim Installieren „Add python.exe to PATH“ ankreuzen).
- **Von Hand:** Im Projektordner `python3 -m http.server` ausführen und `http://localhost:8000/` öffnen.

> **Warum ein lokaler Server?** Wird die HTML-Datei per Doppelklick als `file://` geöffnet, blockieren manche Browser die Anfragen an die Overpass-Server. Für den Modus „Luftlinie“ reicht der Doppelklick auf `wegpunkt-optimierer.html`.

## Eingabe

Eine **GPX-Datei mit Wegpunkten** (`<wpt>`), mindestens 4. Die Namen werden unverändert übernommen, ein bestimmtes Kürzel ist nicht nötig. Tracks und Routen in der Datei werden ignoriert.

Zum Ausprobieren liegen im Ordner [`beispiele`](beispiele/) 25 frei erfundene Wegpunkte.

## Hinweise

- **Overpass Fair Use:** Die öffentlichen Overpass-Server erlauben grob 1 GB pro Tag. Ein großes Gebiet kann beim ersten Mal 0,5–1 GB laden. Fehlende Kacheln werden beim nächsten Lauf nachgeladen, bereits geladene kommen aus dem Zwischenspeicher.
- **Keine Höhenmeter:** Die Optimierung kennt kein Höhenmodell. Zugangsbeschränkungen (`access=*`) werden nicht ausgewertet.
- **Der Track ist die Referenz.** Basecamp rechnet mit seiner eigenen Karte und kann leicht abweichen.
- **Wegpunkt-Daten:** Dieses Repository enthält keine Stempelstellen-Listen. Die Daten gehören den jeweiligen Herausgebern. Hole sie dir als GPX dort, wo sie angeboten werden.

## Entwicklung und Tests

Der Optimierer hat keine Abhängigkeiten. Für den automatischen Test wird [Node.js](https://nodejs.org/) gebraucht:

```
npm install
npm test
```

Der Test lädt die Seite, liest die Beispieldaten ein und rechnet eine Luftlinien-Tour.

## Hintergrund

Entstanden bei der Planung einer durchgehenden Wanderung über alle 222 Stempelstellen der Harzer Wandernadel, später erweitert für größere Gebiete. Der Optimierer ist aber nicht an ein bestimmtes Gebiet oder Abzeichen gebunden.

## Lizenz

[MIT](LICENSE). Kartendaten © [OpenStreetMap-Mitwirkende](https://www.openstreetmap.org/copyright), verfügbar unter der Open Database License (ODbL). Wer aus den Ergebnissen Karten oder Tracks veröffentlicht, sollte OpenStreetMap als Quelle nennen.

---

## English summary

A browser-only tool (a single HTML file, no installation) that finds the shortest order for one continuous hike through many waypoints on the real OpenStreetMap path network. It uses nearest neighbor, 2-opt, Or-opt and iterated local search, fetches paths via the Overpass API, and exports GPX tracks and routes for Garmin Basecamp.

Open <https://einar46.github.io/Wegpunkt-Optimierer/>, or run `starten-mac.command`, `starten-windows.bat` or `python3 -m http.server` and open `http://localhost:8000/`. The user interface and documentation are in German. License: MIT.
