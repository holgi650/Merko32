# CLAUDE.md – Merko32

Merkfähigkeits-App (SwiftUI, iOS 18, nur iPhone, nur Hochformat). Vollständiger Auftrag: `PLAN-Merko32.md`. Überblick für Menschen: `README.txt`.

## Regeln
- **Dateien nie verschieben oder umbenennen** (auch nicht `ContentView.swift` / `Merko32App.swift`). Falls nötig: dem Nutzer sagen, er macht es in Xcode.
- Neue Dateien direkt am Zielort anlegen. Die Ordner `Merko32/`, `Merko32Tests/`, `Merko32UITests/` sind synchronisierte Ordner, Xcode übernimmt sie automatisch.
- `project.pbxproj` **nicht** von Hand ändern. Ausnahme nur auf ausdrücklichen Wunsch, und dann erst, wenn Xcode geschlossen ist (`pgrep -x Xcode`).
- Taucht eine neue Datei in Xcode nicht auf: Bescheid sagen, keine Workarounds bauen.
- Oberfläche und Kommentare auf **Deutsch**, Code-Bezeichner auf **Englisch**.
- Nach jeder Änderung: bauen und testen. Ist alles grün, **selbst committen** (Nachricht „Schritt N: …“ bzw. kurz beschreibend), **nicht pushen**.

## Befehle
```sh
# Alle Tests – den Startup-Performance-Test immer überspringen (dauert ca. 32 s)
xcodebuild test -scheme Merko32 -destination 'platform=iOS Simulator,name=iPhone 17' \
  -skip-testing:Merko32UITests/Merko32UITests/testLaunchPerformance

# Kompletter Durchlauf als UI-Test (ca. 1 min, nur bei Bedarf)
TEST_RUNNER_FULL_RUN=1 xcodebuild test -scheme Merko32 -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:Merko32UITests/GameFlowUITests/testFullRunEndsInResult
```
- Screenshots aus UI-Tests: mit `-resultBundlePath build/x.xcresult` laufen lassen, dann `xcrun xcresulttool export attachments --path build/x.xcresult --output-path <scratchpad>`. `build/` steht in `.gitignore`.
- DEBUG-Config mit 3 s pro Bildschirm: App mit dem Startargument `-debugTimes` starten (das tun die UI-Tests).

## Architektur
- `Model/` und `Logic/`: nur Foundation. **Alle Typen sind `nonisolated`**, weil das App-Target `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` nutzt, das Test-Target aber nicht.
- `Session/GameSession`: `@Observable @MainActor`. Kennt keine echte Zeit, `tick()` wird vom injizierten `Ticker` aufgerufen. `GameSessionTests` nutzen `ManualTicker` und sind `@MainActor`.
- `RunGenerator.make(config:using:)` ist eine reine Funktion. Tests verwenden `SeededGenerator` (SplitMix64), der über 1000 Seeds läuft.
- Alle Spielparameter stehen in `GameConfig.standard`. Bei Änderungen muss `validate()` leer bleiben (`GameConfigTests`).
- Summe der Bildschirmzeiten = 314 s (nicht 300).
- `ContentView` ist die RootView (der Name bleibt wegen der Template-Datei) und schaltet nach `session.phase` um.

## Offene Ideen
Liste möglicher Anpassungen nach den ersten Tests: `PLAN-Merko32.md`, Abschnitt „Mögliche Anpassungen nach den ersten Tests“. Nichts davon ist umgesetzt. Nur umsetzen, wenn der Nutzer es ausdrücklich will.
