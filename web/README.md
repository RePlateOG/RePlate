# RePlate — Web Preview (for Windows / browser)

The real RePlate app is a **native iOS app (SwiftUI)** and can only be built/run with
**Xcode on a Mac**. It cannot run on Windows or in a browser.

This `web/` folder is a **visual preview only** — a browser recreation of the customer
screens (Home, Search, Orders, Messages, Profile) using the same brand colors
(`Theme.swift`) and the same sample data (`MockData.swift`). It is **not** the real app and
shares no code with it. It exists so you can see the look & feel on a Windows PC.

## Run it locally

From this `web/` folder:

```powershell
# Option A — Python (already installed)
python -m http.server 5173

# Option B — Node
npx serve -l 5173
```

Then open: **http://localhost:5173**

## Keeping in sync with the real app

This preview is hand-maintained. When the iOS UI changes meaningfully, update the
`screens`, design tokens, and mock data in `index.html` to match.
