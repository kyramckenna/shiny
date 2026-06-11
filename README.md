# Passkey

This app is a native app based on the sample application at https://developer.apple.com/documentation/authenticationservices/connecting_to_a_service_with_passkeys

## Overview

- Note: This sample code project is associated with WWDC22 session [10092: Meet passkeys](https://developer.apple.com/wwdc22/10092/) and WWDC21 session [10106: Move beyond passwords](https://developer.apple.com/wwdc21/10106/).


## Configure the sample code project

To build and run this sample:
1. Open the sample with Xcode 14 or later.
2. Select the Passkey project.
3. For the project's target, select your team from the Team drop-down menu in the Signing & Capabilities pane to let Xcode automatically manage your provisioning profile.
4. Add the Associated Domains capability using the "+ Capability" button in the same pane, and specify your domain with the `webcredentials` service.
5. Ensure an `apple-app-site-association` (AASA) file is present on your domain in the `.well-known` directory, and that it contains an entry for this app's App ID for the `webcredentials` service.
6. In `Shared/AuthService/REST/Constants.swift`, update these deployment-specific `Config` values:
   - `Config.relyingPartyID`
   - `Config.associatedDomain`
   - `Config.serverBaseURL`
   - `Config.serverFallbackURL`
   - `Config.appGroupIdentifier`
   - `Config.appIdentifier`
7. Ensure Signing & Capabilities values match your configuration:
   - Associated Domains includes `webcredentials:<your relying party domain>`
   - App Groups includes your configured app group (for example `group.daon`)
8. Confirm your AASA `webcredentials` section includes your full App ID (`TEAMID.bundle.identifier`).
9. No other source files should require updates unless there are leftover hardcoded placeholders.
