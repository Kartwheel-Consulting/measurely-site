# Measurely — marketing website

The public website for Measurely: home, nine live calculator demos, pricing,
FAQ, contact and privacy policy. Built with Flutter for the web and hosted on
Render as a static site.

It runs **alongside** the Shopify app. It does not touch the app, the app's
database, or Stove Glass Shop's install.

```
lib/
  main.dart               routes: / /calculators /calculators/<slug> /pricing /faq /contact /privacy
  config.dart             company details, support email, App Store link  ← edit before launch
  theme.dart              brand colours and type (same values as the app)
  pricing/pricing.dart    the app's pricing rule, ported line for line to Dart
  data/                   plans, calculators, features, FAQ — all copy lives here
  widgets/                header, footer, cards, the live calculator demo
  pages/                  one file per page
test/
  pricing_test.dart       the app's own pricing test cases — must match exactly
  pages_test.dart         renders every page at desktop and phone width
web/
  index.html              search-engine text, social preview tags, loading screen
render.yaml, build.sh     hosting
```

---

## 1. Before you publish — three edits

| File | What to change |
|---|---|
| `lib/config.dart` | `supportEmail` → a mailbox that exists and is monitored. Keep it identical to the app's. |
| `lib/config.dart` | `appStoreUrl` → the App Store listing URL, once approved. Until then every "Install" button reads **Request early access** and opens an email. |
| `lib/pages/info_pages.dart` | The privacy policy is written from what the app actually stores, but **have it reviewed** before you submit it to Shopify. |

If a price, limit or feature changes in the app's `app/plans.ts`, change
`lib/data/plans.dart` in the same commit. The site must never promise what
the app does not do.

---

## 2. Run it on your computer

### 2.1 Check Flutter is installed

```powershell
flutter --version
```

You need **Flutter 3.27 or newer**. Write down the exact version it prints — you
will need it in step 4.3.

If the command is not found:

1. Download the Windows zip from <https://docs.flutter.dev/get-started/install/windows/web>.
2. Extract it to `C:\dev\flutter` (not `Program Files` — it needs write access).
3. Add `C:\dev\flutter\bin` to your user `PATH`
   (Start → "Edit environment variables for your account" → Path → New).
4. Open a **new** PowerShell window and run `flutter doctor`. Only the
   **Chrome** line needs a tick for this project.

### 2.2 Get the packages, check, test

```powershell
cd E:\dev\measurely-site
flutter pub get
flutter analyze
flutter test
```

- `flutter analyze` should end with **No issues found!**
- `flutter test` should end with **All tests passed!**

If either fails, paste the output — do not deploy until both are clean.
`build.sh` runs the tests on Render too, so a failing test also stops a
broken deploy.

### 2.3 Preview in Chrome

```powershell
flutter run -d chrome
```

Check each page from the menu, open a calculator, change a size and a unit,
switch on tiered rates and quantity discounts, and resize the window down to
phone width. Press `q` in PowerShell to stop.

### 2.4 Production build (optional locally)

```powershell
flutter build web --release
```

The site is written to `build\web`. Render runs this for you in step 4.

---

## 3. Put it on GitHub

Use a **new, separate repository** — not the app's repo.

1. On GitHub: **New repository** → owner `Kartwheel-Consulting` → name
   `measurely-site` → Private → **do not** add a README or .gitignore → Create.
2. Then:

```powershell
cd E:\dev\measurely-site
git init -b main
git add -A
git status --short
git commit -m "Measurely marketing site"
git remote add origin https://github.com/Kartwheel-Consulting/measurely-site.git
git push -u origin main
```

`git status --short` should list `lib/`, `test/`, `web/`, `pubspec.yaml`,
`render.yaml`, `build.sh` and friends — and **no** `build/` or `.dart_tool/`
folders (the `.gitignore` excludes them).

---

## 3a. Temporary preview on GitHub Pages

For sharing a review link before the site goes on the company server.
`.github/workflows/deploy-pages.yml` builds and publishes on every push to
`main`, after the analyzer and tests pass.

1. The repository must be **public**, unless the GitHub organisation is on a
   paid plan (Pages on private repositories needs Team or Enterprise).
2. Repository → **Settings** → **Pages** → *Build and deployment* →
   **Source: GitHub Actions**.
3. Push to `main`, or run the workflow from the **Actions** tab.
4. Live at `https://<owner>.github.io/<repository>/` — for this project,
  `https://kartwheel-consulting.github.io/measurely-site/`.

The server hosting in section 4 builds with the normal base path (`/`); the
`--base-href` in the workflow applies to GitHub Pages only.

---

## 4. Host it on Render

The site is static: HTML, JavaScript and images, no server and no database.

### 4.1 Create it from the blueprint

1. Render dashboard → **New +** → **Blueprint**.
2. Connect the `Kartwheel-Consulting/measurely-site` repository.
3. Render reads `render.yaml` and shows one service: **measurely-site**, type
   *Static Site*. Click **Apply**.

### 4.2 What `render.yaml` sets up for you

- **Build:** `bash build.sh` — installs Flutter, runs the tests, builds.
- **Publish folder:** `build/web`.
- **Rewrite `/*` → `/index.html`:** lets `/pricing` or `/calculators/area`
  open directly and survive a browser refresh. Without it those links 404.
- **Headers:** no caching on `index.html` and the app script, so visitors
  always get the latest deploy.

### 4.3 Pin the Flutter version

Service → **Environment** → **Add Environment Variable**:

| Key | Value |
|---|---|
| `FLUTTER_VERSION` | the exact version from step 2.1, e.g. `3.35.4` |

Save. Now Render builds with the same Flutter your tests passed on.

### 4.4 First deploy

Render starts building. The first build takes several minutes (it downloads
Flutter); later ones are faster. In **Logs** you should see, in order:

1. `Installing Flutter …`
2. `flutter test` → `All tests passed!`
3. `flutter build web --release` → `✓ Built build/web`
4. `Built build/web`, then *Deploy live*

### 4.5 Check the live site

Open `https://measurely-site.onrender.com` and check:

- [ ] Home loads, with the loading screen shown only briefly
- [ ] Every menu link works
- [ ] Type `https://measurely-site.onrender.com/pricing` straight into the address bar — it opens Pricing, not a 404
- [ ] Refresh on a calculator page — it stays on that page
- [ ] A calculator demo updates as you type
- [ ] On a phone, the menu icon opens the side menu
- [ ] Paste the link into WhatsApp or LinkedIn — the preview card shows the Measurely image

---

## 5. Your own domain (recommended)

For example `measurely.kartwheelconsulting.com`.

1. Render → service → **Settings** → **Custom Domains** → **Add** → enter the domain.
2. At your DNS provider, add the record Render shows — for a subdomain, a
   **CNAME** from `measurely` to `measurely-site.onrender.com`.
3. Wait for Render to show **Verified** and **Certificate issued**. HTTPS is automatic.
4. Replace the Render address with yours in the files search engines and
   link previews read, then push:

```powershell
cd E:\dev\measurely-site
$old = "https://measurely-site.onrender.com"
$new = "https://measurely.kartwheelconsulting.com"
"web\index.html","web\robots.txt","web\sitemap.xml" | ForEach-Object {
  (Get-Content $_ -Raw).Replace($old, $new) | Set-Content $_ -NoNewline
}
git add -A
git commit -m "Use custom domain"
git push
```

Render redeploys by itself.

---

## 6. Updating the site

Edit, then:

```powershell
flutter analyze
flutter test
git add -A
git commit -m "Describe the change"
git push
```

Every push to `main` redeploys. If a deploy goes wrong: Render → **Deploys**
→ previous deploy → **Rollback**.

---

## 7. Connecting it to the App Store listing

In the Partner Dashboard listing, use:

| Listing field | URL |
|---|---|
| Privacy policy URL | `https://<your domain>/privacy` |
| Website / marketing URL | `https://<your domain>/` |
| FAQ URL | `https://<your domain>/faq` |

Once the listing is approved, set `appStoreUrl` in `lib/config.dart` and push.
