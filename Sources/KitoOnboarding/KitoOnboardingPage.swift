//
//  KitoOnboardingPage.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

public struct KitoOnboardingPage: Identifiable {
    public let id: UUID
    public var systemImage: String
    public var title: String
    public var message: String
    /// A full-bleed page background — color, gradient, material, or image —
    /// behind the icon/title/message. `nil` leaves the page on the shared
    /// `theme.colors.background` every other page uses.
    public var background: KitoBackgroundStyle?

    public init(id: UUID = UUID(), systemImage: String, title: String, message: String, background: KitoBackgroundStyle? = nil) {
        self.id = id
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.background = background
    }
}
