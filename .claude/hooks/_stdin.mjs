// Shared helper: read all of stdin as a string (resolves '' when run interactively).
export function readStdin() {
  return new Promise((resolve) => {
    if (process.stdin.isTTY) return resolve("");
    let data = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (c) => (data += c));
    process.stdin.on("end", () => resolve(data));
    process.stdin.on("error", () => resolve(""));
  });
}

export function parse(raw) {
  try { return JSON.parse(raw); } catch { return null; }
}
