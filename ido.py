import datetime


SZAM_NEVES = {
    0: "nulla",
    1: "egy",
    2: "kettő",
    3: "három",
    4: "négy",
    5: "öt",
    6: "hat",
    7: "hét",
    8: "nyolc",
    9: "kilenc",
    10: "tíz",
    11: "tizenegy",
    12: "tizenkettő",
    13: "tizenhárom",
    14: "tizennégy",
    15: "tizenöt",
    16: "tizenhat",
    17: "tizenhét",
    18: "tizennyolc",
    19: "tizenkilenc",
    20: "húsz",
    21: "huszonegy",
    22: "huszonkettő",
    23: "huszonhárom",
    24: "huszonnégy",
    25: "huszonöt",
    26: "huszonhat",
    27: "huszonhét",
    28: "huszonnyolc",
    29: "huszonkilenc",
}


def szam_to_betu(szam: int) -> str:
    """Alakítsa át a számot szöveggé a magyar időmondatokhoz."""

    try:
        return SZAM_NEVES[szam]
    except KeyError as exc:  # pragma: no cover - programozási hiba esetén
        raise ValueError(f"Nincs definiálva név a(z) {szam} számhoz.") from exc


def ora_to_betu(hour: int) -> str:
    """Adja vissza az óra szöveges formáját (12 órás formátum)."""

    hour_mod = hour % 12
    if hour_mod == 0:
        hour_mod = 12
    return SZAM_NEVES[hour_mod]


def perc_to_betu(szam: int) -> str:
    """A percekhez illeszkedő alakot ad vissza (két perc, tizenkét perc, stb.)."""

    special_forms = {2: "két", 12: "tizenkét", 22: "huszonkét"}
    return special_forms.get(szam, szam_to_betu(szam))

def ora_perc_string(dt):
    hour = dt.hour
    minute = dt.minute

    if minute == 0:
        return f"{ora_to_betu(hour)} óra"

    if minute <= 10:
        return f"{ora_to_betu(hour)} óra {szam_to_betu(minute)}"

    if minute <= 14:
        return f"{perc_to_betu(15-minute)} perc múlva negyed {ora_to_betu(hour+1)}"

    if minute == 15:
        return f"negyed {ora_to_betu(hour+1)}"

    if minute <= 20:
        return f"negyed {ora_to_betu(hour+1)} múlt {perc_to_betu(minute-15)} perccel"

    if minute <= 29:
        return f"{perc_to_betu(30-minute)} perc múlva fél {ora_to_betu(hour+1)}"

    if minute == 30:
        return f"fél {ora_to_betu(hour+1)}"

    if minute <= 39:
        return f"fél {ora_to_betu(hour+1)} múlt {perc_to_betu(minute-30)} perccel"

    if minute <= 44:
        return f"{perc_to_betu(45-minute)} perc múlva háromnegyed {ora_to_betu(hour+1)}"

    if minute == 45:
        return f"háromnegyed {ora_to_betu(hour+1)}"

    if minute <= 49:
        return f"háromnegyed {ora_to_betu(hour+1)} múlt {perc_to_betu(minute-45)} perccel"

    return f"{perc_to_betu(60-minute)} perc múlva {ora_to_betu(hour+1)}"


def main() -> None:
    now = datetime.datetime.now()
    ido_szoveg = ora_perc_string(now)
    print(ido_szoveg)


if __name__ == "__main__":
    main()
