import datetime

def szam_to_betu(szam):
    betuk = ["nulla", "egy", "kettő", "három", "négy", "öt", "hat", "hét", "nyolc", "kilenc", "tíz", "tizenegy", "tizenkettő"]
    if szam <= 12:
        return betuk[szam]
    else:
        return betuk[szam-12]

def ora_perc_string(dt):
    hour = dt.hour
    minute = dt.minute
    
    if minute == 0:
        return f"{szam_to_betu(hour)} óra"
    
    if minute <= 10:
        return f"{szam_to_betu(hour)} óra {szam_to_betu(minute)}"
    
    if minute <= 14:
        return f"{szam_to_betu(15-minute)} perc múlva negyed {szam_to_betu(hour+1)}"
    
    if minute == 15:
        return f"negyed {szam_to_betu(hour+1)}"
    
    if minute <= 20:
        return f"negyed {szam_to_betu(hour+1)} múlt {szam_to_betu(minute-15)} perccel"
    
    if minute <= 29:
        return f"{szam_to_betu(30-minute)} perc múlva fél {szam_to_betu(hour+1)}"
    
    if minute == 30:
        return f"fél {szam_to_betu(hour+1)}"
    
    if minute <= 39:
        return f"fél {szam_to_betu(hour+1)} múlt {szam_to_betu(minute-30)} perccel"
    
    if minute <= 44:
        return f"{szam_to_betu(45-minute)} perc múlva háromnegyed {szam_to_betu(hour+1)}"
    
    if minute == 45:
        return f"háromnegyed {szam_to_betu(hour+1)}"
    
    if minute <= 49:
        return f"háromnegyed {szam_to_betu(hour+1)} múlt {szam_to_betu(minute-45)} perccel"
    
    return f"{szam_to_betu(60-minute)} perc múlva {szam_to_betu(hour+1)}"

now = datetime.datetime.now()
#desired_time = datetime.datetime(now.year, now.month, now.day, 12, 0)  # kívánt idő
#now = desired_time  # now változó beállítása a kívánt időre

ido_szoveg = ora_perc_string(now)
print(ido_szoveg)
