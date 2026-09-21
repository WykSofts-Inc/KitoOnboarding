# KitoOnboarding

A paged, swipeable onboarding flow — themed, skip-able, with an animated
page indicator.

## Install

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoOnboarding.git", from: "1.0.0"),
```

## Samples

**Basic three-page flow:**
```swift
@State private var onboarding = KitoOnboardingViewModel(
    pages: [
        KitoOnboardingPage(systemImage: "bolt.fill", title: "Fast", message: "Everything loads instantly."),
        KitoOnboardingPage(systemImage: "lock.fill", title: "Secure", message: "Your data stays yours."),
        KitoOnboardingPage(systemImage: "checkmark.seal.fill", title: "Simple", message: "No clutter, just what you need."),
    ],
    onFinish: { hasSeenOnboarding = true }
)

KitoOnboardingView(viewModel: onboarding)
```

**Gate app entry with it, using KitoNavigation's full-screen cover:**
```swift
.onAppear {
    if !hasSeenOnboarding { router.presentFullScreen(.onboarding) }
}
```

**Track analytics on skip vs. completion:**
```swift
let onboarding = KitoOnboardingViewModel(pages: pages, onFinish: {
    analytics.log("onboarding_completed")
    hasSeenOnboarding = true
})
```

## License

MIT
