MERKO32
=======

Merkfähigkeits-App für das iPhone (SwiftUI), angelehnt an den MEK-Test.
Man sieht 16 Bildschirme mit je 4 Feldern. Jedes Feld zeigt entweder eine neue
Kombination (farbiges Symbol + zweistellige Zahl) oder fragt eine früher gezeigte
Kombination ab (nur das farbige Symbol, die Zahl wird eingetippt). Insgesamt werden
32 Kombinationen gezeigt und jede genau einmal abgefragt.

Der vollständige Auftrag und alle Regeln stehen in PLAN-Merko32.md.


ABLAUF
------
1. Startbildschirm: nur ein Start-Button.
2. 16 Bildschirme, Zeit pro Bildschirm sinkt alle 2 Bildschirme:
   30, 30, 27, 27, 24, 24, 21, 21, 18, 18, 15, 15, 12, 12, 10, 10 Sekunden (zusammen 314 s).
   Kein Weiter-Button: Nach Ablauf der Zeit folgt sofort der nächste Bildschirm.
   "Abbrechen" fragt "Wirklich abbrechen?" und geht dann direkt zur Auswertung.
3. Eingabe über den eigenen Ziffernblock unten: 1-9, 0, Löschen (⌫), Nächstes Feld (⇥).
   Nach der 2. Ziffer springt der Fokus zur nächsten leeren Abfrage.
4. Auswertung: Anzahl richtig, falsch, Prozent und eine Liste aller 32 Abfragen.
   Leere oder einstellige Eingaben und nicht erreichte Abfragen zählen als falsch.


VORAUSSETZUNGEN
---------------
- Xcode 27 (getestet mit Xcode 27.0, Swift 6.4)
- iOS 18.0 oder neuer, nur iPhone, nur Hochformat
- Kein Backend, keine Speicherung über einen Durchlauf hinaus


BAUEN UND STARTEN
-----------------
In Xcode: Merko32.xcodeproj öffnen, Scheme "Merko32", ein iPhone wählen, ⌘R.

Schneller Testmodus (nur Debug-Build): 3 Sekunden pro Bildschirm.
  Xcode -> Product -> Scheme -> Edit Scheme -> Run -> Arguments
  -> bei "Arguments Passed On Launch" den Eintrag  -debugTimes  hinzufügen.


TESTS
-----
Alle Tests (Startup-Performance-Test wird übersprungen, er dauert ca. 32 s):

  xcodebuild test -scheme Merko32 \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    -skip-testing:Merko32UITests/Merko32UITests/testLaunchPerformance

Zusätzlich einen kompletten Durchlauf als UI-Test (ca. 1 Minute):

  TEST_RUNNER_FULL_RUN=1 xcodebuild test -scheme Merko32 \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    -only-testing:Merko32UITests/GameFlowUITests/testFullRunEndsInResult

Unit-Tests (Swift Testing, Ordner Merko32Tests):
  GameConfigTests   - Config-Regeln, deutsche VoiceOver-Labels
  RunGeneratorTests - Ablaufgenerator über 1000 Zufalls-Seeds
  ScoringTests      - richtig, falsch, leer, einstellig, nicht erreicht, Prozent
  GameSessionTests  - Zeitablauf, Bildschirmwechsel, Eingabe, Fokus, Abbruch
UI-Tests (XCTest, Ordner Merko32UITests):
  GameFlowUITests   - Start, Abbruch-Dialog, Neustart, Ziffernblock, Komplett-Durchlauf


AUFBAU
------
Merko32/
  Merko32App.swift      App-Einstieg (Template)
  ContentView.swift     RootView: schaltet zwischen Start, Spiel und Auswertung um
  Model/                GameConfig (alle Parameter + validate()), Symbole, Farben,
                        Combination, MemoryItem, Screen/Field, Run
  Logic/                RunGenerator (erzeugt einen Durchlauf), Scoring (Auswertung)
  Session/              GameSession (Ablaufsteuerung), Ticker (Sekundentakt)
  Views/                StartView, GameView, FieldView, SymbolView, NumberPadView,
                        CountdownView, ResultView, Color+Hex
Merko32Tests/           Unit-Tests + SeededGenerator + ManualTicker
Merko32UITests/         UI-Tests

Model, Logic und Session verwenden kein SwiftUI und sind ohne Oberfläche testbar.
GameSession kennt keine echte Zeit; der Ticker ruft einmal pro Sekunde tick() auf.
In Tests wird stattdessen ein ManualTicker verwendet.


ANPASSEN
--------
Alle Spielparameter (Symbole, Farben, Anzahl, Zahlenbereich, Verteilung, Zeiten)
stehen zentral in Merko32/Model/GameConfig.swift. validate() prüft Änderungen.
Weitere Ideen für Anpassungen: siehe PLAN-Merko32.md, Abschnitt
"Mögliche Anpassungen nach den ersten Tests".
