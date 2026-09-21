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

    public init(viewModel: KitoOnboardingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            HStack {
                Spacer()
                if !viewModel.isLastPage {
                    Button("Skip", action: viewModel.skip)
                        .font(theme.typography.label)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                        .padding(theme.spacing.md)
                }
            }

            TabView(selection: $viewModel.currentIndex) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                    pageView(page).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentIndex)

            pageIndicator

            Button(action: viewModel.advance) {
                Text(viewModel.isLastPage ? "Get started" : "Next")
                    .font(theme.typography.button)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacing.sm)
            }
            .background(theme.colors.primary, in: Capsule())
            .foregroundStyle(theme.colors.onPrimary)
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.background)
    }

    private func pageView(_ page: KitoOnboardingPage) -> some View {
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
