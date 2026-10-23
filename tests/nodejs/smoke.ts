// Runs inside the built image via ts-node, the same way a customer bot would start.
import { execSync } from "node:child_process";

const tools: string[] = ["git", "ffmpeg", "sqlite3", "python3", "gcc", "g++", "make", "curl", "dig", "ping", "zip", "tar", "ip"];
const missing = tools.filter((tool) => {
  try {
    execSync(`command -v ${tool}`, { stdio: "ignore", shell: "/bin/bash" });
    return false;
  } catch {
    return true;
  }
});

if (missing.length > 0) {
  console.error(`missing tools: ${missing.join(" ")}`);
  process.exit(1);
}
console.log(`smoke ok: node ${process.version}, ${tools.length} tools`);
