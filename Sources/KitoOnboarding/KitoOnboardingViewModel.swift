//
//  KitoOnboardingViewModel.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Observation
import KitoCore

@Observable
public final class KitoOnboardingViewModel: KitoViewModel {
    public let pages: [KitoOnboardingPage]
    public var currentIndex: Int = 0
    public var onFinish: () -> Void

    public init(pages: [KitoOnboardingPage], onFinish: @escaping () -> Void = {}) {
        self.pages = pages
        self.onFinish = onFinish
    }

    public var isLastPage: Bool {
        currentIndex == pages.count - 1
    }

    public func advance() {
        if isLastPage {
            onFinish()
        } else {
            currentIndex += 1
        }
    }

    public func skip() {
        onFinish()
    }
}
