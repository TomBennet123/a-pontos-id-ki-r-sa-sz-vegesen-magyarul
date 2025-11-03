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
# Gym – Offline edzésnapló és AI edző iOS-re

A Gym egy SwiftUI-alapú, teljesen offline működő edzésnapló és AI edző. A projekt moduláris felépítésben tartalmazza a fő alkalmazást, a tartományi réteget, a perzisztenciát, az AI modult és a watchOS kísérő alkalmazást.

## Fő funkciók
- **Edzésnaplózás**: Gyakorlatok, szettek, súlyok és RPE értékek rögzítése, sablonok kezelése.
- **Haladás-követés**: Összesített volumen, izomcsoport eloszlások és testsúly trendek számítása.
- **AI Edző**: Lokális elemzések és nyelvi generálás a személyre szabott visszajelzésekhez.
- **watchOS támogatás**: Pulzuskövetés és edzésindítás közvetlenül az óráról.
- **Ajánlott gyakorlat**: Alapértelmezetten elérhető az „Egykezes mellnyomás fekve” leírással, videóval és animált demonstrációval.

## Modulok
- `Domain`: Entitások, érték objektumok és use case-ek.
- `Persistence`: GRDB-alapú SQLite perzisztencia, repository implementációk.
- `Health`: HealthKit integrációs kapu.
- `AICore`: Offline AI elemzés és nyelvi generálás.
- `App`: SwiftUI felhasználói felület és view modellek.
- `WatchApp`: watchOS workout session kezelése.
- `AppIntents`: Siri Shortcut / App Intent integráció.

## Fejlesztés
A projekt Swift Package Managerrel szervezett. A modulok Xcode-ban importálhatók, a `GymApp` cél SwiftUI alkalmazásként futtatható iOS 17+ rendszeren.

```bash
swift package resolve
```

A tesztek futtatása:

```bash
swift test
```

## Adatvédelem
Minden adat a készüléken, lokális SQLite adatbázisban tárolódik, nincs hálózati kommunikáció. Az opcionális ChatGPT integráció csak explicit konfiguráció után érhető el.
