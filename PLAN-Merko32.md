# Merko32 – Plan für eine MEK-ähnliche Merkfähigkeits-App (SwiftUI, iPhone)

> Diese Datei ist der vollständige Auftrag. Bitte lies sie ganz und arbeite die Schritte unten **einzeln** ab.
> Nach jedem Schritt: bauen, testen, mir kurz berichten und **warten**, bis ich committet habe. Selbst nichts committen.

---

## 0. Vorbereitung (mache ich selbst in Xcode, bevor Claude startet)
1. Xcode → **File → New → Project → iOS → App**
   - Product Name: `Merko32`, Interface: SwiftUI, Language: Swift
   - Testing System: **Swift Testing** (damit das Test-Target `Merki32Tests` gleich mit angelegt wird)
   - Storage: None
2. Im Target `Merko32` → General:
   - Minimum Deployments: **iOS 18.0**
   - Supported Destinations: **nur iPhone** (iPad, Mac, Vision entfernen)
   - Device Orientation: **nur Portrait**
3. Build Settings → Swift Language Version: **Swift 6**
4. Mit ⌘B bauen und mit ⌘U die Tests laufen lassen, dann Git-Repo anlegen und den ersten Commit machen.
5. In diesem Ordner Claude starten und auf diese Datei verweisen.

## Regeln für Claude im Projekt
- **Vorhandene Dateien niemals verschieben oder umbenennen** (auch nicht `ContentView.swift`/`Merki32App.swift`). Das hat im ersten Versuch Xcode durcheinandergebracht. Muss etwas verschoben werden, sagst du es mir und ich mache es in Xcode.
- Neue Dateien direkt am Zielort anlegen. Das Projekt nutzt synchronisierte Ordner, Xcode übernimmt neue Dateien und Unterordner unter `Merki32/` bzw. `Merki32Tests/` automatisch. Die Datei `project.pbxproj` nicht von Hand ändern.
- Wenn eine neue Datei in Xcode nicht auftaucht, sag mir Bescheid, statt Workarounds zu bauen.
- Nach jedem Schritt: `xcodebuild test -scheme Merki32 -destination 'platform=iOS Simulator,name=iPhone 17'` muss grün sein.
- Oberfläche und Kommentare auf Deutsch, Code-Bezeichner auf Englisch.

---

## Anforderungen (von mir festgelegt)

### Ablauf
1. **Startbildschirm:** Nur ein Start-Button, keine Einstellungen.
2. **Spiel:** 16 Bildschirme nacheinander mit je 4 Feldern. Jedes Feld zeigt entweder
   - eine **NEUE** Kombination (Symbol in Farbe + zweistellige Zahl) oder
   - eine **ABFRAGE** (nur Symbol in Farbe, ich gebe die Zahl ein).

   Verteilung neu/Abfrage pro Bildschirm:

   | Bildschirm | 1 | 2 | 3–14 | 15 | 16 |
   |---|---|---|---|---|---|
   | neu | 4 | 3 | je 2 | 1 | 0 |
   | Abfrage | 0 | 1 | je 2 | 3 | 4 |

   Insgesamt werden 32 Kombinationen gezeigt, und jede wird genau einmal abgefragt. Abgefragt wird nur, was auf einem **früheren** Bildschirm gezeigt wurde, nie auf demselben. Wo auf dem Bildschirm die neuen Felder und die Abfragen stehen, wird pro Bildschirm zufällig gemischt.
3. **Zeitlimit pro Bildschirm** (8 Stufen, die Zeit sinkt alle 2 Bildschirme):
   `30, 30, 27, 27, 24, 24, 21, 21, 18, 18, 15, 15, 12, 12, 10, 10` Sekunden. Der Countdown ist sichtbar.
   - **Es gibt keinen Weiter-Button.** Der Bildschirm läuft immer bis zum Ablauf der Zeit, danach folgt sofort und ohne Übergang der nächste.
   - **Es gibt einen Abbruch-Button.** Nach einer kurzen Bestätigung („Wirklich abbrechen?“) geht er **direkt zur Auswertung**, nicht zum nächsten Bildschirm.
4. **Auswertung:**
   - Anzahl richtig, Anzahl falsch und der Prozentwert.
   - Eine Liste aller 32 Abfragen in der Reihenfolge, in der sie abgefragt wurden: Symbol in Farbe, richtige Zahl, meine Eingabe und ✓/✗.
   - Ein Button „Neuer Durchlauf“.

### Zahlen
- Es werden 32 **verschiedene** Zahlen aus dem Bereich 11–99 gezogen (ohne Zurücklegen). Innerhalb eines Durchlaufs wiederholt sich keine Zahl.

### Symbole und Farben (6 × 6 = 36 mögliche Kombinationen)
- Symbole (SF Symbols): `star.fill, heart.fill, triangle.fill, square.fill, moon.fill, bolt.fill`
- Farben: Rot `#E53935`, Gelb `#FDD835`, Grün `#43A047`, Blau `#1E57D6`, Orange `#FB8C00`, Violett `#8E24AA`
- Hintergrund: Dunkelgrau `#2B2B2B`
- Beim Start eines Durchlaufs werden aus den 36 Kombinationen **zufällig 32 verschiedene** ausgewählt, und jeder davon wird zufällig eine der 32 verschiedenen Zahlen zugeordnet.
- Symbole, Farben, die Zahl 32, der Zahlenbereich, die Verteilung pro Bildschirm und die Zeiten stehen **zentral in einer `GameConfig`**. Regel: Symbole × Farben ≥ 32.

### Technik
- SwiftUI, iOS 18, nur iPhone, nur Hochformat, kein Backend, keine Speicherung über einen Durchlauf hinaus.
- Datenmodell, Ablaufgenerator und Zeitsteuerung sind **von den Views getrennt** und mit Unit-Tests (Swift Testing) prüfbar.

### Annahmen (gelten, solange ich nichts anderes sage)
1. Wird abgebrochen, erscheinen nicht erreichte Abfragen in der Liste als „nicht erreicht“ und **zählen als falsch**. Der Prozentwert bezieht sich auf alle 32 Abfragen.
2. Ein leeres oder nur einstelliges Feld bei Zeitablauf zählt als falsch (Anzeige „–“).
3. Geht die App in den Hintergrund, pausiert der Timer. Dafür gibt es keine Sonderlogik.
4. Es gibt kein Zurück zu früheren Bildschirmen.
5. Für VoiceOver bekommt jedes Feld ein Label, z. B. „roter Stern“.

---

## Architektur

### Ordnerstruktur (neue Dateien; die Template-Dateien bleiben, wo sie sind)
```
Merko32/
  Merko32App.swift        (Template, bleibt hier – zeigt RootView)
  ContentView.swift       (Template, bleibt hier – wird zur RootView, die je nach Phase umschaltet)
  Model/
    GameConfig.swift      – alle Parameter + validate()
    GameSymbol.swift      – SF-Symbol-Name + deutscher Name
    GameColor.swift       – Hex-Wert + deutscher Name (kein SwiftUI hier)
    Combination.swift     – struct Combination: Hashable { symbol, color }
    MemoryItem.swift      – struct { id, combination, number }
    Screen.swift          – struct Screen { index, seconds, fields: [Field] }
                            enum Field { case show(MemoryItem), query(MemoryItem) }
    Run.swift             – struct Run { items, screens }
  Logic/
    RunGenerator.swift    – erzeugt einen Run (reine Funktion, RNG wird injiziert)
    Scoring.swift         – Antworten → GameResult
  Session/
    GameSession.swift     – @Observable @MainActor State-Machine
    Ticker.swift          – Protokoll Ticker + ClockTicker (Produktion)
  Views/
    StartView, GameView, FieldView, NumberPadView, CountdownView, ResultView, Color+Hex
Merko32Tests/
  SeededGenerator.swift, GameConfigTests, RunGeneratorTests, ScoringTests, GameSessionTests
```
Model, Logic und Session importieren nur Foundation/Observation, kein SwiftUI.

### GameConfig
```
symbols, colors (wie oben)
combinationsPerRun = 32, numberRange = 11...99, fieldsPerScreen = 4
newPerScreen     = [4,3,2,2,2,2,2,2,2,2,2,2,2,2,1,0]
queryPerScreen   = [0,1,2,2,2,2,2,2,2,2,2,2,2,2,3,4]
secondsPerScreen = [30,30,27,27,24,24,21,21,18,18,15,15,12,12,10,10]
```
`validate()` prüft (als Test und als `precondition`):
- symbols × colors ≥ 32
- numberRange.count ≥ 32
- pro Bildschirm gilt neu + Abfrage = 4
- Σneu = Σabfrage = 32
- alle Arrays haben die gleiche Länge (16)
- **Präfixbedingung:** Vor jedem Bildschirm s gilt: gezeigt(< s) − abgefragt(< s) ≥ queryPerScreen[s]

Für schnelle manuelle Tests gibt es mit `#if DEBUG` eine Config mit z. B. 3 s pro Bildschirm.

### Algorithmus `RunGenerator.make(config:using:&rng)`
1. Alle 36 Kombinationen (Symbol × Farbe) bilden, mit `shuffled(using:)` mischen und die ersten 32 nehmen.
2. `Array(11...99)` mischen und die ersten 32 Zahlen nehmen. Damit sind alle Zahlen verschieden.
3. Beides zu 32 `MemoryItem`s zusammenführen. In dieser Reihenfolge werden sie gezeigt.
4. Mit `pool = []` (gezeigt, noch nicht abgefragt) und `next = 0` für jeden Bildschirm s:
   1. `queries`: `queryPerScreen[s]` Items zufällig aus dem `pool` ziehen und entfernen. Der Pool enthält in diesem Moment nur Items **früherer** Bildschirme.
   2. `news = items[next ..< next + newPerScreen[s]]`, danach `next` weiterzählen.
   3. **Erst jetzt** kommen die `news` in den `pool`.
   4. `fields = (news → .show) + (queries → .query)`, anschließend mischen.
5. Die Poolgröße vor den Bildschirmen ist 0, 4, 6, 6 … 6, 4. Es gibt also immer genug Items für die Abfragen, und am Ende ist der Pool leer (`assert`).

### Zeitsteuerung (testbar)
- `GameSession` kennt keine echte Zeit. Sie hat `remainingSeconds` und `tick()`, das um 1 Sekunde herunterzählt. Bei 0 wechselt sie zum nächsten Bildschirm, nach Bildschirm 16 zur Auswertung.
- `protocol Ticker { func start(_ onTick: @escaping @MainActor () -> Void); func stop() }`
  - `ClockTicker`: `Task` mit einer Schleife aus `try await clock.sleep(for: .seconds(1))` und `onTick()`.
  - In Tests: `ManualTicker` bzw. direkte Aufrufe von `tick()`, ganz ohne Warten.

### GameSession
- `phase: .start | .playing | .result(GameResult)`
- Zustand: `run`, `screenIndex`, `remainingSeconds`, `answers: [MemoryItem.ID: String]`, `focusedItemID`
- Methoden: `start()`, `tick()`, `input(digit:)`, `deleteDigit()`, `focusNext()`, `focus(id:)`, `abort()`

### Eingabeverfahren
- Ein **eigener Ziffernblock** unten statt der Systemtastatur, damit das 2×2-Raster nie verdeckt wird.
- Layout: Kopfzeile („Bildschirm 5/16“, Countdown als Zahl + Balken, Abbruch), darunter das 2×2-Raster, darunter der Ziffernblock `1–9, ⌫, 0, ⇥`.
- Ein Zeigefeld zeigt das Symbol in seiner Farbe und groß die Zahl. Ein Abfragefeld zeigt das Symbol in seiner Farbe und ein Eingabekästchen mit 2 Stellen. Das aktive Feld bekommt einen deutlichen Rahmen.
- Beim Start eines Bildschirms liegt der Fokus auf der ersten Abfrage. Antippen fokussiert ein Feld. Nach der 2. Ziffer springt der Fokus automatisch zur nächsten leeren Abfrage. `⇥` springt zyklisch weiter, `⌫` löscht die letzte Ziffer.
- Die erste Ziffer darf nicht 0 sein, mehr als 2 Ziffern gehen nicht. Bestätigen ist nicht nötig, denn bei Zeitablauf zählt der Feldinhalt.

---

## Umsetzungsschritte (jeder einzeln testbar und committbar)
1. **Model + GameConfig + validate()** mit `GameConfigTests`.
2. **RunGenerator + SeededGenerator** mit `RunGeneratorTests` über ≥ 1000 Seeds. Geprüft wird:
   - 16 Bildschirme mit je 4 Feldern, Verteilung pro Bildschirm korrekt
   - 32 verschiedene Kombinationen und 32 verschiedene Zahlen in 11–99
   - jedes Item wird genau einmal gezeigt und einmal abgefragt
   - der Abfrage-Bildschirm liegt nach dem Bildschirm, auf dem das Item gezeigt wurde
   - gleicher Seed ergibt gleichen Run
3. **Scoring** mit `ScoringTests`: richtig, falsch, leer, einstellig, nicht erreicht, Prozent.
4. **GameSession + Ticker** mit `GameSessionTests`:
   - nach 30 Ticks ist Bildschirm 2 aktiv
   - nach 300 Ticks ist die Phase Auswertung
   - Eingaben bleiben erhalten
   - die Fokuslogik funktioniert
   - `abort()` führt sofort zur Auswertung und stoppt den Ticker
5. **RootView (in `ContentView.swift`) + StartView**: Umschalten nach Phase, mit Platzhaltern. Im Simulator prüfen.
6. **GameView + FieldView + CountdownView + Abbruch** (noch ohne Ziffernblock). Prüfen, dass die Zeit abläuft und die Bildschirme wechseln.
7. **NumberPadView + Fokusführung**, dann einen kompletten Durchlauf spielen.
8. **ResultView** mit Liste und „Neuer Durchlauf“.
9. **Feinschliff:** Kontrast auf `#2B2B2B`, Accessibility-Labels, Haptik, App-Icon.

## Verifikation
- Nach jedem Schritt laufen die Unit-Tests grün (siehe Befehl oben).
- Mit der DEBUG-Config (3 s pro Bildschirm) im Simulator einmal komplett durchspielen, einmal abbrechen und einmal neu starten.
