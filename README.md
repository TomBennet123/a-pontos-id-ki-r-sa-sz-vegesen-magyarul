# Gym CLI

A Gym projekt egy minimális, offline módon futtatható edzésnapló, amely parancssori felületen keresztül teszi lehetővé az edzések rögzítését, a haladás elemzését és az AI edző javaslatainak megjelenítését. A kód Swift Package Managerrel építhető és futtatható.

## Követelmények

- Swift 5.9 vagy újabb
- macOS vagy Linux környezet, ahol elérhető a `swift` parancs

## Build és futtatás

```bash
swift build -c release
.build/release/gym
```

## Használat

```bash
.build/release/gym log "Mell edzés" 12000
.build/release/gym progress
.build/release/gym metrics 82.4
```

- `log` – gyorsan létrehoz egy fiktív edzésnaplót és visszaadja az AI edző motivációját, javaslatát.
- `progress` – kiírja a rögzített edzések súly- és volumenstatisztikáit, valamint az izomcsoportok megoszlását.
- `metrics` – testsúly adatot rögzít és átlagot számít.

A példa implementáció egyszerű in-memory tárolót használ. A projekt alkalmas arra, hogy további adatbázis- vagy UI-réteggel bővítsd, illetve iOS/watchOS alkalmazássá fejleszd.
