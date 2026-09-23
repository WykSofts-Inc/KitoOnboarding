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

    // MARK: Navigation

    func testGoBackStopsAtTheFirstPage() {
        let viewModel = KitoOnboardingViewModel(pages: pages())
        viewModel.goBack()
        XCTAssertEqual(viewModel.currentIndex, 0)
        viewModel.advance()
        viewModel.goBack()
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertTrue(viewModel.isFirstPage)
    }

    func testProgressRunsFromTheFirstPageToOne() {
        let viewModel = KitoOnboardingViewModel(pages: pages())
        XCTAssertEqual(viewModel.progress, 0.5)
        viewModel.advance()
        XCTAssertEqual(viewModel.progress, 1)
        XCTAssertEqual(KitoOnboardingViewModel(pages: []).progress, 0)
    }

    func testCurrentPageFollowsTheIndex() {
        let viewModel = KitoOnboardingViewModel(pages: pages())
        XCTAssertEqual(viewModel.currentPage?.title, "One")
        viewModel.advance()
        XCTAssertEqual(viewModel.currentPage?.title, "Two")
        XCTAssertNil(KitoOnboardingViewModel(pages: []).currentPage)
    }

    // MARK: Pages

    func testTheSymbolInitializerStillWorks() {
        let page = KitoOnboardingPage(systemImage: "star", title: "T", message: "M")
        XCTAssertEqual(page.systemImage, "star")
        guard case .symbol("star") = page.artwork else { return XCTFail("expected a symbol artwork") }
    }

    func testSettingSystemImageReplacesTheArtwork() {
        var page = KitoOnboardingPage(artwork: .none, title: "T", message: "M")
        XCTAssertEqual(page.systemImage, "")
        page.systemImage = "bolt"
        guard case .symbol("bolt") = page.artwork else { return XCTFail("expected a symbol artwork") }
    }

    func testACustomArtworkPageKeepsItsText() {
        let page = KitoOnboardingPage(eyebrow: "New", title: "T", message: "M", bullets: ["a", "b"], accent: .orange) { Circle() }
        guard case .custom = page.artwork else { return XCTFail("expected custom artwork") }
        XCTAssertEqual(page.eyebrow, "New")
        XCTAssertEqual(page.bullets, ["a", "b"])
        XCTAssertEqual(page.accent, .orange)
    }

    // MARK: Style

    func testNewStyleOptionsDefaultToTheOriginalLook() {
        let style = KitoOnboardingStyle.default
        XCTAssertEqual(style.layout, .centered)
        XCTAssertEqual(style.indicator, .capsules)
        XCTAssertEqual(style.pageTransition, .slide)
        XCTAssertEqual(style.artworkMotion, .none)
        XCTAssertTrue(style.showsSkip)
        XCTAssertFalse(style.showsBackButton)
        XCTAssertEqual(style.labels, KitoOnboardingLabels(next: "Next", getStarted: "Get started", skip: "Skip", back: "Back"))
    }

    func testReduceMotionReplacesBigTransitionsWithAFade() {
        for transition in [KitoOnboardingPageTransition.cube, .zoom, .parallax] {
            XCTAssertEqual(KitoOnboardingView.effectiveTransition(transition, reduceMotion: true), .fade)
            XCTAssertEqual(KitoOnboardingView.effectiveTransition(transition, reduceMotion: false), transition)
        }
        XCTAssertEqual(KitoOnboardingView.effectiveTransition(.scaleFade, reduceMotion: true), .scaleFade)
    }

    func testTransitionsLeaveTheCurrentPageUntouched() {
        for transition in [KitoOnboardingPageTransition.slide, .fade, .scaleFade, .parallax, .cube, .zoom] {
            XCTAssertEqual(KitoOnboardingView.opacity(transition, 0), 1)
            XCTAssertEqual(KitoOnboardingView.scale(transition, 0), 1)
            XCTAssertEqual(KitoOnboardingView.cubeAngle(transition, 0), 0)
        }
    }

    func testTransitionsAffectLeavingPages() {
        XCTAssertLessThan(KitoOnboardingView.opacity(.fade, 1), 1)
        XCTAssertLessThan(KitoOnboardingView.scale(.scaleFade, -1), 1)
        XCTAssertGreaterThan(KitoOnboardingView.scale(.zoom, 1), 1)
        XCTAssertEqual(KitoOnboardingView.cubeAngle(.cube, 1), 75)
        XCTAssertEqual(KitoOnboardingView.opacity(.slide, 1), 1)
    }
}
