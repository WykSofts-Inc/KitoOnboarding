//
//  KitoOnboardingPage.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// The picture on a page: an SF Symbol, an image (bundled or remote), or any view you draw.
public enum KitoOnboardingArtwork {
    case symbol(String)
    case image(KitoBackgroundImage)
    case custom(AnyView)
    case none
}

public struct KitoOnboardingPage: Identifiable {
    public let id: UUID
    public var artwork: KitoOnboardingArtwork
    /// A small line above the title, e.g. "STEP 1" or "NEW".
    public var eyebrow: String?
    public var title: String
    public var message: String
    /// Short feature lines shown under the message with a check mark.
    public var bullets: [String]
    /// A full-bleed page background — color, gradient, material, or image —
    /// behind the icon/title/message. `nil` leaves the page on the shared
    /// `theme.colors.background` every other page uses.
    public var background: KitoBackgroundStyle?
    /// Text colour for this page (and Skip, the indicator and Back while it's showing); nil uses
    /// the theme, or white on a `.fullBleed` layout.
    public var foreground: Color?
    /// The button and indicator colour while this page is showing; nil uses `theme.colors.primary`.
    public var accent: Color?
    /// Text on the accent-coloured button; nil uses `theme.colors.onPrimary`.
    public var onAccent: Color?

    /// The SF Symbol name when the artwork is a symbol, "" otherwise. Setting it makes the
    /// artwork that symbol.
    public var systemImage: String {
        get { if case .symbol(let name) = artwork { return name } else { return "" } }
        set { artwork = .symbol(newValue) }
    }

    public init(id: UUID = UUID(), systemImage: String, title: String, message: String, background: KitoBackgroundStyle? = nil) {
        self.init(id: id, artwork: .symbol(systemImage), title: title, message: message, background: background)
    }

    public init(
        id: UUID = UUID(),
        artwork: KitoOnboardingArtwork,
        eyebrow: String? = nil,
        title: String,
        message: String,
        bullets: [String] = [],
        background: KitoBackgroundStyle? = nil,
        foreground: Color? = nil,
        accent: Color? = nil,
        onAccent: Color? = nil
    ) {
        self.id = id
        self.artwork = artwork
        self.eyebrow = eyebrow
        self.title = title
        self.message = message
        self.bullets = bullets
        self.background = background
        self.foreground = foreground
        self.accent = accent
        self.onAccent = onAccent
    }

    /// A page whose artwork is a view you draw: an illustration, a product shot, an animation.
    public init<Artwork: View>(
        id: UUID = UUID(),
        eyebrow: String? = nil,
        title: String,
        message: String,
        bullets: [String] = [],
        background: KitoBackgroundStyle? = nil,
        foreground: Color? = nil,
        accent: Color? = nil,
        onAccent: Color? = nil,
        @ViewBuilder artwork: () -> Artwork
    ) {
        self.init(
            id: id, artwork: .custom(AnyView(artwork())), eyebrow: eyebrow, title: title, message: message,
            bullets: bullets, background: background, foreground: foreground, accent: accent, onAccent: onAccent
        )
    }
}
