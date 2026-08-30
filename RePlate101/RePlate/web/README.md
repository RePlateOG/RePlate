# RePlate — Web Preview (for Windows / browser)

The real RePlate app is a **native iOS app (SwiftUI)** and can only be built/run with
**Xcode on a Mac**. It cannot run on Windows or in a browser.

This `web/` folder is a **visual preview only** — a browser recreation of the customer
screens (Home, Search, Orders, Messages, Profile) using the same brand colors
(`Theme.swift`) and the same sample data (`MockData.swift`). It is **not** the real app and
shares no code with it. It exists so you can see the look & feel on a Windows PC.

## How to open it (with the latest changes)

This is ONE self-contained file (no server, no internet needed). To see the
newest version after someone pushes changes:

```bash
git pull          # get the latest changes
```

Then just **double-click `web/index.html`** — it opens in your browser and
shows the app with all the latest changes. Repeat `git pull` + reopen anytime.

### Optional: run it on a local web address instead

If you prefer a `http://localhost` link, run one of these from this `web/` folder:

```bash
python -m http.server 5173     # then open http://localhost:5173
# or
npx serve -l 5173
```

## Keeping in sync with the real app

This preview is hand-maintained. When the iOS UI changes meaningfully, update the
`screens`, design tokens, and mock data in `index.html` to match.
