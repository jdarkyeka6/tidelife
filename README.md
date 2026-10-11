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

## TestFlight signing status (11 October 2026)

The complete Everafter game, correct display name and icon successfully pass the iOS build and archive. **TestFlight upload is not yet complete** because the developer account has reached its Apple Distribution certificate limit and GitHub doesn't have a matching signing private key.

The already-stored App Store Connect API key works for profile access; you do **not** need to redownload that key. Do not revoke certificates without checking their use in other apps.

When an existing Apple Distribution signing identity is available, add these GitHub Actions secrets:

- `APPLE_DISTRIBUTION_P12_BASE64`: base64 encoding of the original `.p12` signing identity exported **with its private key**
- `APPLE_DISTRIBUTION_P12_PASSWORD`: password protecting that `.p12`

Then go to Actions > "Upload Everafter to TideLife TestFlight" > Run workflow. This workflow never attempts to create or revoke Apple Distribution certificates. The iOS build remains automatic on source pushes.

To base64 encode a `.p12` on Windows (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\\path\\to\\distribution.p12"))
```

Keep the `.p12`, its password and the `.p8` API key in GitHub Actions Secrets or another secure vault, never in the public repository. If the original certificate's private key is not available, coordinate signing with the certificate owner or resolve Apple cloud-managed signing through the team's Apple Developer account.

**Do not change `com.jake.tidelife` when renaming the App Store Connect listing.** The iPhone app displays `Everafter` already.
