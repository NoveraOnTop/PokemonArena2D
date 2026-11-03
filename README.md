# Pokémon Arena 2D · Arena Lab

Eigenständiger privater Fan-Prototyp in **Godot 4.5.1 / GDScript**, 1280 × 720. Dieses Projekt ist nicht das Spiel von Big Kid Nation und nicht mit dessen Entwicklern verbunden. Sämtliche Figuren sind selbst programmierte Pixel-Platzhalter; es wurden keine fremden Spielgrafiken oder Audiodateien übernommen.

## Start

`project.godot` mit Godot 4.5.1 Standard öffnen und **F5** drücken. „Kampf starten“ beginnt einen 3-gegen-3-Kampf gegen ein zufälliges KI-Team. Zusätzlich gibt es Training, Statistik, Bosskampf, ein Turnier mit drei Runden, einen Überlebensmodus mit fünf Wellen und die fünfteilige Arena-Chronik. Die Arena wird außerhalb der Kampagne bei jedem neuen Kampf zufällig bestimmt.

Der Prototyp verwendet die Compatibility-Render-Pipeline, die auch auf älteren integrierten Grafikkarten läuft. Eine ältere Godot-4-Version wurde nicht geprüft.

## Neuer Spielaufbau

Die alte Seitenansicht mit Gravitation, Sprüngen und Plattformen wurde durch eine Arena aus schräger Vogelperspektive ersetzt. Die Figuren bewegen sich auf einer zweidimensionalen Bodenfläche. Pfeil hoch bewegt nach hinten; es gibt keine Sprungtaste mehr. Diagonale Bewegung ist auf dieselbe Geschwindigkeit begrenzt wie gerade Bewegung.

## Steuerung

| Eingabe | Funktion |
|---|---|
| WASD oder Pfeiltasten | In alle Richtungen bewegen |
| Maus innerhalb der Arena | Frei zielen |
| J / linke Maustaste | Attacke 1 |
| K / rechte Maustaste | Attacke 2 |
| L / Q | Attacke 3 |
| I / E | Spezialattacke |
| Leertaste | In Bewegungsrichtung ausweichen; im Stand letzte Bewegungsrichtung |
| R | Zum nächsten lebenden Teammitglied wechseln |
| 1 / 2 / 3 oder Porträt anklicken | Gewählten Teamplatz einwechseln |
| Esc | Pause / Fortsetzen |
| F2 | Gegner-KI an / aus |

Auf Geräten mit Touchscreen dient die linke untere Bildschirmhälfte als virtueller Bewegungsstick. Rechts im Spielfeld wird durch Wischen gezielt und beim Loslassen die erste Attacke ausgelöst. Ausweichen, vier Attacken und Teammitglieder lassen sich direkt über die HUD-Flächen antippen.

Im Teammenü stehen drei dauerhaft speicherbare Team-Slots zur Verfügung. Änderungen am aktiven Slot werden automatisch gespeichert; ein Slotwechsel lädt sofort das gespeicherte Team.

Ohne Mausbewegung zielt die Figur automatisch zum aktiven Gegner. Gamepad: linker Stick bewegen, rechter Stick zielen, A ausweichen, B Teamwechsel, X/Y/LB/RB vier Attacken, Start Pause. Ein physisches Gamepad wurde nicht angeschlossen und getestet.

Die unteren Attackenkarten lassen sich auch anklicken. Beim Klicken auf die Bedienflächen bleibt der letzte Zielpunkt innerhalb der Arena erhalten.

## Spielbare Kreaturen und tatsächliche Fähigkeiten

- **Pikachu:** Donnerblitz, Ruckzuckhieb, Elektroball, Donner. Statische Energie regeneriert 16 statt 13 Energie pro Sekunde.
- **Glurak:** Flammenwurf, Feuerwirbel, Luftschnitt, Feuersturm. Glutkern verhindert Brandstatus.
- **Turtok:** Aquaknarre, Hydropumpe, Panzerschutz, Surfer. Panzer reduziert eingehenden Schaden um 10 Prozent.
- **Gengar:** Spukball, Hypnose, Schattenstoß, Nachtnebel. Schattenhülle verlängert das Ausweichfenster von 0,22 auf 0,28 Sekunden.
- **Lapras:** Aquaknarre, Eisstrahl, Panzerschutz, Blizzard. Frostschild verhindert Verlangsamung.
- **Sichlor:** Schlitzer, Ruckzuckhieb, Luftschnitt, Sichelsturm. Jägerinstinkt erhöht das Bewegungstempo bei mehr als 70 Energie um 10 Prozent.

Alle sechs haben eigene Statuswerte, Größen, schattierte Pixelgrafiken, Porträts, Bewegungsdarstellung und Attackenkombinationen. Alle sechs besitzen eigene Vorder-, Rücken- und Profilansichten; das Profil wird für links gespiegelt. Jede Ansicht hat einen Zyklus aus vier Schrittphasen. Beim Bewegen folgt der Körper der Laufrichtung, während der Angriffsanimation der Zielrichtung. Es gibt weiterhin keine acht eigenständigen Richtungszeichnungen.

## Kampfregeln

- Drei Kreaturen pro Team, jeweils eine aktiv. Ein besiegtes Mitglied wird automatisch ersetzt. Erst wenn das gesamte Team besiegt ist, endet der Kampf.
- Freiwilliger Teamwechsel hat zwei Sekunden Abklingzeit. KP, Energie und Attacken-Cooldowns bleiben pro Kreatur erhalten. Inaktive Kreaturen regenerieren Energie und bauen Cooldowns ab, aktive Statuslaufzeiten pausieren auf der Bank.
- Energie, Cooldowns, begrenzte Trefferbetäubung, Rückstoß und Ausweich-Unverwundbarkeit gelten für beide Seiten.
- Donner und Flächenangriffe markieren ihren Zielbereich vor dem Einschlag. Donner schlägt sichtbar von oben ein; die Warnphase richtet keinen Schaden an.
- Wasser macht nass: vier Sekunden lang 25 Prozent mehr Elektroschaden. Feuer verursacht 3,5 Sekunden Brand mit 2,5 KP pro Sekunde. Eis/Nachtnebel verlangsamen für 2,2 Sekunden. Hypnose blockiert Bewegung und Angriffe für höchstens 0,85 Sekunden; ein Treffer beendet vorhandenen Schlaf. Schutz verhindert neue Statusanwendungen.
- Panzerschutz reduziert Schaden für 2,8 Sekunden um 75 Prozent. Turtoks passive Reduktion kommt zusätzlich dazu.
- Typenwirkung liegt in `Data/types.json`. Die Wirkung wird über alle Einträge in `types` der Zielkreatur multipliziert. Lapras ist Wasser/Eis, Glurak Feuer/Flug, Gengar Geist/Gift und Sichlor Käfer/Flug. Die Tabelle deckt die eingesetzten Typen ab, nicht die vollständige Pokémon-Datenbank.
- Felsen besitzen echte Kollisionen und 45 Strukturpunkte. Sie blockieren Bewegung und Projektile. Strahlen enden am ersten Felsen. Angriffe zerstören Felsen und öffnen dadurch neue Wege.
- Leicht/Normal/Schwer ändern KI-Reaktion und Ausweichhäufigkeit; Statuswerte werden nicht erhöht.

## Grafik und Bedienung

Neun zufällig ausgewählte Arenen besitzen eigene Gestaltung, Hindernisse, passende Typvorteile und wiederkehrende Umgebungsereignisse. Dazu zählen unter anderem Vulkanhitze, heilende Wiesenenergie, Sturmblitze, Geisterenergie-Entzug und Kraftwerksaufladung. Tiefes Küstenwasser bremst Nicht-Wassertypen, während Wasser-Pokémon dort schneller schwimmen. Heiße Vulkanränder und dichter Dschungel verändern ebenfalls die Bewegung. Starke Flächenattacken hinterlassen zeitweise sichtbare Einschlagspuren.

Überarbeitete Menüs, Teamwerkstatt, einheitliche Karten, Charakterporträts, KP-Balken, Typen, Teamstatus, Energie, Statusanzeigen, farbige Attackenkarten und Countdown-Anzeigen. Eigene synthetische Soundeffekte und neun kurze, pro Arena unterschiedliche Chiptune-Schleifen mit Lautstärkeregler. Es werden keine fremden Audiodateien verwendet.

## Projektstruktur

| Ordner | Inhalt |
|---|---|
| Scenes | Startszene |
| Scripts | Spielablauf, Eingaben, Kämpfer, Angriffs-Lebenszyklen |
| Art | Eigener Pixelgrafik-Generator mit Cache |
| Data | JSON für 24 Kreaturen, 46 Attacken und Typenwirkung |
| Arenas | Arenadarstellung und zerstörbare Felsen |
| UI | Gezeichnetes Kampf-HUD |
| Effects | Partikel-/Ringeffekte |
| Tests | Zusätzliche Kampftests und visuelle Prüfszenen |
| Characters, Moves, Audio, Resources | Vorbereitete Ordner für spätere eigene Ressourcen |

`main.gd` baut Menü, Teamauswahl, Welt und Audio auf. `fighter.gd` kümmert sich um Eingabe/KI, Zustände und Bewegung. `projectile.gd` nutzt je nach Attackentyp Projektile, Strahlen, gerichtete Nahkampfbögen oder verzögerte Flächen. Grafik und Trefferbereiche teilen sich dieselben Parameter.

Team, Schwierigkeit, Lautstärke, eigene primäre Tasten sowie Trainerlevel und Erfahrung werden lokal unter `user://arena_settings.cfg` gespeichert. Siege geben Erfahrung; höhere Trainerlevel verstärken das eigene Team schrittweise bis höchstens 20 Prozent.

Zusätzlich werden Siege, Niederlagen, aktuelle Serie, beste Serie und Gesamtzahl der Kämpfe gespeichert und nach jeder Runde im Ergebnisbildschirm angezeigt.

Die Menütexte wurden auf der Zielauflösung 1280 × 720 auf Überlauf und Mindestlesbarkeit geprüft. Sehr kleine 9–11-px-Infotexte wurden auf 11–13 px angehoben; Überschriften und Schaltflächen bleiben innerhalb ihrer Karten. Normale Revanchen ziehen ein neues Gegnerteam und verhindern eine direkte Wiederholung derselben Dreiergruppe.

## Validierung

Auf diesem Rechner mit Godot 4.5.1 importiert, tatsächlich ausgeführt und über die OpenGL-Compatibility-Pipeline gerendert. Menü, Teamwerkstatt und Kampfansicht wurden als Bilder ausgegeben und visuell geprüft.

Automatisierte Laufzeitprüfungen:

```
godot --headless --path <Projektordner> --script res://Scripts/smoke_test.gd
godot --headless --path <Projektordner> --script res://Tests/combat_test.gd
```

Geprüft werden unter anderem Pfeiltasten, vertikale/diagonale Bewegung, Felsenkollision, Projektiltreffer, Energie, Cooldowns, Ausweichen, Schutz, Status, Pause, Teamwechsel, KO-Nachrücken, Kampfende, Revanche, Attacken-Lebenszyklen, Felszerstörung, Menüs, Donnerwarnung, Ausweichen aus dem Donnerkreis, Nass-/Elektro-Kombination und passive Fähigkeiten. Beide Testläufe enden bei Erfolg mit Exitcode 0.

Die Windows-Umgebung meldet beim Start einen Fehler beim Lesen ihres System-Zertifikatsspeichers. Das Spiel nutzt keine Netzwerkfunktionen; Import, Rendering und Tests funktionieren trotzdem. Die normale Bildrate ist auf 60 begrenzt. Eine separate identische Trainingsszene ohne FPS-Begrenzung ergab vor der Optimierung 39,10 ms durchschnittliche Framezeit bei 849 Zeichenaufrufen und danach 3,15 ms bei 102 Zeichenaufrufen. Im ersten gerenderten vollständigen Probekampf lag der niedrigste sekündlich erfasste FPS-Wert bei 53, vorher 17. Das sind Messungen auf diesem Rechner bei parallel geöffneten Programmen und keine allgemeine 60-FPS-Garantie.

## Arena-Chronik und Richtungen

Die Kampagne besteht aus fünf aufeinanderfolgenden Kapiteln mit eigenem Text, festem Schauplatz und handverlesenem Gegnerteam. Der erreichte Fortschritt wird gespeichert. Kämpfer unterscheiden acht Bewegungs- und Blickzustände inklusive Diagonalen. Die vorhandenen vier Pixelvorlagen werden für die diagonalen Zustände passend ausgerichtet; es handelt sich nicht um acht separat handgezeichnete Sprites pro Pokémon.

## Noch nicht enthalten

Kein Onlinemodus und keine vollständige Pokémon-Datenbank. Die 20 enthaltenen Pokémon, ihre eingesetzten Typen und Fähigkeiten sind für diesen Prototyp umgesetzt. Die Grafiken sind Fan-Prototyp-Material und nicht zur Veröffentlichung gedacht. Touch-Eingaben konnten auf diesem Rechner nicht mit echter Hardware geprüft werden.


## Nachbesserungen nach dem vollständigen Probekampf

- Die detaillierten Arenen liegen nun als vorgerenderte eigene PNG-Dateien vor. Nur Glut und Wasser-Umgebung werden separat animiert. Die Quelldarstellung bleibt in Art/arena_source.gd erhalten; Tests/bake_arenas.gd erzeugt die PNGs erneut.
- HUD-Stile werden wiederverwendet und die Kampfanzeigen höchstens 30-mal pro Sekunde neu aufgebaut. Bewegung und Physik bleiben bei 60 Ticks.
- Cooldowns stehen oben rechts in jeder Attackenkarte mit eigenem Fortschrittsbalken. Der Attackenname bleibt frei.
- Die Schadensstatistik zählt tatsächlichen KP-Verlust nach Schutz und Panzer. Überzähligen Schaden beim KO zählt sie nicht. Brandschaden wird der verursachenden Kreatur zugerechnet. Die Ergebnisanzeige zeigt eine Nachkommastelle.
- Flammenwurf verursacht 16 statt 20 Grundschaden und hat 1,05 Sekunden Cooldown. Feuerwirbel verursacht 7 statt 12 pro Treffer, pulsiert alle 0,8 Sekunden für 2,4 Sekunden und hat fünf Sekunden Cooldown. Feuersturm verursacht 38 statt 49 Schaden bei 8,5 Sekunden Cooldown und 50 Energie.
- Doppeltypen werden berücksichtigt: Feuer ist gegen Wasser/Eis-Lapras neutral. Damit ersetzt eine Typenverwechslung nicht mehr die eigentliche Balance.
- Tests/regression_test.gd prüft Schadenszählung, überschüssigen Schaden beim KO, Brand-Zurechnung, die neuen Richtungen sowie Feuer gegen Lapras.
- Tests/full_round.gd spielt vollständige automatisierte Runden mit normalen Spieleraktionen, ohne KP oder Statuswerte zu verändern. Zusätzliche Startargumente: -- label=run-name seed=27102026. Eine automatisierte Runde ersetzt keine manuelle Prüfung des Spielgefühls und drei Runden beweisen keine vollständige Balance.



## 30-Minuten-Prüfung vom 27. Oktober 2026

- Primäre Tastaturbelegungen sind im Einstellungsmenü änderbar, dauerhaft speicherbar und zurücksetzbar. Doppelte Belegungen werden abgewiesen. Pfeiltasten sowie Esc, F2 und 1–3 bleiben feste Alternativen. Q/E bleiben Zusatzattackentasten, solange keine eigene primäre Belegung sie verwendet. Maus und Gamepad bleiben nutzbar. Hilfe und Kampf-HUD zeigen die gespeicherten Tasten.
- Manuelle Stick-Zielrichtungen gelten jetzt auch für Flächenattacken. Der erste tatsächlich angeschlossene Controller wird berücksichtigt; die Belegung wurde mit simulierten Eingaben geprüft, nicht mit physischer Hardware.
- Wechsel während eines Angriffsvorstoßes sind gesperrt. Besiegte und inaktive Kreaturen können keine Attacken oder Ausweichaktionen mehr auslösen. Aktionen respektieren die Pause.
- Flächenangriffe stoßen vom Einschlagzentrum weg. Strahlen enden an der vorderen Felsenkante. Schnelle Projektile berücksichtigen die Reihenfolge der ersten Kontakte, damit ein weiter entfernter Felsen keinen näheren Treffer verschluckt.
- KI wählt nur bezahlbare, abgekühlte Attacken in Reichweite und berücksichtigt Immunitäten. Normal/Schwer gewichten Typen, Status und Energiekosten zusätzlich. Schild wird in Bedrängnis eingesetzt.
- Kampfzeit und Zustandswechsel laufen im festen Physiktakt. Kampf-, Ton- und Grafikzufall sind getrennt. Zwei komplette Runden mit identischem Startwert ergaben identische Kampfzustände und Ergebnisse.
- Acht eigene Tonstimmen erlauben überlappende Treffer- und Attackengeräusche. Die Lautstärke wirkt auch auf bereits spielende Stimmen. Beim Schließen werden die Tonstimmen kontrolliert beendet.
- Fokusverlust pausiert einen laufenden Kampf automatisch. Niederlagen sind ausdrücklich benannt und die Ergebnisansicht zeigt die verbliebenen KP beziehungsweise KO der eigenen Teammitglieder.
- Fehlende Energie und Cooldowns werden kurz erklärt. Die Lücken zwischen Attacken- und Teamkarten lösen keine Aktionen mehr aus. Mausattacken verwenden den aktuellen Zielpunkt ohne veraltete Richtung vom vorherigen Physiktakt.
- Editierbare JSON-Daten werden vor Kampfbeginn geprüft. Ungültige Werte, fehlende Attacken und kaputte Typentabellen erzeugen eine lesbare Fehlerseite. Fehlerhafte numerische Einstellungswerte fallen auf sichere Standardwerte zurück.

Zusätzliche Prüfszenen: `Tests/audit_regression.gd`, `Tests/input_audio_ai_test.gd`, `Tests/occlusion_test.gd`, `Tests/data_lifecycle_test.gd`, `Tests/soak_test.gd`, `Tests/review_visuals.gd`. Der Dauertest wechselt Teams, Arenen und Schwierigkeitsgrade, unterbricht/fortsetzt Kämpfe und kontrolliert KP, Energie, Arena-Grenzen sowie verwaiste Knoten. Er ist ein automatisierter Stabilitätstest, kein manueller Test des Spielgefühls.


Prüfergebnis dieser Überarbeitung: sieben funktionale Prüfsammlungen mit 99 bestandenen Einzelprüfungen; zusätzlich zehn bestandene Prüfungen über den tatsächlichen Godot-GUI-Eingabeweg. Der zehnminütige Dauertest schloss 17 Kämpfe mit 81 freiwilligen Wechseln und 17 Pause/Fortsetzen-Prüfungen ohne Zustandsfehler oder verwaiste Knoten ab; die Speicher-Stichproben lagen zwischen 43,0 und 43,2 MB. Ein frisch aus der ZIP entpacktes Projekt wurde neu importiert und bestand den vollständigen Kampftest. Eine physische Gamepad- und manuelle Spielgefühlprüfung bleibt offen.

## Figuren-Sprites

Die vier Richtungsansichten in `Art/Sprites` basieren bei den ersten 15 Figuren auf den Overworld-Sprites aus Pokémon HeartGold/SoulSilver. Bezugsquelle: veekun Sprite-Paket (`https://veekun.com/dex/downloads`). Quajutsus Richtungen basieren auf dem Walk-Sprite der PMD Sprite Collaboration (`https://github.com/PMDCollab/SpriteCollab`). Pokémon und die Figuren gehören Nintendo, Game Freak und Creatures.

## Zufällige Arenen und Heimvorteile

Bei jedem neuen Kampf und jeder Revanche wird eine von neun vollständig unterschiedlich gestalteten Arenen ausgelost. Die manuelle Kartenauswahl wurde entfernt. Eigene Bodenformen, Wege, Dekorationen, Umgebungsanimationen und Hindernisaufstellungen verändern Deckung und Laufwege. Pokémon mit passenden Typen erhalten 10 Prozent mehr Bewegungstempo, 12 Prozent mehr Schaden und 20 Prozent schnellere Energieaufladung. Der aktuell aktive Arenabonus wird im Kampf-HUD angezeigt.

Der Angriffsbonus gilt gezielt für Attacken, deren Typ zur Arena passt. Solche Attacken verursachen 12 Prozent mehr Schaden, bewegen sich 10 Prozent schneller und besitzen eine 12 Prozent größere Trefferfläche. Im Kampf-HUD sind sie mit `ARENA+` markiert und erhalten einen goldenen Verstärkungsring. Unpassende Attackentypen bleiben unverändert.

Alle Attacken besitzen zusätzlich überarbeitete Pixel-Effekte: weich auslaufende Bewegungsspuren, typabhängige Symbole und Partikel, geschichtete Leuchtkerne sowie kräftigere Trefferexplosionen mit Lichtblitz, Doppelring, Strahlen und rautenförmigen Splittern. Strahlen, Nahkampfbögen, Projektile und Flächenattacken behalten dabei ihre ursprünglichen Trefferbereiche.

Ausgewählte Attacken besitzen eigene Detailanimationen statt nur eines allgemeinen Typeffekts: Wasser-Shuriken rotiert als vierzackiger Wasserstern, Donnerblitz verzweigt sich, Rasierblatt fliegt als Blattfächer, Aurasphäre nutzt gegenläufige Energieringe, Psycho-Attacken bilden eine Helix und Mond-, Drachen-, Feuer- sowie Unlichtattacken haben eigene Silhouetten. Als Gestaltungsreferenz diente das Prinzip mehrstufiger Effekte aus Pokémon Showdown; sämtliche Grafiken werden eigenständig in Godot gezeichnet.

Alle 46 Attacken besitzen außerdem einen stabilen individuellen visuellen Fingerabdruck. Partikelzahl, Umlaufrichtung, Geschwindigkeit, Abstand und Form werden pro Attacken-ID festgelegt. Dadurch unterscheiden sich auch Attacken desselben Typs und derselben Grundform sichtbar voneinander.

- Lavakessel: Feuer, Gestein und Boden
- Blütenpfad: Pflanze, Käfer und Fee
- Korallenstrand: Wasser, Eis und Elektro
- Kristallhöhle: Eis, Psycho und Stahl
- Sonnenruinen: Kampf, Geist und Normal
- Sturmspitze: Elektro, Flug und Drache
- Spukschloss: Geist, Unlicht und Psycho
- Urwaldring: Pflanze, Gift und Käfer
- Impulskraftwerk: Stahl, Elektro und Kampf

## Zufälliges Gegnerteam

In normalen KI-Kämpfen und bei jeder Revanche werden drei verschiedene Gegner neu aus allen 20 verfügbaren Pokémon gezogen. Innerhalb des gegnerischen Teams gibt es keine Doppelungen; eine direkte Wiederholung derselben Dreiergruppe wird verhindert. Das freie Training verwendet weiterhin feste Dummys, damit Tests und Übungssituationen reproduzierbar bleiben.

