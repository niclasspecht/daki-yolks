#!/bin/bash
# Startet alle LAUFENDEN Server neu, deren Image mit IMAGE_PREFIX beginnt.
# Gestoppte Server bleiben aus und holen das neue Image beim nächsten Start selbst.
#
#   PANEL_URL=https://panel.example.com API_KEY=ptlc_... ./restart-servers.sh          # nur anzeigen
#   PANEL_URL=https://panel.example.com API_KEY=ptlc_... DRY_RUN=0 ./restart-servers.sh # wirklich neu starten
#
# API_KEY: Client-API-Key eines Root-Admins (Konto -> API Credentials).
# Benötigt: curl, jq
set -euo pipefail

: "${PANEL_URL:?PANEL_URL setzen}"
: "${API_KEY:?API_KEY setzen}"
IMAGE_PREFIX="${IMAGE_PREFIX:-ghcr.io/niclasspecht/daki-yolks:}"
DRY_RUN="${DRY_RUN:-1}"
DELAY="${DELAY:-5}"

api() {
  curl -fsS -H "Authorization: Bearer $API_KEY" -H "Accept: application/json" \
    -H "Content-Type: application/json" "$@"
}

page=1
servers=()
while :; do
  resp=$(api "$PANEL_URL/api/client?type=admin-all&per_page=100&page=$page")
  while IFS=$'\t' read -r id name image; do
    [[ "$image" == "$IMAGE_PREFIX"* ]] && servers+=("$id"$'\t'"$name"$'\t'"$image")
  done < <(jq -r '.data[].attributes | select(.is_suspended | not) | [.identifier, .name, .docker_image] | @tsv' <<< "$resp")
  total=$(jq -r '.meta.pagination.total_pages' <<< "$resp")
  (( page >= total )) && break
  page=$((page + 1))
done

echo "${#servers[@]} Server mit $IMAGE_PREFIX*"
for entry in "${servers[@]}"; do
  IFS=$'\t' read -r id name image <<< "$entry"
  state=$(api "$PANEL_URL/api/client/servers/$id/resources" | jq -r '.attributes.current_state')
  if [[ "$state" != "running" ]]; then
    echo "skip    $id  $name  ($state)"
    continue
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "würde   $id  $name  ($image)"
  else
    api -X POST "$PANEL_URL/api/client/servers/$id/power" -d '{"signal":"restart"}' >/dev/null
    echo "restart $id  $name  ($image)"
    sleep "$DELAY"
  fi
done
