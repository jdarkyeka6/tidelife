# Everafter (TideLife TestFlight record)

This repository builds **Everafter**, an offline, unlocked, original life simulator for iPhone and iPad.

- **Home screen/display name:** Everafter
- **App Store Connect/TestFlight record:** TideLife (rename in App Store Connect later)
- **Existing bundle identifier:** `com.jake.tidelife` (do not change this to rename the app)
- **Game:** `TideLife/Game/index.html`
- **Minimum iOS:** 17.0
- **No logins, subscriptions, paywalls or network needed to play**

The app uses a native `WKWebView` wrapper around the entire bundled game. Browser-style local saves are kept in WebKit's persistent data store. Game JSON export downloads go to the app Documents folder and are visible in Files if supported by the iOS WebKit download API.

## Running locally

1. Install XcodeGen: `brew install xcodegen`.
2. Run `xcodegen generate`.
3. Open `TideLife.xcodeproj`, select scheme `TideLife`, and run.

## TestFlight

The GitHub Actions workflow `Everafter to TestFlight (TideLife app)` builds on pushes to main. It uses the **existing** `APP_STORE_CONNECT_API_KEY`, `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, and `APPLE_TEAM_ID` repository secrets. It requests Apple's automatic/cloud-managed distribution signing to avoid the old manually named profile issue.

If automatic cloud distribution signing isn't permitted for the App Store Connect account, fix the account's cloud-managed distribution certificate permissions or install an Apple Distribution certificate for local export. **Never commit .p8 or .p12 files to the repo.**

After a successful upload, Apple may take time to process the build before it appears in TestFlight. Changing the TestFlight/App Store Connect listing name later does not require changing the bundle identifier or the game's display name.
