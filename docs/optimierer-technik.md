# Wegpunkt-Optimierer — Technische Dokumentation

Datei: [`wegpunkt-optimierer.html`](../wegpunkt-optimierer.html) · Bedienung: [optimierer-bedienung.md](optimierer-bedienung.md)

"Version 1" bezeichnet im Folgenden die erste Fassung des Optimierers (objektbasiertes Wegenetz), "Version 2" die aktuelle Fassung in diesem Repository. Version 1 ist nicht mehr enthalten; die Vergleiche dokumentieren, dass Version 2 dieselben Distanzen liefert.

## 1. Zweck der Version 2

Version 1 hält das OSM-Wegenetz mehrfach und objektbasiert im Speicher (Rohdaten, Knoten-Map mit Text-Schlüsseln, Nachbarschaftslisten, Kantenliste, Polylinien). Für ein Mittelgebirge (z. B. 222 Punkte, ca. 3.000 km²) reicht das, für Gebiete in der Größe eines Bundeslandes (z. B. 430 Punkte, Rechteck ca. 144 × 173 km) nicht mehr: mehrere GB Speicher und stundenlange Distanzberechnung.

Version 2 rechnet **dieselben Distanzen** (siehe Abschnitt 6), aber mit kompakten Datenstrukturen, lokalem Kachel-Zwischenspeicher und schnellerem Dijkstra. Bedienung, Straf-/Bonus-Faktoren, TSP-Heuristik und alle Exporte sind unverändert.

## 2. Wegenetz-Download (neu)

- **Festes Kachelraster** 0,1° × 0,15° (ca. 11 × 10 km), unabhängig von der Wegpunkt-Datei → Kacheln sind über Läufe und Dateien hinweg wiederverwendbar.
- **Kachelauswahl:** nur Kacheln, deren Rechteck höchstens *Puffer* km (Standard 8 km) von mindestens einem Wegpunkt entfernt ist. Beispiel 430 Punkte über ca. 144 × 173 km: 178 Kacheln.
  - Version 1 nutzte das Rechteck um alle Punkte + 2 km. Durch den größeren Puffer stehen am Rand mehr Wege zur Verfügung — Ergebnisse können dadurch minimal kürzer werden, nie länger.
- **Alle Wegtypen werden geladen** (highway=*, Fähren, Seilbahnen außer Materialseilbahnen, IDs der Wege in Wanderrouten-Relationen). Ausschlüsse und Straf-Faktoren werden erst lokal angewendet → eine geladene Kachel gilt für alle Einstellungen.
- **Zwischenspeicher (IndexedDB im Browser):** jede Kachel wird sofort in ein kompaktes Format umgewandelt (Koordinaten als ganze Zahlen in 1e-7 Grad = OSM-Genauigkeit, Tags auf die benötigten Merkmale reduziert) und gespeichert. Weitere Läufe, geänderte Einstellungen oder ein neu geöffneter Browser laden nichts erneut.
  - Anzeige des Umfangs (Kachelanzahl, MB, Datenstand) und Button **"Zwischenspeicher leeren (frische OSM-Daten)"**.
  - Checkbox zum Abschalten. Ist IndexedDB nicht verfügbar, läuft alles wie in Version 1 ohne Speicherung.
- **Robustheit:** bis zu 3 Runden über 3 Overpass-Server mit Wartezeiten (8 s, 25 s). Antworten mit Server-Abbruchvermerk ("remark", z. B. Timeout) gelten als unvollständig und werden verworfen, nicht gespeichert.
- **Fortsetzen:** Fehlen Kacheln (Server überlastet, Tageskontingent ca. 1 GB erreicht), bricht der Wegenetz-Aufbau mit Hinweis ab; die geladenen Kacheln bleiben gespeichert. Erneuter Klick auf "Optimieren" lädt nur die fehlenden.
- **Gleichzeitige Anfragen:** einstellbar 1–4, Standard 2.
- Fortschrittsanzeige mit geladenen MB und Restzeit.

## 3. Kompakter Graph

- **Knoten nur an Kreuzungen und Wegenden.** Zwischenpunkte eines Wegstücks werden zu einer Kante ("Kette") mit Länge und Suchkosten zusammengefasst; die Geometrie bleibt in Zahlen-Arrays für Anbindung und Exporte erhalten.
- **Knoten-Identität wie Version 1:** Koordinate auf 6 Nachkommastellen gerundet (verbindet auch doppelt erfasste OSM-Knoten an gleicher Stelle).
- Kachel-Rohdaten werden nach dem Graphaufbau freigegeben.
- **Exakte Ausdünnung:** Sackgassen-Äste ohne Wegpunkt und Netzteile ohne Wegpunkt werden entfernt — sie können nie auf einem kürzesten Weg zwischen zwei Wegpunkten liegen. Ergebnis unverändert, Rechnung schneller.

## 4. Anbindung der Wegpunkte (präzisiert)

Wie bisher per Lot auf das nächstgelegene Wegsegment; Anschlussweg = Luftlinie, nie gestraft. Die betroffene Kette wird **am Lotpunkt aufgetrennt**. Das behebt drei Ungenauigkeiten von Version 1:

1. **Lot auf einen Stützpunkt** (Segmentende, häufig): Version 1 ließ dann eine Anschlusskante weg und rechnete einen Umweg über das Nachbarsegment (einige Meter zu viel).
2. **Sehr lange Segmente** (z. B. Fähren): Version 1 sortierte Segmente nur in die Rasterzellen ihrer Endpunkte ein und konnte ein näheres langes Segment übersehen. Version 2 sortiert in alle überdeckten Zellen ein; liegt ein Punkt > 3 km vom Netz entfernt, wird das gesamte Netz durchsucht.
3. **Mehrere Wegpunkte auf demselben Segment** werden direkt entlang des Weges verbunden.

## 5. Distanzmatrix

- Dijkstra auf Zahlen-Arrays (CSR-Adjazenz, indizierter Binärheap, Zurücksetzen per Zeitstempel statt Neuanlage).
- **Symmetrie:** Wegdistanz A→B = B→A. Die Punkte werden entlang der Hauptachse ihrer Verteilung abgearbeitet; jeder Lauf sucht nur noch die später folgenden Punkte.
- Nicht verbundene Paare: wie bisher Luftlinie als Ersatz, mit Hinweis.

## 6. Prüfung

**Gleichheit mit Version 1** (synthetische Netze, simuliertes Overpass, beide Versionen im Browser-Simulator):
- Distanzmatrix identisch zu Version 1 mit korrigiertem Punkt 4.1: 0 abweichende Paare, max. Abweichung 0,000000 m — geprüft mit Standardeinstellungen, mit allen Straf-/Bonus-Faktoren und SAC-Grenze, sowie mit verschiedenen Wegtyp-Ausschlüssen.
- Gegenüber dem unkorrigierten Version 1 sind die Distanzen dort, wo 4.1 greift, kürzer (Penalty-Fälle: Wegwahl nach Suchkosten).
- Track-Polylinie und Entfernungsliste (CSV) identisch.
- **Rückweg-Analyse:** Gesamtsumme identisch; die Aufteilung "rein / Hinweg / Rückweg" ist in Version 2 exakt (unabhängig auf Track-Koordinaten nachgezählt). Version 1 hat Überlappungen an Lotpunkten teils nicht als doppelt erkannt und dadurch etwas zu viel "rein" ausgewiesen. Die Anzahl "genutzte Wegabschnitte" zählt jetzt Kreuzung-zu-Kreuzung-Stücke statt Einzelsegmente (kleinere Zahl, gleiche km).

**Zwischenspeicher/Fehlerfälle:** zweiter Lauf mit geänderten Einstellungen 0 Anfragen und identisches Ergebnis; zwei dauerhaft gestörte Kacheln → klarer Hinweis, Folgelauf lädt nur diese 2 nach, Ergebnis gleich Referenz; Server-Abbruchvermerke werden verworfen.

**Last (Bundesland-Größe, synthetisch):** 13,7 Mio. Stützpunkte, 1,6 Mio. Kreuzungen, 2,5 Mio. Wegstücke:
- Graphaufbau 5 s, Anbindung 1 s, Ausdünnung 0,6 s
- volle 430 × 430-Matrix ca. 6 min (Testrechner 2 Kerne, 2,8 GHz)
- Spitzen-Speicher ca. 0,6 GB
- Echte OSM-Daten können dichter sein → Zeit entsprechend länger.

**Ende-zu-Ende** mit 430 echten Wegpunkten und Kachel-Simulation über das ganze Gebiet: 178 Kacheln, Deduplizierung über Kachelgrenzen, Track (Teilstrecken), Route (Teilstrecken, Douglas-Peucker), CSV, Netz-Export, Matrix-JSON (symmetrisch) — konsistent. Kurztest in Chromium als file://-Seite ohne Konsolenfehler, IndexedDB verfügbar.

**Nicht geprüft:** echte Overpass-Antworten (aus der Testumgebung nicht erreichbar).

## 7. Weitere Änderungen

- **Korrektur Toleranz:** Version 1 und die erste Fassung von Version 2 machten aus Toleranz "0" stillschweigend 15 m. Jetzt gilt der eingegebene Wert, mindestens 1 m.

- Rechenzeit-Budget bis 900 s (vorher 180 s) — sinnvoll bei 430 Punkten.
- Netz-Export blockweise zusammengesetzt (auch bei Millionen Punkten ohne Riesen-String); Hinweis, wenn sehr groß.
- Statuszeile nennt zusätzlich Kacheln (davon aus Zwischenspeicher), geladene MB und Größe des Rechennetzes.

## 7a. Export "Route für Neuberechnung (GPX)"

**Problem mit der Douglas-Peucker-Route:** Sie besteht aus Hunderten Original-Stützpunkten des Tracks, auch dicht in Kurven und genau auf Kreuzungen. Basecamp setzt jeden Routenpunkt auf den nächsten Weg seiner Karte und routet dann von Punkt zu Punkt. Weicht die Karte (z. B. Freizeitkarte, anderer OSM-Stand) um wenige Meter ab, oder rastet ein Kreuzungspunkt auf dem falschen Abzweig ein, entstehen kurze Kehrtwenden. Diese summieren sich auf mehrere km je Teilstrecke.

**Neuer Export** (zusätzlicher Button, nutzt "Teilstrecken" und "Toleranz" der Route). Gedacht für Neuberechnung mit kürzester Strecke, Bundesstraßen und Autobahnen gemieden:

- **Wegpunkte** sind immer Routenpunkte (mit Namen, Symbol "Flag, Red").
- **Alle anderen Punkte** liegen in der **Mitte eines Wegstücks** zwischen zwei Kreuzungen.
  - Mindestens 25 m Abstand zu beiden Enden, höchstens ein Punkt je Wegstück.
  - So rastet jeder Punkt eindeutig ein, und die Reihenfolge kann sich nicht umkehren.
  - Anschlusswege zu Wegpunkte werden nie belegt.
- **So wenige Punkte wie möglich:** Von jedem Routenpunkt aus wird der nächste so weit nach vorn gelegt, wie die kürzeste Verbindung genau dem Track folgt.
  - Geprüft auf dem eigenen Wegenetz nach Basecamp-Regeln: reine Weglänge ohne Straf-Faktoren; Bundesstraßen, Autobahnen/Kraftfahrstraßen, Fähren und Seilbahnen gesperrt.
  - Alternativen, die weniger als 1 m länger sind, gelten als unsicher → zusätzlicher Punkt.
- **Abschnitte, die ein Wander-Profil nicht nachrechnen kann** (Bundesstraße, Autobahn/Kraftfahrstraße, Fähre, Seilbahn):
  - Anfang: benannter Punkt "<Art> Beginn (Gerade)" (Symbol "Flag, Blue").
  - Ende: benannter Punkt "<Art> Ende (Wandern)" (Symbol "Flag, Green").
  - Dazwischen dicht nach Douglas-Peucker (Toleranz-Feld), damit "Gerade" dem Straßenverlauf folgt.
  - Liegt ein Wegpunkt direkt an einem solchen Abschnitt (nur Anschlussweg dazwischen), gehört sie zum Gerade-Abschnitt; ihr Name trägt dann den Zusatz.
  - Zwischen zwei Gerade-Abschnitten heißt es "… weiter Gerade (…)".
- **Teilstrecken** werden nur an Wegpunkte, Wegstück-Mitten oder Markern getrennt, nie mitten in einem Gerade-Abschnitt. Sie schließen nahtlos aneinander an.
- **Statuszeile:** Anzahl Routenpunkte, mittlerer Abstand, Anzahl und Länge der Gerade-Abschnitte je Art.

**Prüfung (Basecamp-Simulation):** Die Routenpunkte werden auf eine Karte gesetzt, deren Koordinaten um bis zu ±0/3/8 m verschoben sind, und mit kürzester Strecke neu berechnet (gesperrt wie oben; Gerade-Abschnitte als Luftlinie). 5 synthetische Netze, je 60 Wegpunkte, Track ca. 140–155 km:

| Kartenversatz | Douglas-Peucker 5 m (≈ 750–850 Punkte) | Douglas-Peucker 15 m (≈ 460–500 Punkte) | Route für Neuberechnung (≈ 75–90 Punkte) |
|---|---|---|---|
| ±0 m | +0,7 … +5,8 km | +0,6 … +5,7 km | −0,02 … +0,00 km |
| ±3 m | +1,6 … +6,5 km | +1,4 … +6,3 km | +0,00 … +0,41 km |
| ±8 m | +4,5 … +8,9 km | +3,2 … +8,6 km | +0,07 … +0,92 km |

Ohne Kartenversatz bildet die Neuberechnung den Track exakt nach (Rest = abgeschnittene Kurven in Gerade-Abschnitten).

**Grenzen:**
- Fehlt in der Basecamp-Karte ein Weg, den OSM hat, oder sperrt das Profil einen Wegtyp, rechnet Basecamp trotzdem anders. Der Track bleibt die Referenz.
- Den Profilwechsel ("Gerade"/"Wandern") kann die GPX-Datei nicht vorgeben. Er muss an den Markern in Basecamp gesetzt werden.

## 8. Bekannte Grenzen

- Erster Download für ein Gebiet von ca. 25.000 km² grob 0,5–1 GB von Overpass; die öffentliche Fair-Use-Grenze liegt bei ca. 1 GB/Tag → ggf. auf zwei Tage verteilt (Fortsetzen ist eingebaut).
- Speicher-Kontingent des Browsers: bei Überschreitung wird ohne weitere Speicherung weitergerechnet.
- Wie Version 1: kein Höhenmodell, kein Zugriffsbeschränkungs-Filter; Wege, die sich ohne gemeinsamen OSM-Knoten kreuzen, sind nicht verbunden.
- Wegpunkt-Namen ohne festes Kürzel — "TS001 …", "HWN001 …" oder ganz ohne Nummer funktionieren gleichermaßen.
