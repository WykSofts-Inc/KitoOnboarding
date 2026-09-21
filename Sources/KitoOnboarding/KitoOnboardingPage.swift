//
//  KitoOnboardingPage.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

public struct KitoOnboardingPage: Identifiable {
    public let id: UUID
    public var systemImage: String
    public var title: String
    public var message: String

    public init(id: UUID = UUID(), systemImage: String, title: String, message: String) {
        self.id = id
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }
}
