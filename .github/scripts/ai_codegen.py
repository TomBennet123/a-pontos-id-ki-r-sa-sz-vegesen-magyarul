import os
import re
import subprocess
import json
from openai import OpenAI

# --- Konfiguráció ---
TRIGGER_PHRASE = "/generate"
# Alkatalógus, ahova a generált fájlok kerülnek
OUTPUT_DIR = "generated_code" 
# ---

def get_env_vars():
    """Beolvassa a szükséges környezeti változókat."""
    api_key = os.environ.get("OPENAI_API_KEY")
    token = os.environ.get("GH_TOKEN")
    repo = os.environ.get("REPO_NAME")
    issue_num = os.environ.get("ISSUE_NUMBER")
    comment_body = os.environ.get("COMMENT_BODY")

    if not all([api_key, token, repo, issue_num, comment_body]):
        print("Error: Hiányzó környezeti változók (API_KEY, TOKEN, REPO, ISSUE_NUM, COMMENT_BODY).")
        exit(1)
    return api_key, token, repo, issue_num, comment_body

def extract_prompt(comment_body):
    """Kinyeri a promptot a komment szövegéből, a trigger-szó utáni részt."""
    if TRIGGER_PHRASE not in comment_body:
        return None
    
    # A prompt minden, ami a trigger-szó első előfordulása után van
    prompt = comment_body.split(TRIGGER_PHRASE, 1)[1].strip()
    
    # Esetleges Markdown idézetjelek eltávolítása
    prompt = re.sub(r"^> ?", "", prompt, flags=re.MULTILINE).strip()
    return prompt

def call_openai_api(api_key, prompt):
    """Meghívja az OpenAI API-t a megadott prompttal."""
    print("Csatlakozás az OpenAI API-hoz...")
    client = OpenAI(api_key=api_key)
    
    system_prompt = (
        "Te egy szakértő kód generátor vagy. A felhasználó specifikációt ad meg. "
        "Kizárólag a kóddal válaszolj, pontosan az alábbi formátumban, "
        "mindenféle bevezető vagy befejező szöveg nélkül:\n\n"
        "FILENAME: path/to/your/file.py\n"
        "```python\n"
        "# A kódod a file.py számára\n"
        "```\n\n"
        "FILENAME: path/to/another.txt\n"
        "```\n"
        "Tartalom az another.txt számára\n"
        "```\n"
    )

    try:
        response = client.chat.completions.create(
            model="gpt-4o",  # Javasolt egy modern modellt használni
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ]
        )
        return response.choices[0].message.content
    except Exception as e:
        print(f"Hiba az OpenAI API hívása közben: {e}")
        return None

def parse_and_write_files(ai_response, base_dir):
    """Feldolgozza az AI válaszát és fájlokba írja a 'base_dir' alá."""
    print("AI válasz feldolgozása és fájlok írása...")
    if os.path.exists(base_dir):
        # Töröljük a korábbi generált fájlokat, ha léteznek
        import shutil
        shutil.rmtree(base_dir)
    
    # Regex, ami megtalálja a "FILENAME: " és a kódblokk-párosokat
    file_blocks = re.split(r"FILENAME: (.+)", ai_response, flags=re.MULTILINE)[1:]
    
    if not file_blocks:
        print("Hiba: Nem található 'FILENAME:' blokk az AI válaszában. Leállás.")
        print("--- AI Válasz ---")
        print(ai_response)
        print("-------------------")
        return False

    files_created = 0
    for i in range(0, len(file_blocks), 2):
        filepath_raw = file_blocks[i].strip()
        # A kódblokk tartalmának kinyerése (figyelembe véve a nyelvjelölőt)
        content_match = re.search(r"```[\s\S]*?\n([\s\S]*?)```", file_blocks[i+1], re.DOTALL)
        
        if content_match:
            content = content_match.group(1)
            # Teljes elérési út létrehozása a 'base_dir' alatt
            full_path = os.path.join(base_dir, filepath_raw)
            # Könyvtár létrehozása, ha nem létezik
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            
            with open(full_path, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"Fájl sikeresen írva: {full_path}")
            files_created += 1
        else:
            print(f"Figyelmeztetés: Nem sikerült feldolgozni a kódblokkot ehhez: {filepath_raw}")
    
    return files_created > 0

def run_subprocess(command, env=None):
    """Segédfüggvény shell parancsok futtatásához és naplózásához."""
    print(f"Parancs futtatása: {' '.join(command)}")
    try:
        # UTF-8 kódolás explicit beállítása a kimenethez
        result = subprocess.run(command, check=True, capture_output=True, text=True, encoding='utf-8', env=env)
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Hiba a parancs futtatása közben: {e}")
        print("STDOUT:", e.stdout)
        print("STDERR:", e.stderr)
        return False

def create_git_pr(issue_num, token, repo):
    """Létrehoz egy új ágat, commitol, pushol és PR-t nyit."""
    print("Git műveletek indítása...")
    branch_name = f"ai-gen/issue-{issue_num}"
    pr_title = f"AI által generált kód a #{issue_num} issue alapján"
    pr_body = (
        f"Ezt a PR-t az AI automatikusan generálta a #{issue_num} issue-hoz írt komment alapján.\n\n"
        "Kérlek, nézd át a változtatásokat."
    )
    
    # Git felhasználó beállítása
    if not run_subprocess(["git", "config", "user.name", "github-actions[bot]"]): return
    if not run_subprocess(["git", "config", "user.email", "github-actions[bot]@users.noreply.github.com"]): return

    # Új branch létrehozása (vagy váltás, ha már létezik)
    run_subprocess(["git", "checkout", "-b", branch_name])
    
    # Fájlok hozzáadása, commit és push (force push, hogy felülírja a korábbi próbálkozást)
    if not run_subprocess(["git", "add", OUTPUT_DIR]): return
    # Csak akkor commitoljunk, ha van változás
    if subprocess.run(["git", "diff", "--staged", "--quiet"]).returncode != 0:
        if not run_subprocess(["git", "commit", "-m", f"AI-generált kód a #{issue_num} issue-hoz"]): return
        if not run_subprocess(["git", "push", "origin", branch_name, "--force"]): return
    else:
        print("Nincs változás a legutóbbi commit óta. Lehet, hogy a PR már naprakész.")

    # PR létrehozása a GitHub CLI (gh) segítségével
    # A tokent a környezeti változóban adjuk át
    pr_env = os.environ.copy()
    pr_env["GH_TOKEN"] = token
    
    # Ellenőrizzük, létezik-e már PR ehhez az ághoz
    pr_list_command = [
        "gh", "pr", "list",
        "--repo", repo,
        "--head", branch_name,
        "--json", "number"
    ]
    try:
        result = subprocess.run(pr_list_command, check=True, capture_output=True, text=True, env=pr_env)
        existing_prs = json.loads(result.stdout)
        if existing_prs:
            print(f"Már létezik PR ehhez az ághoz ({branch_name}). Nem hozok létre újat.")
            return
    except Exception as e:
        print(f"Hiba a létező PR-ek ellenőrzésekor: {e}")
        # Folytatjuk, legfeljebb a 'gh pr create' fog hibát dobni

    pr_command = [
        "gh", "pr", "create",
        "--repo", repo,
        "--base", "main",  # Feltételezve, hogy 'main' a fő ág
        "--head", branch_name,
        "--title", pr_title,
        "--body", pr_body
    ]
    
    if not run_subprocess(pr_command, env=pr_env):
        print("Nem sikerült létrehozni a Pull Requestet.")

def main():
    api_key, token, repo, issue_num, comment_body = get_env_vars()
    
    prompt = extract_prompt(comment_body)
    if not prompt:
        print(f"A komment nem tartalmazza a '{TRIGGER_PHRASE}' triggert vagy a prompt üres.")
        return

    ai_response = call_openai_api(api_key, prompt)
    if not ai_response:
        return

    if not parse_and_write_files(ai_response, OUTPUT_DIR):
        print("Nem sikerült a fájlok írása vagy feldolgozása. Git műveletek megszakítva.")
        return

    create_git_pr(issue_num, token, repo)
    print("Folyamat sikeresen befejezve.")

if __name__ == "__main__":
    main()
