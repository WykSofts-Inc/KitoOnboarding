//
//  KitoOnboardingTests.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
import SwiftUI
import KitoCore
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

    func testPageBackgroundDefaultsToNil() {
        XCTAssertNil(KitoOnboardingPage(systemImage: "star", title: "T", message: "M").background)
    }

    func testPageCanCarryABackgroundImageOrGradient() {
        let gradientPage = KitoOnboardingPage(systemImage: "star", title: "T", message: "M", background: .gradient(.linear(.purple, .indigo)))
        guard case .gradient(let gradient) = gradientPage.background else {
            return XCTFail("expected .gradient")
        }
        XCTAssertEqual(gradient.colors, [.purple, .indigo])

        let imagePage = KitoOnboardingPage(systemImage: "star", title: "T", message: "M", background: .image(.systemImage("mountain.2.fill")))
        guard case .image(let image, _) = imagePage.background, case .systemImage(let name) = image else {
            return XCTFail("expected .image(.systemImage)")
        }
        XCTAssertEqual(name, "mountain.2.fill")
    }

    func testStyleDefaultsToBottomFullWidthAndSlide() {
        let style = KitoOnboardingStyle.default
        XCTAssertEqual(style.buttonPlacement, .bottomFullWidth)
    }
}
