# ``KitoOnboarding``

A paged, swipeable onboarding flow with a themed, skippable layout and an animated page indicator.

## Overview

KitoOnboarding presents a sequence of ``KitoOnboardingPage`` values in a
``KitoOnboardingView``. A ``KitoOnboardingViewModel`` owns the pages, tracks the
current position, and calls its `onFinish` closure when the user completes or
skips the flow, which makes it a natural place to record that onboarding has
been seen.

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

Each page can carry an eyebrow, bullets, a background (colour, gradient,
material or image), and its own foreground, accent and on-accent colours. Skip,
Back, the indicator and the button take on the current page's colours as you
swipe. Artwork can be an SF Symbol, an image, or any view you draw.

Pass a ``KitoOnboardingStyle`` to choose the button placement, page transition,
layout, indicator, artwork motion and button labels. Transitions track the
swipe itself, and Reduce Motion swaps the cube, zoom and parallax transitions
for a fade.

## Topics

### Essentials

- ``KitoOnboardingView``
- ``KitoOnboardingViewModel``

### Pages

- ``KitoOnboardingPage``
- ``KitoOnboardingArtwork``

### Styling

- ``KitoOnboardingStyle``
- ``KitoOnboardingLabels``
- ``KitoOnboardingButtonPlacement``
- ``KitoOnboardingPageTransition``
- ``KitoOnboardingLayout``
- ``KitoOnboardingIndicator``
- ``KitoOnboardingArtworkMotion``
