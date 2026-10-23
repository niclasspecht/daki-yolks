# daki-yolks

Eigene Pterodactyl-Images für Node.js und Python, basierend auf [ptero-eggs/yolks](https://github.com/ptero-eggs/yolks) (MIT).
Die Images werden automatisch neu gebaut, sobald Docker Hub ein gepatchtes Basis-Image veröffentlicht.

| Image | Basis |
| --- | --- |
| `ghcr.io/niclasspecht/daki-yolks:nodejs_22` / `_24` / `_26` | `node:<v>-trixie-slim` |
| `ghcr.io/niclasspecht/daki-yolks:python_3.11` … `_3.15` | `python:<v>-slim-trixie` |

Alle Images gibt es für `linux/amd64` und `linux/arm64`.

## Wann gebaut wird

| Auslöser | Verhalten |
| --- | --- |
| alle 6 Stunden | prüft pro Version den Digest des Basis-Images und baut nur, wenn er sich geändert hat (Security-Releases kommen so spätestens nach 6 h an) |
| Montag 03:17 UTC | baut alle Versionen neu, damit auch Debian-Paket-Updates ankommen |
| Push auf `main` in `nodejs/`, `python/` oder Workflows | baut alle Versionen der Sprache neu |
| Actions → Workflow → **Run workflow** | manuell, standardmäßig alle Versionen |

Vor jedem Push startet der Workflow das Image wie Wings (Nicht-Root-User, `STARTUP`-Variable) und bricht ab, wenn die erwartete Version nicht erscheint.

## Version hinzufügen oder entfernen

Version in `versions` in `.github/workflows/nodejs.yml` bzw. `python.yml` eintragen, committen, danach die Zeile im Egg ergänzen.
Beim Entfernen erst Egg und Server umstellen, dann die Version streichen. Das alte Image bleibt auf GHCR liegen, wird aber nicht mehr aktualisiert.

## Inhalt

- `nodejs/`, `python/`: Dockerfile mit Versions-Build-Arg und Entrypoint (muss LF-Zeilenenden haben, `.gitattributes` erzwingt das)
- `eggs/`: Eggs mit den neuen Images, zum Import im Panel (Egg öffnen → **Update Egg**)
- `scripts/migrate-images.sql`: stellt bestehende Server in der Panel-DB auf die neuen Images um
- `scripts/prepull.sh`: lädt alle Images auf einem Wings-Node vor
- `scripts/restart-servers.sh`: startet alle laufenden Server mit den neuen Images über die Client-API neu
