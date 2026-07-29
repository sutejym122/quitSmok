# BUILT App Store Connect Checklist

## Release identity

- App name: `BUILT`
- Version: `1.0`
- Initial build: `1`
- Main bundle ID: `com.sutej.BUILT`
- Widget bundle ID: `com.sutej.BUILT.BUILTWidgets`
- Lifetime Pro product ID: `com.sutej.built.pro.lifetime`
- Primary category: Health & Fitness
- Secondary category: Lifestyle
- Minimum OS: iOS 17.0
- Price: Free app with one lifetime non-consumable Pro unlock

Do not change the main bundle ID after the first build is uploaded.

## Candidate product-page metadata

### Subtitle

`Quit smoking. Build strength.`

### Promotional text

`Turn every smoke-free decision into visible proof. Track recovery, defeat cravings, protect your fitness, and build rewards without subscriptions.`

### Keywords

`quit smoking,smoke free,craving tracker,nicotine recovery,fitness motivation,habit change`

### Description

BUILT is a private, identity-first system for quitting smoking and protecting the body and life you are building.

See your smoke-free time, cigarettes avoided, money protected, recovery milestones, craving wins, training, motivation photos, and reward progress in one focused place.

WHEN A CRAVING HITS

Open the free 60-second Rescue flow. Name the urge, reset your breathing, choose a replacement action, and record the outcome. Rescue is never placed behind the Pro unlock.

MAKE PROGRESS VISIBLE

• Live smoke-free timer  
• Cigarettes avoided and money protected  
• Recovery timeline  
• Craving history and defeated-craving count  
• Home Screen widgets  
• Local reminders and milestones  

PROTECT YOUR FITNESS

Optionally connect Apple Health to see workouts and active energy completed since quitting. Your Health data remains under Apple’s permission controls and is not used for advertising.

BUILD A REWARD

Turn money you no longer burn into a visible reward goal. Add manual contributions or include protected cigarette spending automatically.

PRIVATE BY DESIGN

BUILT has no account system, no advertising SDK, and no third-party analytics. Your quitting, craving, fitness, photo, and reward information stays on your device.

BUILT PRO

Unlock expanded Fitness, Proof, Growth, and personalization features with one lifetime non-consumable purchase. No subscription. Restore Purchases is available in Settings.

BUILT is a motivational habit-support tool and is not medical advice, diagnosis, treatment, or emergency care.

## URLs after GitHub Pages is enabled

Candidate privacy URL:

`https://sutejym122.github.io/quitSmok/privacy/`

Candidate support URL:

`https://sutejym122.github.io/quitSmok/support/`

Before entering these in App Store Connect:

1. Merge the release-readiness work into the branch used by GitHub Pages.
2. In GitHub: Settings → Pages.
3. Publish from the `/docs` folder.
4. Open both URLs in a private browser window.
5. Confirm they work without signing in.

## App privacy answers

Use these answers only while the shipping app remains local-only and contains no analytics, advertising, backend upload, crash-reporting SDK, or other third-party data collection.

- Does this app collect data? `No`
- Tracking: `No`
- Tracking permission prompt: Not used
- Health data sent to developer or third parties: `No`
- User content sent to developer or third parties: `No`
- Diagnostics sent to developer or third parties: `No`

## HealthKit review preparation

- HealthKit capability enabled only on the main app
- Clinical Health Records disabled
- Read access limited to the data BUILT actually displays
- Purpose string clearly describes workouts and active energy
- Health connection remains optional
- No advertising or marketing use of Health data
- Privacy policy URL is public
- Screenshots and metadata visibly explain the fitness use

## Lifetime Pro IAP

- Reference name: `BUILT Pro Lifetime`
- Product ID: `com.sutej.built.pro.lifetime`
- Type: Non-Consumable
- Display name: `BUILT Pro — Lifetime`
- Description: `Unlock expanded Fitness, Proof, Growth, rewards, and personalization features with one lifetime purchase.`
- App Review screenshot: Show the paywall and localized lifetime price
- Review notes: Explain where the paywall appears and where Restore Purchases is located

The IAP must be submitted with the first app version if it has not previously been approved.

## App Review notes draft

BUILT is a smoking-cessation and fitness-motivation app. It has no account or login.

The free Rescue flow can be opened from the Today screen and remains fully usable without purchase.

BUILT Pro is one non-consumable lifetime in-app purchase:
`com.sutej.built.pro.lifetime`

To review the purchase:
1. Launch the app and complete onboarding.
2. Open a contextual Pro feature or Settings → BUILT Pro.
3. The paywall displays the localized StoreKit price.
4. Restore Purchases is available in Settings.

Apple Health is optional. The app requests read-only access to workout and active-energy information after the user explicitly chooses to connect it. Health information is processed locally and is not transmitted to the developer or third parties.

No special test account is required.

## Screenshots

Prepare at minimum:

- One complete iPhone 6.9-inch screenshot set
- One complete iPad 13-inch screenshot set

Recommended five-frame story:

1. Today — smoke-free timer and protected progress
2. Rescue — “A craving is not a command”
3. Fitness — workouts since quitting
4. Proof — craving wins and motivation
5. Growth — recovery and reward goal

## TestFlight checklist

- Agreements, tax, and banking active
- App record exists with exact bundle ID
- Version and build are unique
- IAP product exists
- Archive validates in Organizer
- Upload completes without privacy-manifest warnings
- Export compliance answered
- Internal testing group created
- Test information and contact details completed
- Clean install tested
- Upgrade install tested
- Purchase and restore tested with Sandbox/TestFlight
- Widget tested after TestFlight install
- Notifications tested after TestFlight install
- HealthKit permission tested after TestFlight install
- Crash logs checked before external testing

## Final submission gates

- `./Scripts/run_release_preflight.sh` passes
- `./Scripts/audit_app_store_readiness.sh` passes
- `./Scripts/build_testflight_archive.sh` passes
- Organizer validation passes
- Privacy and support URLs are publicly reachable
- App privacy answers are complete
- Screenshots are final
- IAP is attached to version 1.0
- Review notes are pasted
- A TestFlight build has completed real-device testing
