//
//  KitoOnboardingView.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

public struct KitoOnboardingView: View {
    @Environment(\.kitoTheme) private var theme
    @Bindable var viewModel: KitoOnboardingViewModel
    let style: KitoOnboardingStyle

    public init(viewModel: KitoOnboardingViewModel, style: KitoOnboardingStyle = .default) {
        self.viewModel = viewModel
        self.style = style
    }

    public var body: some View {
        VStack {
            header

            TabView(selection: $viewModel.currentIndex) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                    pageView(page, index: index).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentIndex)

            footer
        }
        .background(theme.colors.background)
    }

    // MARK: Header (Skip, or a compact Next)

    @ViewBuilder
    private var header: some View {
        switch style.buttonPlacement {
        case .bottomFullWidth, .bottomTrailingCompact:
            HStack {
                Spacer()
                if !viewModel.isLastPage {
                    Button("Skip", action: viewModel.skip)
                        .font(theme.typography.label)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                        .padding(theme.spacing.md)
                }
            }
        case .topTrailingCompact:
            HStack {
                Spacer()
                if !viewModel.isLastPage {
                    Button(action: viewModel.advance) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(theme.colors.onPrimary)
                            .frame(width: 36, height: 36)
                            .background(theme.colors.primary, in: Circle())
                    }
                    .padding(theme.spacing.md)
                }
            }
        }
    }

    // MARK: Footer (page indicator + primary action)

    @ViewBuilder
    private var footer: some View {
        switch style.buttonPlacement {
        case .bottomFullWidth:
            pageIndicator
            primaryButton.frame(maxWidth: .infinity).padding(theme.spacing.lg)

        case .bottomTrailingCompact:
            HStack {
                pageIndicator
                Spacer()
                primaryButton
            }
            .padding(theme.spacing.lg)

        case .topTrailingCompact:
            pageIndicator.padding(.bottom, theme.spacing.sm)
            VStack(spacing: theme.spacing.sm) {
                if viewModel.isLastPage {
                    primaryButton.frame(maxWidth: .infinity)
                } else {
                    Button("Skip", action: viewModel.skip)
                        .font(theme.typography.label)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                }
            }
            .padding(theme.spacing.lg)
        }
    }

    private var primaryButton: some View {
        Button(action: viewModel.advance) {
            Text(viewModel.isLastPage ? "Get started" : "Next")
                .font(theme.typography.button)
                .padding(.horizontal, style.buttonPlacement == .bottomFullWidth ? 0 : theme.spacing.lg)
                .frame(maxWidth: style.buttonPlacement == .bottomFullWidth ? .infinity : nil)
                .padding(.vertical, theme.spacing.sm)
        }
        .background(theme.colors.primary, in: Capsule())
        .foregroundStyle(theme.colors.onPrimary)
    }

    // MARK: Page content

    private func pageView(_ page: KitoOnboardingPage, index: Int) -> some View {
        let isCurrent = index == viewModel.currentIndex
        return applyBackground(page.background) {
            VStack(spacing: theme.spacing.lg) {
                Spacer()
                Image(systemName: page.systemImage)
                    .font(.system(size: 88))
                    .foregroundStyle(theme.colors.primary)
                Text(page.title)
                    .font(theme.typography.displayMedium)
                    .foregroundStyle(theme.colors.onBackground)
                    .multilineTextAlignment(.center)
                Text(page.message)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.onBackground.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacing.xl)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .modifier(KitoOnboardingPageTransitionEffect(transition: style.pageTransition, isCurrent: isCurrent))
    }

    @ViewBuilder
    private func applyBackground<Content: View>(_ background: KitoBackgroundStyle?, @ViewBuilder content: () -> Content) -> some View {
        if let background {
            content().kitoBackground(background, cornerRadius: 0)
        } else {
            content()
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.currentIndex ? theme.colors.primary : theme.colors.surfaceMuted)
                    .frame(width: index == viewModel.currentIndex ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.currentIndex)
            }
        }
    }
}

/// Applies `KitoOnboardingPageTransition`'s content transform. `.slide`
/// leaves the page untouched (TabView's own paging is the whole effect);
/// `.fade`/`.scaleFade` dim/shrink a page once it's no longer current.
private struct KitoOnboardingPageTransitionEffect: ViewModifier {
    let transition: KitoOnboardingPageTransition
    let isCurrent: Bool

    func body(content: Content) -> some View {
        switch transition {
        case .slide:
            content
        case .fade:
            content
                .opacity(isCurrent ? 1 : 0.35)
                .animation(.easeInOut(duration: 0.3), value: isCurrent)
        case .scaleFade:
            content
                .opacity(isCurrent ? 1 : 0.4)
                .scaleEffect(isCurrent ? 1 : 0.88)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCurrent)
        }
    }
}
