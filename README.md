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

## Automatic signing for TestFlight (11 October 2026)

The game and custom icon build successfully. **Everafter is not on TestFlight yet.** The app's home-screen display name is `Everafter`, while the existing App Store Connect record and bundle identifier remain TideLife / `com.jake.tidelife`.

The XcodeGen project sets `CODE_SIGN_STYLE: Automatic`. The "Upload Everafter to TideLife TestFlight" workflow uses the stored App Store Connect API key and passes `-allowProvisioningUpdates` and authentication-key arguments to `xcodebuild`. The export option also specifies automatic signing. No `.p12` certificate or password is required by the workflow.

The latest automatic-signing attempt **failed before archive/export**:

```
No Account for Team (configured Apple team)
No profiles for 'com.jake.tidelife' were found
```

This is an Apple/Xcode account or signing access problem on the GitHub macOS runner, not a game compilation error. Xcode must be able to associate the API key with a team permitted to manage provisioning and cloud distribution signing. Check the `APPLE_TEAM_ID`, API key issuer/team association and permissions in Apple Developer/App Store Connect before retrying. The account has also previously reached its local Apple Distribution certificate limit, so do not create or revoke certificates without checking dependencies.

Apple's Xcode cloud-signing guidance documents the supported `xcodebuild` App Store Connect API key approach: https://developer.apple.com/videos/play/wwdc2021/10204/

See GitHub Actions to inspect the failing automatic signing run. No live TestFlight build was uploaded.
