# Gym – Offline edzésnapló és AI edző iOS-re

A Gym egy SwiftUI-alapú, teljesen offline működő edzésnapló és AI edző. A projekt moduláris felépítésben tartalmazza a fő alkalmazást, a tartományi réteget, a perzisztenciát, az AI modult és a watchOS kísérő alkalmazást.

## Fő funkciók
- **Edzésnaplózás**: Gyakorlatok, szettek, súlyok és RPE értékek rögzítése, sablonok kezelése.
- **Haladás-követés**: Összesített volumen, izomcsoport eloszlások és testsúly trendek számítása.
- **AI Edző**: Lokális elemzések és nyelvi generálás a személyre szabott visszajelzésekhez.
- **watchOS támogatás**: Pulzuskövetés és edzésindítás közvetlenül az óráról.

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
