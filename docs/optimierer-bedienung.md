# Wegpunkt-Optimierer — Bedienungsanleitung

Gilt für: [`wegpunkt-optimierer.html`](../wegpunkt-optimierer.html)
Technische Details und Testergebnisse: [optimierer-technik.md](optimierer-technik.md)

---

## 1. Was das Programm macht

Der Optimierer bestimmt für alle Wegpunkte einer GPX-Datei die kürzeste Reihenfolge, um sie nacheinander abzulaufen (Problem des Handlungsreisenden).

- **Distanzen:** wahlweise per Luftlinie oder über das echte Wegenetz aus OpenStreetMap.
- **Ergebnis:**
  - Reihenfolge und Gesamtlänge
  - Track für die Navigation
  - Routen für Basecamp
  - Entfernungsliste und Analysedateien

Das Programm ist eine einzelne HTML-Datei und läuft komplett im Browser (Firefox, Chrome, Safari), ohne Installation. Hochgeladen wird nichts. Nur im Modus „Echtes Wegenetz“ werden Kartendaten von den Overpass-Servern geladen und im Browser zwischengespeichert.

---

## 2. Ablauf in Kürze

1. GPX-Datei mit den Wegpunkten laden.
2. Tourform und Distanzmodell wählen, Rechenzeit einstellen.
3. Bei Bedarf die erweiterten Einstellungen anpassen.
4. **Optimieren** klicken und warten, bis die Statuszeile „Fertig …“ meldet.
5. Die gewünschten Dateien herunterladen (Abschnitt 6).

> **Wichtig:** Das Ergebnis lebt nur in der geöffneten Seite. Neu laden oder schließen löscht es. Lade also alle benötigten Dateien herunter, bevor du die Seite schließt.

---

## 3. Eingaben im Hauptbereich

### GPX-Datei (Wegpunkte)
- **Inhalt:** Alle `<wpt>`-Einträge der Datei werden verwendet, mindestens 4. Tracks und Routen in der Datei werden ignoriert.
- **Namen:** Werden unverändert übernommen. Ein bestimmtes Kürzel ist nicht nötig („HWN001 …“, „TS001 …“ oder „Gipfel“ funktionieren gleich).
- **Höhe:** `<ele>` wird übernommen, falls vorhanden.
- **Dateinamen:** Der Dateiname ohne Endung ist der Anfang aller Ausgabedateinamen.
- Eine neue Datei verwirft alle bisherigen Ergebnisse.

### Tourform
- **Offener Weg** (Standard): Start und Ziel wählt das Programm selbst so, dass die Gesamtstrecke minimal wird. Einen festen Start kann man nicht vorgeben.
- **Rundtour:** Die Tour endet wieder am Startpunkt.

### Distanzmodell
- **Luftlinie:** rein geometrische Entfernung, sehr schnell, nur zur Orientierung. Liefert keinen Track.
- **Echtes Wegenetz (OSM, online):** Entfernungen über echte Wege. Siehe Abschnitt 5.

### Rechenzeit (Sekunden), 2–900, Standard 25
- **Gilt nur für die Suche der Reihenfolge.** Laden des Wegenetzes und Berechnung der Distanzen kommen im Wegenetz-Modus noch hinzu.
- **Mehr Zeit bringt meist bessere Ergebnisse:**
  - bis ca. 200 Punkte: 60–120 s
  - ab 400 Punkten: 300–600 s
- **Ergebnisse streuen leicht:** Die Suche ist zufallsbasiert. Zwei Läufe können sich um wenige Zehntelkilometer unterscheiden.

### Start ohne Installation
Siehe [README](../README.md#start): online über GitHub Pages, per Startskript oder mit `python3 -m http.server`. Im Modus „Luftlinie“ reicht auch ein Doppelklick auf die HTML-Datei.

### Optimieren / Abbrechen
- **Optimieren** startet die Berechnung.
- **Abbrechen** stoppt beim nächsten Zwischenschritt.

### Laufzeit-Tipp: Distanzmatrix wird wiederverwendet
Im Wegenetz-Modus wird die Distanzmatrix nur einmal berechnet (bei großen Gebieten der größte Teil der Laufzeit). Ein weiterer Klick auf **Optimieren** startet nur die Suche neu, etwa mit mehr Rechenzeit oder anderer Tourform, solange
- dieselbe GPX-Datei geladen ist,
- keine Wegenetz-Einstellung geändert wurde (Abschnitt 4.2 und 4.3),
- nicht zwischendurch mit **Luftlinie** gerechnet wurde. Das verwirft die Wegenetz-Matrix.

---

## 4. Erweiterte Einstellungen

Wirken nur im Modus „Echtes Wegenetz“. **Jede Änderung in 4.1 bis 4.3 macht das berechnete Wegenetz ungültig.** Der nächste Klick auf „Optimieren“ berechnet die Distanzen neu (die Kartendaten kommen aus dem Zwischenspeicher). Track- und Routen-Exporte des alten Ergebnisses sind danach nicht mehr möglich.

### 4.1 Wegenetz-Download & Zwischenspeicher

| Eingabe | Standard | Wirkung |
|---|---|---|
| **Puffer um die Wegpunkte (km)** | 8 | Geladen werden Kacheln (ca. 11 × 10 km), die höchstens so weit von einem Wegpunkt entfernt sind. Wege außerhalb werden nicht berücksichtigt. Größer = sicherer, aber mehr Download und Rechenzeit. |
| **Gleichzeitige Anfragen an Overpass** | 2 | Parallele Downloads. Bei häufigen Fehlern auf 1 senken. |
| **Zwischenspeicher im Browser verwenden** | an | Geladene Kacheln bleiben im Browser gespeichert. Spätere Läufe, andere Einstellungen und überlappende Gebiete brauchen keinen erneuten Download. |
| **Zwischenspeicher leeren** | – | Löscht alle gespeicherten Kacheln; der nächste Lauf lädt aktuelle OSM-Daten. Daneben stehen Umfang und Datenstand. |

**Wenn Kacheln fehlen** (Overpass überlastet oder Tageskontingent von ca. 1 GB erreicht): Das Programm meldet das und rechnet ersatzweise mit Luftlinie. Später einfach erneut **Optimieren** klicken; dann werden nur die fehlenden Kacheln nachgeladen.

**Der Zwischenspeicher gehört zum jeweiligen Browser.** Firefox und Chrome haben getrennte Speicher.

### 4.2 Straßentypen

| Eingabe | Standard | Wirkung |
|---|---|---|
| **Autobahnen & Kraftfahrstraßen ausschließen** | an | Werden nie benutzt. |
| **Bundesstraßen: Straf-Faktor** | 4 | Ein Bundesstraßenstück zählt bei der Wegwahl 4-fach. Es wird also nur benutzt, wenn jede Alternative mehr als 4-mal so lang wäre wie dieses Stück, typisch in Ortsdurchfahrten. 1 = normal erlaubt, 20 = praktisch nie. |
| **Landstraßen / Kreisstraßen ausschließen** | aus | secondary/tertiary werden nie benutzt. |
| **Orts-/Wohnstraßen ausschließen** | aus | residential, living_street, unclassified werden nie benutzt. |
| **Wirtschafts-/Feldwege ausschließen** | aus | track werden nie benutzt. |
| **Fuß-/Radwege ausschließen** | aus | footway, path, steps, bridleway, cycleway, pedestrian werden nie benutzt. |
| **Fähren einschließen** | an | Fährverbindungen dürfen genutzt werden. |
| **Seilbahnen einschließen** | an | Seilbahnen und Lifte dürfen genutzt werden. Für eine reine Wandertour eher **ausschalten**. |

### 4.3 Wegeeigenschaften

Straf-Faktoren beeinflussen nur, **welcher** Weg gewählt wird. Ausgegebene Längen sind immer die echten Kilometer. Faktor 1 = Eigenschaft spielt keine Rolle.

| Eingabe | Standard | Wirkung |
|---|---|---|
| **Belag: Straf-Faktor befestigte Wege** | 1 | Asphalt, Beton, Pflaster usw. werden gemieden, z. B. 1,5 = nur nehmen, wenn die Alternative 1,5-mal so lang ist. |
| **SAC-Wanderskala: maximale Schwierigkeit** | keine | Schwierigere Wege werden komplett ausgeschlossen. Betrifft nur Wege mit sac_scale-Angabe. |
| **Wegsichtbarkeit: Straf-Faktor** | 1 | Für schlecht sichtbare Pfade (trail_visibility bad/horrible/no). |
| **Mindestbreite (m) + Straf-Faktor** | 0 / 1 | Wege schmaler als die Mindestbreite werden bestraft. 0 = aus. Nur Wege mit width-Angabe (selten). |
| **Wegzustand: Straf-Faktor** | 1 | Für schlechte Oberflächen (smoothness bad … impassable). |
| **Fernwanderwege: Bonus-Faktor** | 1 | Wege in ausgewiesenen Wanderrouten werden bevorzugt, z. B. 0,8 = gelten als 20 % kürzer. 1 = kein Bonus. |

---

## 5. Was im Wegenetz-Modus passiert (Statuszeile)

1. **Kacheln laden:** aus dem Zwischenspeicher, sonst von Overpass (mit Fortschritt, MB und Restzeit).
2. **Wegenetz aufbauen:** Wege, Kreuzungen, Wegstücke.
3. **Wegpunkte anbinden:** Jeder Wegpunkt wird rechtwinklig an das nächste Wegstück angebunden. Dieser **Anschlussweg** ist Luftlinie und wird auf dem Hin- und auf dem Rückweg gezählt.
4. **Distanzen berechnen:** Fortschritt, Restzeit und eine grobe Hochrechnung.
5. **Reihenfolge suchen:** für die eingestellte Rechenzeit.

Die **Abschlussmeldung** enthält:
- Länge, Start und Ziel
- Anschlusswege (Summe, Durchschnitt, längster)
- Kacheln (davon aus dem Zwischenspeicher, geladene MB)
- Punktepaare ohne Wegverbindung (dort wird ersatzweise die Luftlinie verwendet)
- Aufschlüsselung der Strecke: **echtes Wegenetz** (einmal gelaufen) + **Hinweg-Anteil** + **Rückweg-Anteil**. Hin- und Rückweg sind die Stichwege, die doppelt gelaufen werden. Die Summe entspricht der Tourlänge, abzüglich der Abschnitte ohne Wegverbindung.

**Weitere Anzeigen:**
- **Kennzahlen:** Länge (km), Wegpunkte, Perturbationen (Anzahl Suchschritte), Laufzeit.
- **Vergleich Luftlinie ↔ Wegenetz:** Erscheint, wenn für dieselbe Tourform beide Modelle gerechnet wurden. Zeigt, wie viele Positionen der Reihenfolge sich unterscheiden.
- **Skizze:** Reihenfolge als Linienzug. Gelb = Start, rot = Ziel.

---

## 6. Ausgaben

Alle Dateinamen beginnen mit dem Namen der geladenen GPX-Datei, gefolgt von `_Offene_Route` bzw. `_Rundtour`, außer bei Distanzmatrix und Wegenetz. Ein erneuter Download erzeugt dieselben Namen; der Browser hängt dann (1), (2) usw. an.

**Gemeinsame Einstellungen für die GPX-Ausgaben:**
- **Wegpunkt-Namen in GPX einschließen** (Standard an): Die Wegpunkte erhalten ihre Namen. Aus = Wegpunkte ohne Namen.
- **Teilstrecken** (1–20): Teilt die Tour in etwa gleich lange Stücke nach echter Distanz. Diese schließen nahtlos aneinander an und heißen „Teilstrecke 01/20“ usw. Track und Routen haben je ein eigenes Feld.
- **Toleranz (m)** (1–200, Standard 15): siehe die beiden Routen-Ausgaben.

Teilstrecken und Toleranz kannst du nach dem Optimieren beliebig ändern und erneut herunterladen, ohne neu zu rechnen.

### 6.1 Track (GPX) herunterladen — `…_Track.gpx`
**Nur im Wegenetz-Modus.**
- **Inhalt:**
  - alle Wegpunkte als `<wpt>`
  - der echte, unvereinfachte Wegverlauf als `<trk>` (einer je Teilstrecke), mit allen OSM-Stützpunkten
  - Anschlusswege als gerade Linien zu den Wegpunkten und zurück
  - Abschnitte ohne Wegverbindung als Gerade
- **Verwendung:** **Navigation im Gelände.** Der Track liegt exakt auf den OSM-Wegen; seine Länge entspricht der Tourlänge.

### 6.2 Route (GPX) herunterladen — `…_Route.gpx`
Inhalt je nach Modus:
- **Im Wegenetz-Modus:**
  - **Vereinfachung:** Der echte Wegverlauf wird mit Douglas-Peucker vereinfacht, je Teilstrecke eine `<rte>`.
  - **Toleranz:** Sie bestimmt, wie weit die Route höchstens vom Track abweichen darf. Kleiner = mehr Punkte, enger am Track.
  - **Routenpunkte:** Original-Stützpunkte des Tracks, Symbol „Dot“, plus alle Wegpunkte als `<wpt>`.
- **Im Luftlinien-Modus:** eine kompakte Route, die nur die Wegpunkte in optimierter Reihenfolge verbindet, mit Namen.

**Wofür geeignet:** zum **Anzeigen ohne Neuberechnung**. Die Länge als Polygonzug ist etwas kürzer als der Track, weil die Geraden Kurven abschneiden.

**Wofür nicht geeignet:** zum **Neuberechnen in Basecamp**. Die vielen dichten Punkte rasten auf einer abweichenden Karte teils falsch ein und erzeugen Kehrtwenden. Dafür gibt es 6.3.

### 6.3 Route für Neuberechnung (GPX) — `…_Route_Neuberechnung.gpx`
**Nur im Wegenetz-Modus.** Gedacht für **Basecamp mit Profil „Wandern“, kürzeste Strecke, Autobahnen und Bundesstraßen gemieden**.

- **Wegpunkte:** Alle Wegpunkte sind Routenpunkte, mit Namen und roter Flagge.
- **Weitere Routenpunkte:** Sie liegen in der **Mitte von Wegstücken**, mindestens 25 m von Kreuzungen entfernt, höchstens einer pro Wegstück. Sie werden nur gesetzt, wo die kürzeste Verbindung sonst vom Track abweichen würde. Ergebnis: wenige Punkte (Beispiel mit 430 Punkten: Ø ca. 3,6 km Abstand), eindeutiges Einrasten, keine Kehrtwenden.
- **Markierte Abschnitte** auf **Bundesstraße, Autobahn/Kraftfahrstraße, Fähre oder Seilbahn** kann ein Wander-Profil nicht nachrechnen. Dort steht:
  - am Anfang ein Punkt „… Beginn (Gerade)“ mit blauer Flagge: **in Basecamp hier auf Profil „Gerade“ umstellen**
  - dazwischen dichte Punkte (nach der Toleranz)
  - am Ende ein Punkt „… Ende (Wandern)“ mit grüner Flagge: **hier zurück auf „Wandern“**
  - Liegt ein Wegpunkt direkt an einem solchen Abschnitt, steht der Hinweis in ihrem Namen. „… weiter Gerade“ heißt: Profil bleibt auf „Gerade“.
- **Teilstrecken** werden nie mitten in einem Gerade-Abschnitt getrennt.
- **Statuszeile:** Anzahl Routenpunkte, mittlerer Abstand, Zahl und Länge der Gerade-Abschnitte.
- **Grenzen:** Wo die Basecamp-Karte (z. B. Freizeitkarte) einen Weg nicht kennt oder das Profil ihn meidet, rechnet Basecamp anders. Der Track bleibt die Referenz.

### 6.4 Entfernungsliste (CSV) herunterladen — `…_Entfernungen.csv`
Eine Zeile je Wegpunkt in Tour-Reihenfolge. Format für deutsches Excel: Semikolon, Dezimalkomma, UTF-8 mit BOM.

| Spalte | Inhalt |
|---|---|
| Position | Nummer in der Tour-Reihenfolge |
| Name | Name des Wegpunkts |
| Breitengrad / Längengrad | Koordinaten, 7 Nachkommastellen |
| Höhe (m) | aus der GPX-Datei, falls vorhanden |
| Luftlinie zum nächsten Punkt (km) | gerade Entfernung zum Folgepunkt |
| Echter Weg zum nächsten Punkt (km) | Wegdistanz zum Folgepunkt inkl. beider Anschlusswege. Leer im Luftlinien-Modus oder ohne Wegverbindung. |
| Anschlussweg zum Wegenetz (km) | Luftlinie vom Wegpunkt zum nächsten Weg, nur im Wegenetz-Modus |

Beim offenen Weg hat der letzte Punkt keine Folgedistanz. **Verwendung:** Tagesetappen planen, auffällig lange Sprünge finden, Wegpunkte weit abseits von Wegen erkennen (großer Anschlussweg).

### 6.5 Distanzmatrix (JSON, für Analyse) exportieren — `…_distanzmatrix.json`
**Inhalt:** Die vollständige Tabelle aller Entfernungen zwischen allen Wegpunkten, wie sie für die Optimierung verwendet wurde, plus Zusatzangaben:

| Feld | Inhalt |
|---|---|
| `distanzmodell` | `network` (Wegenetz) oder `beeline` (Luftlinie) |
| `tourform` | `open` (offener Weg) oder `closed` (Rundtour) |
| `bisherBesteLaenge_km` | Länge der gefundenen Tour |
| `bisherBesteReihenfolge` | Reihenfolge als Indizes in `punkte`, beginnend bei 0 |
| `punkte` | Name, Breite, Länge, Höhe aller Wegpunkte |
| `matrix_km` | `matrix_km[i][j]` = Entfernung von Punkt i zu Punkt j in km |

**Verwendung:** externe Auswertung, Gegenprobe mit anderen Programmen oder einem exakten Optimierungs-Solver. Für die normale Tourenplanung nicht nötig. Bei 430 Punkten ca. 3–4 MB.

### 6.6 Abgefragtes Wegenetz (GPX) exportieren — `…_OSM_Wegenetz.gpx`
**Nur im Wegenetz-Modus.**
- **Inhalt:** Alle Wege, die nach den eingestellten Filtern im geladenen Gebiet verwendet wurden, nicht nur die der Tour. Ein `<trk>` mit einem Segment je OSM-Weg, magenta eingefärbt (Garmin-Erweiterung).
- **Verwendung:** sichtbar machen, welche Wege das Programm kannte, etwa um **Lücken im OSM-Netz** zu finden, wo Wegpunkte nur per Luftlinie verbunden sind oder ein lokal bekannter Weg fehlt.
- **Achtung, Größe:** Mittelgebirge (ca. 3.000 km²) einige Dutzend MB, **Gebiete von ca. 25.000 km² mehrere hundert MB**. Basecamp wird damit sehr langsam. Für große Gebiete eher nicht verwenden.

### 6.7 Doppelt gelaufene Strecke analysieren
**Erzeugt keine Datei.** Schreibt die Aufschlüsselung aus Abschnitt 5 (echtes Wegenetz + Hinweg-Anteil + Rückweg-Anteil) erneut in die Statuszeile. Diese Analyse läuft nach jeder Wegenetz-Optimierung ohnehin automatisch; der Knopf ist nur zum erneuten Anzeigen.

---

## 7. Empfohlene Arbeitsweise

1. **Erster Lauf im Wegenetz-Modus** mit Standardeinstellungen und großzügiger Rechenzeit. Der erste Download dauert; danach kommt das Gebiet aus dem Zwischenspeicher.
2. **Ergebnis verbessern:** erneut **Optimieren** mit mehr Rechenzeit. Die Matrix bleibt erhalten, siehe Abschnitt 3.
3. **Ausgeben:**
   - **Track** (mit Teilstrecken) für das Navigationsgerät
   - **Route für Neuberechnung** (gleiche Teilstreckenzahl) für Basecamp; an den Flaggen das Profil umschalten
   - **Entfernungsliste** für die Etappenplanung
4. **Alles herunterladen, bevor die Seite geschlossen wird.**

---

## 8. Häufige Fragen

**Die Basecamp-Route ist länger als der Track.** Geringe Abweichungen (Beispiel: +6 km auf 791 km) entstehen durch Unterschiede zwischen Basecamp-Karte und aktuellem OSM. Große Abweichungen bei der Douglas-Peucker-Route entstehen durch Kehrtwenden an falsch eingerasteten Punkten; dafür die Route für Neuberechnung verwenden.

**Track, Route oder Neuberechnungs-Route lassen sich nicht herunterladen.** Entweder wurde mit Luftlinie gerechnet, oder eine Wegenetz-Einstellung wurde nach der Optimierung geändert. Dann erneut optimieren.

**Kann ich einen festen Startpunkt vorgeben?** Nein. Beim offenen Weg wählt das Programm Start und Ziel frei. Die Tour lässt sich in Basecamp aber an jeder Stelle beginnen; bei einer Rundtour ist der Start ohnehin beliebig.

**Wie bekomme ich aktuelle OSM-Daten?** Den Zwischenspeicher leeren und neu rechnen.

**Mehrere Gebiete nacheinander?** Einfach die nächste GPX-Datei laden. Die Zwischenspeicher-Kacheln werden gebietsübergreifend genutzt; überlappende Gebiete laden nichts doppelt.
