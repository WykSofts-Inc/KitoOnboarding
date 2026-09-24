# KitoOnboarding

**[Documentation](https://wyksofts-inc.github.io/KitoOnboarding/documentation/kitoonboarding/)**

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

**Illustrated pages, a layout, a transition and a progress-ring button:**
```swift
let pages = [
    KitoOnboardingPage(eyebrow: "Discover", title: "Find what you love", message: "Thousands of picks, sorted for you.", accent: .orange) {
        MyIllustration()                     // any view: an image, a drawing, an animation
    },
    KitoOnboardingPage(artwork: .none, title: "See the world", message: "Guides from locals.",
                       background: .image(.url(photoURL), overlayTint: .black.opacity(0.2)),
                       accent: .white, onAccent: .black),
]

KitoOnboardingView(viewModel: KitoOnboardingViewModel(pages: pages), style: KitoOnboardingStyle(
    buttonPlacement: .progressRing,          // .bottomFullWidth, .bottomTrailingCompact, .topTrailingCompact
    pageTransition: .parallax,               // .slide, .fade, .scaleFade, .cube, .zoom
    layout: .fullBleed,                      // .centered, .heroTop, .card, .textFirst
    indicator: .progressBar,                 // .capsules, .dots, .numbered, .none
    artworkMotion: .float,                   // .bounce, .pulse
    labels: KitoOnboardingLabels(next: "Continue", getStarted: "Let's go"),
    showsBackButton: true
))
```

Each page can carry an `eyebrow`, `bullets`, a `background` (colour, gradient, material or
image), and its own `foreground`, `accent` and `onAccent`; Skip, Back, the indicator and the
button take on the current page's colours as you swipe. Transitions track the swipe itself, and
Reduce Motion swaps cube, zoom and parallax for a fade.

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

## Right-to-left

- The pager is a horizontal scroll view, so pages, swipes, parallax and page transitions mirror automatically:
  in Arabic or Hebrew the next page comes in from the left.
- The back chevron and the next arrows use `chevron.backward` / `arrow.forward`, so they point the right way.
- Nothing extra to do in your app.

## License

MIT
