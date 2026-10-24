// Runs inside the built image under xvfb-run, the way a customer bot would use Playwright.
// Launches every browser headless (render Latin, CJK and emoji text, take a screenshot)
// plus Chromium headed on the virtual display (render only: without a GPU, headed
// Chromium on Xvfb cannot capture screenshots).
import { chromium, firefox } from "playwright";

const runs = [
  [chromium, { headless: true }],
  [firefox, { headless: true }],
  [chromium, { headless: false }],
];

for (const [type, options] of runs) {
  const label = `${type.name()} (${options.headless ? "headless" : "headed"})`;
  const browser = await type.launch(options);
  const version = browser.version();
  const page = await browser.newPage();
  await page.setContent("<h1>Daki ✓ 日本語 한국어 😀</h1>");
  const text = await page.textContent("h1");
  const shot = options.headless ? await page.screenshot() : null;
  await browser.close();
  if (!text?.includes("Daki") || (shot && shot.length < 1000)) {
    console.error(`${label} rendered nothing`);
    process.exit(1);
  }
  console.log(`${label} ${version} ok`);
}

console.log(`smoke ok: node ${process.version}, ${runs.length} browser runs`);
