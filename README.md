# CursorCraft

A Firefox extension that wipes any web page to a blank canvas and lets a swarm of multiplayer cursors build it back, live: crosshair-drawn boxes, typed text, pen-tool lines, ruler guides and ⌥-drag duplicates, until the page looks just like it did before.

![CursorCraft rebuilding a page](media/demo.gif)

[Full demo video (36s)](media/demo.mp4) · [Demo with sound (60s)](media/demo-with-sound.mp4)

## Credit

This is an unofficial Firefox port and tribute to **[Swarm](https://califa.github.io/swarm-site/)** by **[Joel Califa](https://joelcalifa.com)** ([@califa](https://github.com/califa), [source](https://github.com/califa/swarm-site)) and the Chromium extension **[Swarm Rebuild](https://github.com/DhvanilPatel/swarm-cursors)** by **[Dhvanil Patel](https://github.com/DhvanilPatel)**.

The motion design is Joel Califa's: the cursor set, the swarm and flocking physics, the build choreography (rects, typing, guides, duplicates), the rulers and the overall look. Dhvanil Patel adapted it into a Chrome extension to snapshot live DOM trees with synthesized audio. What this project adds is porting it to Firefox and Gecko-based browsers (Zen Browser, LibreWolf, Floorp), adapting it to Firefox's Manifest V3 architecture, and fixing Gecko sub-pixel text and SVG jitter during scrolling.

Go look at the originals. They are better than this.

## Install

To run the extension locally:

1. Clone or download this repo.
2. Open `about:debugging#/runtime/this-firefox` in Firefox or Zen Browser.
3. Click **Load Temporary Add-on...** and choose the [`src/manifest.json`](src/manifest.json) file.
4. Pin it to your toolbar.

## Use

- Click the toolbar icon or press **Alt+Shift+S** on any page (shortcuts can be customized in `about:addons` → gear icon → **Manage Extension Shortcuts**).
- The page fades out and the cursors orbit the site's favicon, then fan out and start building.
- **Scroll** and the swarm chases you, with more agents joining the faster you go.
- **Tour** auto-scrolls at the pace the swarm can keep up with. Good for screen recordings.
- **1× / 2× / 3×** changes build speed.
- **Sound** is on by default (speaker icon in the toolbar, or press **M**). If the page hasn't been clicked yet, the browser keeps audio locked and the button says **Tap for sound**; one click anywhere starts it.
- When it's done, the cursors flock to your mouse. **Go live** fades back to the real, clickable page; **Replay** builds it again.
- **Esc**, **X**, or clicking the icon again exits at any time.

There's a self-contained test page in [`demo/index.html`](demo/index.html) (an inner-scrolling app shell with floats, forms, cards and media). Opening local files needs permission to access file URLs enabled for the extension.

## How it works

1. **Snapshot.** [`src/swarm.js`](src/swarm.js) walks the live DOM, including open shadow roots, and turns it into a blueprint:
   - boxes with fills, borders, radii, shadows, gradients, masks and backdrop blur → **rects**
   - text blocks → **text layers**, cloned with their computed styles (fonts, links, inline code, icons, `::before`/`::after`)
   - single-side borders and `<hr>` → **pen-tool lines**
   - `<img>`, `<picture>`, `<svg>`, `<video>`, `<canvas>`, iframes → **media**. WebGL canvases, playing video and cross-origin iframes are cropped from a screenshot taken at click time while only those elements are visible.
   - repeated siblings (nav links, cards, list rows, logos) → one **master** plus **duplicates**
   - shared left edges and baselines → **ruler guides** that text snaps to
2. **Blank.** A full-viewport layer, isolated from the page's CSS in a shadow root, covers the page with its own background color. A quick hidden scroll pass first triggers lazy images and reveal-on-scroll content.
3. **Rebuild.** Each cursor runs a small generator script per task. Tasks unlock top-down as you scroll, children wait for their parent box, and duplicates wait for their master:
   - **rect / media:** crosshair drag with a live `W × H` badge and a gray placeholder, then the real fill fades in (images sweep top to bottom)
   - **text:** drag a text box, type with an I-beam and a blinking caret; big headings start at 18px and step up
   - **lines:** pen tool, anchor points, rubber band to the cursor
   - **guides:** Figma-style rulers slide in, a red guide is dragged out, and text snaps onto it
   - **duplicates:** select the master, ⌥-drag a copy with red spacing measurements, then retype its text, swap its image or restyle it
   - **swarm physics:** orbiting, alignment and mouse-avoiding flocking for the intro and the finale
4. **Sound.** Synthesized live with the Web Audio API (no audio files), mostly clicky, a little musical:
   - typing is a mechanical keyboard (a sharp click over a short thock, deeper on spaces), and every mouse press is a press-and-release click
   - guides snap with a crisp click, and growing headings tick up in pitch
   - boxes, images and duplicates add a sparse, quiet glass-piano note from the E major pentatonic, on an eighth-note grid: big sections play low, small things high, pitch rises left to right, and every sound is panned to its cursor
   - an airy swell as the page dissolves, a short arpeggio as the swarm fans out, a soft E major chord when the page is done, and a falling sweep for Go live

### Files

| Path | What it is |
| --- | --- |
| `src/manifest.json` | Manifest V3; permissions are `activeTab` and `scripting` only |
| `src/background.js` | Toolbar click → media-only screenshot → inject `swarm.js` (or toggle off) |
| `src/swarm.js` | Snapshot, renderer and swarm engine (one dependency-free content script) |
| `demo/index.html` | Edge-case test page |
| `scripts/package.sh` | Builds the zip and xpi to upload to Firefox Add-ons |

## Limits

- Firefox doesn't let extensions run on `about:` pages, the Add-ons site or the PDF viewer. The icon shows a red X there.
- It's a visual rebuild, not a clone. Animations freeze at the moment you click, decorative pseudo-elements are skipped when their position can't be worked out, and canvases, videos and iframes below the first screen become placeholders.
- Web components are rebuilt as plain styled elements, so none of the page's scripts run inside the swarm's layer.
- Very long pages are capped at about 4,000 layers / 40,000px.

## Publishing

When ready to submit to Mozilla Add-ons, `./scripts/package.sh` writes `dist/cursor-craft-<version>.zip` and `.xpi` for the [Firefox Add-on Developer Hub](https://addons.mozilla.org/developers/). The privacy policy is [`PRIVACY.md`](PRIVACY.md).

## Status & License

This is an open-source port published with permission from the original authors ([Joel Califa](https://joelcalifa.com) and [Dhvanil Patel](https://github.com/DhvanilPatel)).
