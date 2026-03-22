import { execSync } from "node:child_process";

let cachedHostIp = null;

export function getHostIp() {
  if (!cachedHostIp) {
    try {
      const output = execSync("getent hosts host.containers.internal", {
        encoding: "utf8",
      });
      cachedHostIp = output.trim().split(/\s+/)[0];
    } catch {
      cachedHostIp = "host.containers.internal"; // fallback
    }
  }
  return cachedHostIp;
}

export function getBrowserUrl() {
  return `http://${getHostIp()}:9222`;
}
