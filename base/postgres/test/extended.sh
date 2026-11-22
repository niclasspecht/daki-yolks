#!/bin/bash
# Extended test for the PostgreSQL image, run by CI after the smoke test.
# Starts the image with the same container settings Wings uses (non-root UID, read-only
# root filesystem with tmpfs /tmp, TTY on stdin, no-new-privileges, dropped capabilities,
# volume at /home/container, STARTUP) and checks the egg's behaviour end to end.
# Usage: base/postgres/test/extended.sh <image>   (needs docker, script and sudo, e.g. a GitHub runner)
set -euo pipefail

IMG=$1
RUN_AS=${RUN_AS:-999:989}
PORT=25432
NAME=pgtest-$$
WORK=$(mktemp -d)
VOL=$WORK/vol
FIFO=$WORK/stdin
# Test-only passwords
PW1=test-password-one-1
PW2=test-password-two-2

logs() { docker logs "$NAME" 2>&1 | tr -d '\r'; }
fail() { echo "::error::$*"; logs | tail -n 40 || true; exit 1; }
ok() { echo "ok: $*"; }

cleanup() {
    exec 4>&- 2>/dev/null || true
    docker rm -f "$NAME" >/dev/null 2>&1 || true
    sudo rm -rf "$WORK"
}
trap cleanup EXIT

new_volume() {
    sudo rm -rf "$VOL"
    mkdir -p "$VOL"
    sudo chown "$RUN_AS" "$VOL"
}

# Start the container like Wings. `script` provides the TTY; its stdin is a FIFO so the
# test can type into the console like the panel does.
start() { # <password>
    docker rm -f "$NAME" >/dev/null 2>&1 || true
    rm -f "$FIFO"
    mkfifo "$FIFO"
    local cmd
    cmd=$(printf '%q ' docker run -it --name "$NAME" --user "$RUN_AS" \
        --read-only --tmpfs /tmp:rw,exec,nosuid,size=100M \
        --security-opt no-new-privileges \
        --cap-drop setpcap --cap-drop mknod --cap-drop audit_write --cap-drop net_raw \
        --cap-drop dac_override --cap-drop fowner --cap-drop fsetid --cap-drop net_bind_service \
        --cap-drop sys_chroot --cap-drop setfcap --cap-drop sys_ptrace \
        -v "$VOL":/home/container -p 127.0.0.1:$PORT:$PORT \
        -e STARTUP=daki-postgres -e SERVER_PORT=$PORT -e PGUSER=postgres -e PGPASSWORD="$1" \
        "$IMG")
    script -qfec "$cmd" /dev/null <"$FIFO" >/dev/null 2>&1 &
    exec 4>"$FIFO"
}

wait_log() { # <text> [seconds]
    local i
    for i in $(seq 1 "${2:-60}"); do
        logs | grep -qF -- "$1" && return 0
        sleep 1
    done
    return 1
}

wait_exit() { # [seconds]
    local i
    for i in $(seq 1 "${1:-30}"); do
        [ "$(docker inspect -f '{{.State.Running}}' "$NAME" 2>/dev/null)" = "false" ] && return 0
        sleep 1
    done
    return 1
}

# Client from the official image, so the checks do not depend on the image under test.
sql() { # <password> <query>
    docker run --rm --network host -e PGPASSWORD="$1" postgres:18-alpine \
        psql -h 127.0.0.1 -p $PORT -U postgres -d postgres -tAc "$2" 2>/dev/null
}
login() { sql "$1" 'select 1' >/dev/null; }

docker pull -q postgres:18-alpine >/dev/null

# 1. First start with a password from the Startup tab
new_volume
start "$PW1"
wait_log "is ready on port" || fail "first start"
logs | grep -qF "database system is ready to accept connections" || fail "done string missing"
login "$PW1" || fail "login with PW1"
login wrong-password-123 && fail "wrong password accepted"
ok "first start, password login, wrong password rejected"

# 2. Console input reaches psql
echo "CREATE TABLE console_test(id int);" >&4
sleep 2
sql "$PW1" "select to_regclass('console_test')" | grep -q console_test || fail "console input does not reach psql"
ok "console input reaches psql"

# 3. "\q" (the egg's stop command) shuts down cleanly
echo '\q' >&4
wait_exit 30 || fail "server did not stop on \\q"
logs | grep -qF "database system is shut down" || fail "no clean shutdown on \\q"
ok "stop via \\q is clean"

# 4. Changing the password in the Startup tab: new one works, old one does not
start "$PW2"
wait_log "Superuser password from the Startup tab is active" || fail "password change"
login "$PW2" || fail "login with PW2"
login "$PW1" && fail "old password still works"
ok "password change via Startup tab"

# 5. SIGTERM (docker stop, node reboot) shuts down cleanly
docker stop -t 30 "$NAME" >/dev/null
logs | grep -qF "database system is shut down" || fail "no clean shutdown on SIGTERM"
ok "SIGTERM shutdown is clean"

# 6. An empty password later keeps the current one
start ""
wait_log "is ready on port" || fail "start with empty password"
login "$PW2" || fail "PW2 lost after empty password"
echo '\q' >&4; wait_exit 30 || fail "stop"
ok "empty password keeps the current one"

# 7. Data directories from the ptero-eggs egg (local md5 in pg_hba) still start
sudo sed -i -E 's/^(local[[:space:]]+all[[:space:]]+all[[:space:]]+)trust/\1md5/' "$VOL/postgres_db/pg_hba.conf"
sudo sed -i '/^# Console access via/d' "$VOL/postgres_db/pg_hba.conf"
start "$PW1"
wait_log "Superuser password from the Startup tab is active" || fail "ptero-eggs data directory"
login "$PW1" || fail "login after switching from the ptero-eggs egg"
echo '\q' >&4; wait_exit 30 || fail "stop"
ok "data directory from the ptero-eggs egg works"

# 8. Wrong major version: clear message, data untouched
real=$(sudo cat "$VOL/postgres_db/PG_VERSION")
echo 99 | sudo tee "$VOL/postgres_db/PG_VERSION" >/dev/null
start "$PW1"
wait_exit 60 || fail "wrong major version did not exit"
logs | grep -qF "but this image runs PostgreSQL" || fail "no version mismatch message"
echo "$real" | sudo tee "$VOL/postgres_db/PG_VERSION" >/dev/null
start "$PW1"
wait_log "is ready on port" || fail "start after version mismatch"
login "$PW1" || fail "data lost after version mismatch"
echo '\q' >&4; wait_exit 30 || fail "stop"
ok "version mismatch is detected, data untouched"

# 9. Fresh start without a password: random password in the console
new_volume
start ""
wait_log "is ready on port" || fail "fresh start without password"
GEN=$(logs | sed -n 's/^\[daki\] Generated superuser password: //p')
[ -n "$GEN" ] || fail "no generated password"
login "$GEN" || fail "login with generated password"
echo '\q' >&4; wait_exit 30 || fail "stop"
ok "random password on first start"

echo "all tests passed ($IMG)"
