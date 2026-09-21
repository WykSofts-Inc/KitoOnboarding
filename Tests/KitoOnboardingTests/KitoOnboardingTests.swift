//
//  KitoOnboardingTests.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoOnboarding

@MainActor
final class KitoOnboardingTests: XCTestCase {
    private func pages() -> [KitoOnboardingPage] {
        [
            KitoOnboardingPage(systemImage: "1.circle", title: "One", message: "First"),
            KitoOnboardingPage(systemImage: "2.circle", title: "Two", message: "Second"),
        ]
    }

    func testAdvanceMovesToNextPage() {
        let viewModel = KitoOnboardingViewModel(pages: pages())
        viewModel.advance()
        XCTAssertEqual(viewModel.currentIndex, 1)
    }

    func testAdvanceOnLastPageCallsOnFinish() {
        var finished = false
        let viewModel = KitoOnboardingViewModel(pages: pages(), onFinish: { finished = true })
        viewModel.advance()
        viewModel.advance()
        XCTAssertTrue(finished)
    }

    func testSkipCallsOnFinishImmediately() {
        var finished = false
        let viewModel = KitoOnboardingViewModel(pages: pages(), onFinish: { finished = true })
        viewModel.skip()
        XCTAssertTrue(finished)
        XCTAssertEqual(viewModel.currentIndex, 0)
    }
}
