//
//  KitoOnboardingStyle.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Where the primary action button sits. Every placement still shows a
/// full-width "Get started" button on the last page — a tiny icon button
/// is the wrong final call to action regardless of how earlier pages are
/// styled — this only changes how "Next" reads on the pages before it.
public enum KitoOnboardingButtonPlacement: Equatable, Sendable {
    /// Full-width capsule pinned to the bottom (the original layout).
    case bottomFullWidth
    /// A compact trailing pill at the bottom, alongside the page indicator.
    case bottomTrailingCompact
    /// A small circular arrow button in the top-trailing corner, in place
    /// of Skip (Skip moves to a text link at the bottom instead).
    case topTrailingCompact
    /// A round arrow button wrapped in a ring that fills as you progress; it stretches into the
    /// full-width "Get started" button on the last page.
    case progressRing
}

/// How pages move as you swipe between them. Driven by the swipe itself, so every effect tracks
/// your finger rather than playing after the page settles.
public enum KitoOnboardingPageTransition: Equatable, Sendable {
    /// Pages simply slide.
    case slide
    /// Pages fade as they leave.
    case fade
    /// Pages shrink and fade: a shallow carousel/depth effect.
    case scaleFade
    /// Artwork and background move slower than the text, for depth.
    case parallax
    /// Pages turn like the faces of a cube.
    case cube
    /// The leaving page zooms toward you and fades.
    case zoom
}

/// How the text, artwork and background of each page are arranged.
public enum KitoOnboardingLayout: Equatable, Sendable {
    /// Artwork in the middle, centred text below it (the original layout).
    case centered
    /// Large artwork filling the top, leading-aligned text below.
    case heroTop
    /// The background fills the screen; leading text sits at the bottom over a scrim. Best with
    /// a photo or gradient background.
    case fullBleed
    /// Artwork on the page background, text on a rounded card rising from the bottom.
    case card
    /// A big leading title first, artwork filling the space below.
    case textFirst
}

/// How the current position is shown.
public enum KitoOnboardingIndicator: Equatable, Sendable {
    /// A stretched capsule for the current page (the original indicator).
    case capsules
    /// Round dots; the current one is larger and filled.
    case dots
    /// "2 / 4".
    case numbered
    /// Segmented bars along the top, like Stories.
    case progressBar
    case none
}

/// Ambient motion on the artwork of the current page. Off when Reduce Motion is on.
public enum KitoOnboardingArtworkMotion: Equatable, Sendable {
    case none
    /// Drifts gently up and down.
    case float
    /// Bounces each time its page becomes current.
    case bounce
    /// Breathes in and out.
    case pulse
}

/// The words on the buttons.
public struct KitoOnboardingLabels: Equatable, Sendable {
    public var next: String
    public var getStarted: String
    public var skip: String
    public var back: String

    public init(next: String = "Next", getStarted: String = "Get started", skip: String = "Skip", back: String = "Back") {
        self.next = next
        self.getStarted = getStarted
        self.skip = skip
        self.back = back
    }
}

public struct KitoOnboardingStyle: Sendable {
    public var buttonPlacement: KitoOnboardingButtonPlacement
    public var pageTransition: KitoOnboardingPageTransition
    public var layout: KitoOnboardingLayout
    public var indicator: KitoOnboardingIndicator
    public var artworkMotion: KitoOnboardingArtworkMotion
    public var labels: KitoOnboardingLabels
    public var showsSkip: Bool
    /// A back chevron in the top-leading corner after the first page.
    public var showsBackButton: Bool

    public init(
        buttonPlacement: KitoOnboardingButtonPlacement = .bottomFullWidth,
        pageTransition: KitoOnboardingPageTransition = .slide,
        layout: KitoOnboardingLayout = .centered,
        indicator: KitoOnboardingIndicator = .capsules,
        artworkMotion: KitoOnboardingArtworkMotion = .none,
        labels: KitoOnboardingLabels = KitoOnboardingLabels(),
        showsSkip: Bool = true,
        showsBackButton: Bool = false
    ) {
        self.buttonPlacement = buttonPlacement
        self.pageTransition = pageTransition
        self.layout = layout
        self.indicator = indicator
        self.artworkMotion = artworkMotion
        self.labels = labels
        self.showsSkip = showsSkip
        self.showsBackButton = showsBackButton
    }

    public static let `default` = KitoOnboardingStyle()
}
