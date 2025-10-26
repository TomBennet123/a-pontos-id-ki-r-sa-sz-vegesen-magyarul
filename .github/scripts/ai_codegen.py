#!/usr/bin/env python3
import argparse, os, json, pathlib, sys
from openai import OpenAI

PROMPT_SYSTEM = """Te egy kódgeneráló asszisztens vagy. 
Feladat: a megadott specifikáció alapján hozz létre *konkrét fájlokat* egy iOS (Swift/SwiftUI) apphoz.
Adj vissza *csak* egy JSON-t a következő séma szerint:
{
  "files": [
    {"path": "App/AI/Offline/OfflineAICoach.swift", "content": "<swift source>"},
    {"path": "App/Models/Workout.swift", "content": "<swift source>"}
  ],
  "notes": "Rövid megjegyzések"
}
A kód legyen futtatható, importokkal együtt. Ne adj magyarázó szöveget a JSON-on kívül.
"""

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--spec", required=True)
    ap.add_argument("--outdir", required=True)
    args = ap.parse_args()

    client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
    # Responses API hívás (ajánlott, naprakész végpont) – JSON struktúrált kimenethez ideális. 
    # Lásd: Responses API, Structured outputs. 
    response = client.responses.create(
        model="gpt-5",  # vagy más, projektedben engedélyezett modell
        reasoning={"effort": "medium"},
        input=[
            {"role":"system", "content": PROMPT_SYSTEM},
            {"role":"user", "content": f"Specifikáció:\n{args.spec}\n\nAdj vissza a fenti JSON sémát követő választ."}
        ],
        # Ha szigorúan JSON-t kérsz:
        response_format={"type":"json_object"}
    )

    # A válasz első output_item-je JSON stringet ad vissza
    out_text = response.output[0].content[0].text
    try:
        obj = json.loads(out_text)
    except Exception as e:
        print("Nem JSON választ kaptunk az API-tól:", e, file=sys.stderr)
        print(out_text)
        sys.exit(1)

    outdir = pathlib.Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    files = obj.get("files", [])
    for f in files:
        path = outdir / f["path"]
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(f["content"], encoding="utf-8")
        print(f"Wrote {path}")

    notes = obj.get("notes", "")
    (outdir / "AI_NOTES.txt").write_text(notes, encoding="utf-8")

if __name__ == "__main__":
    main()
