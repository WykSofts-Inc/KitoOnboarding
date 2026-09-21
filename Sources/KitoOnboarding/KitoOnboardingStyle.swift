//
//  KitoOnboardingStyle.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

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
}

/// How a page's content animates in as it becomes the current page —
/// applied on top of `TabView`'s own swipe paging, not a replacement for it.
public enum KitoOnboardingPageTransition: Sendable {
    /// No extra transform — pages simply swipe in the standard TabView way.
    case slide
    /// Off-page content fades down to partial opacity.
    case fade
    /// Off-page content shrinks and fades — a shallow carousel/depth effect.
    case scaleFade
}

public struct KitoOnboardingStyle: Sendable {
    public var buttonPlacement: KitoOnboardingButtonPlacement
    public var pageTransition: KitoOnboardingPageTransition

    public init(
        buttonPlacement: KitoOnboardingButtonPlacement = .bottomFullWidth,
        pageTransition: KitoOnboardingPageTransition = .slide
    ) {
        self.buttonPlacement = buttonPlacement
        self.pageTransition = pageTransition
    }

    public static let `default` = KitoOnboardingStyle()
}
