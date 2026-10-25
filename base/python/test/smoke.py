# Runs inside the built image, the same way a customer bot would start.
import shutil
import sqlite3
import ssl
import sys
import venv  # noqa: F401

tools = ["git", "gcc", "g++", "curl", "dig", "ffmpeg", "ssh", "ps", "killall", "patch", "less", "ip"]
missing = [tool for tool in tools if shutil.which(tool) is None]
if missing:
    sys.exit(f"missing tools: {' '.join(missing)}")
print(f"smoke ok: python {sys.version.split()[0]}, {ssl.OPENSSL_VERSION}, sqlite {sqlite3.sqlite_version}, {len(tools)} tools")
