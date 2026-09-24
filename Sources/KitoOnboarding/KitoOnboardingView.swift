//
//  KitoOnboardingView.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A paged onboarding flow. Pages fill the screen (backgrounds run under the status bar and home
/// indicator); Skip, Back, the indicator and the primary button float above them and take on the
/// current page's colours as you swipe.
public struct KitoOnboardingView: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var viewModel: KitoOnboardingViewModel
    let style: KitoOnboardingStyle

    @State private var scrolledIndex: Int? = 0

    public init(viewModel: KitoOnboardingViewModel, style: KitoOnboardingStyle = .default) {
        self.viewModel = viewModel
        self.style = style
    }

    // MARK: Current-page colours

    private var accent: Color { viewModel.currentPage?.accent ?? theme.colors.primary }
    private var onAccent: Color { viewModel.currentPage?.onAccent ?? theme.colors.onPrimary }
    private var headerForeground: Color {
        viewModel.currentPage.map { OnboardingPageView.foreground(for: $0, layout: style.layout, theme: theme) } ?? theme.colors.onBackground
    }
    /// On `.card` the footer sits on the card, not the page background.
    private var footerForeground: Color {
        style.layout == .card ? (style.cardForeground ?? theme.colors.onSurface) : headerForeground
    }

    public var body: some View {
        GeometryReader { proxy in
            let insets = proxy.safeAreaInsets
            ZStack {
                theme.colors.background
                pager(insets: insets)
                VStack(spacing: 0) {
                    // A minimum margin keeps the chrome off the corners when there's no safe area (a preview).
                    header.padding(.top, max(insets.top, theme.spacing.sm))
                    Spacer(minLength: 0)
                    footer.padding(.bottom, max(insets.bottom, theme.spacing.lg))
                }
            }
            .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
        .onAppear { scrolledIndex = viewModel.currentIndex }
        .onChange(of: scrolledIndex) { _, index in
            if let index, index != viewModel.currentIndex { viewModel.currentIndex = index }
        }
        .onChange(of: viewModel.currentIndex) { _, index in
            guard scrolledIndex != index else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) { scrolledIndex = index }
        }
    }

    // MARK: Pages

    private func pager(insets: EdgeInsets) -> some View {
        let transition = Self.effectiveTransition(style.pageTransition, reduceMotion: reduceMotion)
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(viewModel.pages.indices, id: \.self) { index in
                    OnboardingPageView(
                        page: viewModel.pages[index],
                        isCurrent: index == viewModel.currentIndex,
                        style: style,
                        insets: insets,
                        motionEnabled: !reduceMotion
                    )
                    .containerRelativeFrame([.horizontal, .vertical])
                    .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                        content
                            .opacity(Self.opacity(transition, phase.value))
                            .scaleEffect(Self.scale(transition, phase.value))
                            .rotation3DEffect(
                                .degrees(Self.cubeAngle(transition, phase.value)),
                                axis: (x: 0, y: 1, z: 0),
                                anchor: phase.value < 0 ? .trailing : .leading,
                                perspective: 0.45
                            )
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrolledIndex)
    }

    /// Cube and zoom are big, fast motions; Reduce Motion swaps them for a fade.
    static func effectiveTransition(_ transition: KitoOnboardingPageTransition, reduceMotion: Bool) -> KitoOnboardingPageTransition {
        guard reduceMotion else { return transition }
        switch transition {
        case .cube, .zoom, .parallax: return .fade
        default: return transition
        }
    }

    static func opacity(_ transition: KitoOnboardingPageTransition, _ value: Double) -> Double {
        let distance = min(abs(value), 1)
        switch transition {
        case .fade: return 1 - distance * 0.75
        case .scaleFade: return 1 - distance * 0.55
        case .zoom: return 1 - distance
        default: return 1
        }
    }

    static func scale(_ transition: KitoOnboardingPageTransition, _ value: Double) -> Double {
        let distance = min(abs(value), 1)
        switch transition {
        case .scaleFade: return 1 - distance * 0.14
        case .zoom: return 1 + distance * 0.35
        default: return 1
        }
    }

    static func cubeAngle(_ transition: KitoOnboardingPageTransition, _ value: Double) -> Double {
        transition == .cube ? value * 75 : 0
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: theme.spacing.xs) {
            if style.indicator == .progressBar {
                OnboardingIndicatorView(style: .progressBar, count: viewModel.pages.count, current: viewModel.currentIndex, accent: accent, foreground: headerForeground)
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.top, theme.spacing.xs)
            }
            HStack {
                if style.showsBackButton && !viewModel.isFirstPage {
                    Button(action: viewModel.goBack) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .foregroundStyle(headerForeground)
                    .accessibilityLabel(style.labels.back)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
                Spacer()
                if !viewModel.isLastPage {
                    if style.buttonPlacement == .topTrailingCompact {
                        Button(action: viewModel.advance) {
                            Image(systemName: "arrow.forward")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(onAccent)
                                .frame(width: 40, height: 40)
                                .background(accent, in: Circle())
                        }
                        .accessibilityLabel(style.labels.next)
                    } else if style.showsSkip {
                        Button(style.labels.skip, action: viewModel.skip)
                            .font(theme.typography.label)
                            .foregroundStyle(headerForeground.opacity(0.75))
                    }
                }
            }
            .frame(height: 48)
            .padding(.horizontal, theme.spacing.md)
        }
    }

    // MARK: Footer

    private var footerIndicator: some View {
        OnboardingIndicatorView(
            style: style.indicator == .progressBar ? .none : style.indicator,
            count: viewModel.pages.count, current: viewModel.currentIndex, accent: accent, foreground: footerForeground
        )
    }

    @ViewBuilder
    private var footer: some View {
        Group {
            switch style.buttonPlacement {
            case .bottomFullWidth:
                VStack(spacing: theme.spacing.lg) {
                    footerIndicator
                    primaryButton(fullWidth: true)
                }
            case .bottomTrailingCompact:
                HStack {
                    if !viewModel.isLastPage {
                        footerIndicator
                        Spacer()
                    }
                    primaryButton(fullWidth: viewModel.isLastPage)
                }
            case .topTrailingCompact:
                VStack(spacing: theme.spacing.lg) {
                    footerIndicator
                    if viewModel.isLastPage {
                        primaryButton(fullWidth: true)
                    } else if style.showsSkip {
                        Button(style.labels.skip, action: viewModel.skip)
                            .font(theme.typography.label)
                            .foregroundStyle(footerForeground.opacity(0.75))
                            .frame(height: 52)
                    }
                }
            case .progressRing:
                HStack {
                    if !viewModel.isLastPage {
                        footerIndicator
                        Spacer()
                    }
                    ProgressRingButton(
                        isLast: viewModel.isLastPage, progress: viewModel.progress, accent: accent, onAccent: onAccent,
                        labels: style.labels, font: theme.typography.button, action: viewModel.advance
                    )
                }
            }
        }
        .padding(.horizontal, theme.spacing.lg)
    }

    private func primaryButton(fullWidth: Bool) -> some View {
        Button(action: viewModel.advance) {
            Text(viewModel.isLastPage ? style.labels.getStarted : style.labels.next)
                .font(theme.typography.button)
                .foregroundStyle(onAccent)
                .contentTransition(.interpolate)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.horizontal, fullWidth ? 0 : theme.spacing.xl)
                .frame(height: 54)
                .background(Capsule().fill(accent))
        }
        .buttonStyle(OnboardingPressStyle())
    }
}

// MARK: - Page

struct OnboardingPageView: View {
    @Environment(\.kitoTheme) private var theme
    let page: KitoOnboardingPage
    let isCurrent: Bool
    let style: KitoOnboardingStyle
    let insets: EdgeInsets
    let motionEnabled: Bool

    static func foreground(for page: KitoOnboardingPage, layout: KitoOnboardingLayout, theme: KitoTheme) -> Color {
        page.foreground ?? (layout == .fullBleed ? .white : theme.colors.onBackground)
    }

    private var foreground: Color { Self.foreground(for: page, layout: style.layout, theme: theme) }
    private var accent: Color { page.accent ?? theme.colors.primary }
    private var cardForeground: Color { style.cardForeground ?? theme.colors.onSurface }
    private var parallax: Bool { style.pageTransition == .parallax && motionEnabled }
    /// Room for the floating header and footer.
    private var topInset: CGFloat { max(insets.top, theme.spacing.sm) + (style.indicator == .progressBar ? 64 : 52) }
    private var bottomInset: CGFloat { max(insets.bottom, 24) + 120 }

    var body: some View {
        ZStack {
            background
            content
        }
        .clipped()
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var background: some View {
        ZStack {
            if let background = page.background {
                Color.clear
                    .kitoBackground(background, cornerRadius: 0)
                    .scaleEffect(parallax ? 1.3 : 1)
                    .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                        content.offset(x: parallax ? -phase.value * 160 : 0)
                    }
            }
            if style.layout == .fullBleed {
                LinearGradient(colors: [.black.opacity(0.35), .clear, .clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
            }
        }
    }

    private var artwork: some View {
        OnboardingArtworkView(artwork: page.artwork, accent: accent, motion: style.artworkMotion, isCurrent: isCurrent, motionEnabled: motionEnabled, parallax: parallax)
    }

    @ViewBuilder
    private var content: some View {
        switch style.layout {
        case .centered:
            VStack(spacing: theme.spacing.xl) {
                Spacer(minLength: 0)
                artwork.frame(maxHeight: 280)
                textBlock(alignment: .center, color: foreground)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, topInset)
            .padding(.bottom, bottomInset)

        case .heroTop:
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                artwork.frame(maxWidth: .infinity, maxHeight: .infinity)
                textBlock(alignment: .leading, color: foreground)
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, topInset)
            .padding(.bottom, bottomInset)

        case .fullBleed:
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                Spacer(minLength: 0)
                if !page.artwork.isNone {
                    artwork.frame(maxHeight: 160, alignment: .leading)
                }
                textBlock(alignment: .leading, color: foreground, titleFont: theme.typography.displayLarge)
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, topInset)
            .padding(.bottom, bottomInset)

        case .card:
            VStack(spacing: 0) {
                artwork
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, theme.spacing.xl)
                    .padding(.top, topInset)
                    .padding(.bottom, theme.spacing.xl)
                VStack(spacing: theme.spacing.lg) {
                    Capsule().fill(cardForeground.opacity(0.15)).frame(width: 40, height: 5)
                    textBlock(alignment: .center, color: cardForeground)
                }
                .padding(.horizontal, theme.spacing.xl)
                .padding(.top, theme.spacing.md)
                .padding(.bottom, bottomInset)
                .frame(maxWidth: .infinity)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 36, topTrailingRadius: 36, style: .continuous)
                        .fill(style.cardColor ?? theme.colors.surface)
                        .shadow(color: .black.opacity(0.12), radius: 24, y: -4)
                )
            }

        case .textFirst:
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                textBlock(alignment: .leading, color: foreground, titleFont: theme.typography.displayLarge)
                artwork.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, topInset + theme.spacing.md)
            .padding(.bottom, bottomInset)
        }
    }

    /// Title, message and bullets; they rise into place, staggered, each time the page becomes
    /// current.
    private func textBlock(alignment: HorizontalAlignment, color: Color, titleFont: Font? = nil) -> some View {
        let textAlignment: TextAlignment = alignment == .center ? .center : .leading
        let frameAlignment = Alignment(horizontal: alignment, vertical: .center)
        return VStack(alignment: alignment, spacing: theme.spacing.sm) {
            if let eyebrow = page.eyebrow {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .kerning(1.4)
                    .foregroundStyle(style.layout == .fullBleed ? color.opacity(0.85) : accent)
                    .modifier(RiseIn(isVisible: isCurrent, delay: 0.02, enabled: motionEnabled))
            }
            Text(page.title)
                .font(titleFont ?? theme.typography.displayMedium)
                .foregroundStyle(color)
                .multilineTextAlignment(textAlignment)
                .modifier(RiseIn(isVisible: isCurrent, delay: 0.06, enabled: motionEnabled))
            Text(page.message)
                .font(theme.typography.body)
                .foregroundStyle(color.opacity(0.72))
                .multilineTextAlignment(textAlignment)
                .modifier(RiseIn(isVisible: isCurrent, delay: 0.12, enabled: motionEnabled))
            if !page.bullets.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(page.bullets.enumerated()), id: \.offset) { index, bullet in
                        Label {
                            Text(bullet).foregroundStyle(color)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(accent)
                        }
                        .font(theme.typography.body)
                        .modifier(RiseIn(isVisible: isCurrent, delay: 0.18 + Double(index) * 0.06, enabled: motionEnabled))
                    }
                }
                .padding(.top, theme.spacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: frameAlignment)
    }
}

extension KitoOnboardingArtwork {
    var isNone: Bool { if case .none = self { return true } else { return false } }
}

// MARK: - Artwork

struct OnboardingArtworkView: View {
    let artwork: KitoOnboardingArtwork
    let accent: Color
    let motion: KitoOnboardingArtworkMotion
    let isCurrent: Bool
    let motionEnabled: Bool
    let parallax: Bool

    @State private var drifting = false
    @State private var bounceTrigger = 0

    var body: some View {
        content
            .offset(y: motion == .float && drifting ? -12 : 0)
            .scaleEffect(motion == .pulse && drifting ? 1.06 : 1)
            .keyframeAnimator(initialValue: 1.0, trigger: bounceTrigger) { view, scale in
                view.scaleEffect(scale)
            } keyframes: { _ in
                SpringKeyframe(motion == .bounce ? 1.14 : 1, duration: 0.18, spring: .snappy)
                SpringKeyframe(1, duration: 0.5, spring: .bouncy)
            }
            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                view.offset(x: parallax ? phase.value * 110 : 0)
            }
            .onAppear {
                guard motionEnabled, motion == .float || motion == .pulse else { return }
                withAnimation(.easeInOut(duration: motion == .float ? 2.4 : 1.6).repeatForever(autoreverses: true)) { drifting = true }
            }
            .onChange(of: isCurrent) { _, current in
                if current, motionEnabled, motion == .bounce { bounceTrigger += 1 }
            }
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var content: some View {
        switch artwork {
        case .symbol(let name):
            symbol(name)
        case .image(let image):
            switch image {
            case .asset(let name):
                Image(name).resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            case .systemImage(let name):
                symbol(name)
            case .url(let url):
                AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.35))) { phase in
                    switch phase {
                    case .success(let loaded):
                        loaded.resizable().scaledToFit().transition(.opacity)
                    case .failure:
                        Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary)
                    default:
                        ProgressView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
        case .custom(let view):
            view
        case .none:
            EmptyView()
        }
    }

    private func symbol(_ name: String) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(accent)
            .frame(maxWidth: 170, maxHeight: 170)
    }
}

// MARK: - Motion helpers

/// Fades and lifts content in when its page becomes current.
struct RiseIn: ViewModifier {
    let isVisible: Bool
    let delay: Double
    let enabled: Bool

    func body(content: Content) -> some View {
        content
            .opacity(!enabled || isVisible ? 1 : 0)
            .offset(y: !enabled || isVisible ? 0 : 18)
            .animation(enabled ? .spring(response: 0.55, dampingFraction: 0.85).delay(isVisible ? delay : 0) : nil, value: isVisible)
    }
}

struct OnboardingPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Indicator

struct OnboardingIndicatorView: View {
    let style: KitoOnboardingIndicator
    let count: Int
    let current: Int
    let accent: Color
    let foreground: Color

    var body: some View {
        Group {
            switch style {
            case .capsules:
                HStack(spacing: 6) {
                    ForEach(0..<count, id: \.self) { index in
                        Capsule()
                            .fill(index == current ? accent : foreground.opacity(0.25))
                            .frame(width: index == current ? 22 : 7, height: 7)
                    }
                }
            case .dots:
                HStack(spacing: 9) {
                    ForEach(0..<count, id: \.self) { index in
                        Circle()
                            .fill(index == current ? accent : foreground.opacity(0.25))
                            .frame(width: index == current ? 10 : 7, height: index == current ? 10 : 7)
                    }
                }
            case .numbered:
                HStack(spacing: 2) {
                    Text("\(current + 1)").foregroundStyle(foreground).contentTransition(.numericText(value: Double(current)))
                    Text("/ \(count)").foregroundStyle(foreground.opacity(0.5))
                }
                .font(.subheadline.weight(.semibold).monospacedDigit())
            case .progressBar:
                HStack(spacing: 4) {
                    ForEach(0..<count, id: \.self) { index in
                        Capsule()
                            .fill(index <= current ? accent : foreground.opacity(0.22))
                            .frame(height: 3)
                    }
                }
            case .none:
                EmptyView()
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: current)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(current + 1) of \(count)")
    }
}

// MARK: - Progress ring button

/// A round Next button whose ring fills with progress; on the last page it stretches into the
/// full-width primary button.
struct ProgressRingButton: View {
    let isLast: Bool
    let progress: Double
    let accent: Color
    let onAccent: Color
    let labels: KitoOnboardingLabels
    let font: Font
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLast {
                    Text(labels.getStarted).font(font).foregroundStyle(onAccent).transition(.opacity)
                } else {
                    Image(systemName: "arrow.forward").font(.system(size: 20, weight: .bold)).foregroundStyle(onAccent).transition(.opacity)
                }
            }
            .frame(maxWidth: isLast ? .infinity : 56)
            .frame(height: 56)
            .background(Capsule().fill(accent))
            .padding(isLast ? 0 : 7)
            .overlay {
                if !isLast {
                    ZStack {
                        Circle().stroke(accent.opacity(0.2), lineWidth: 3)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }
                    .transition(.opacity)
                }
            }
        }
        .buttonStyle(OnboardingPressStyle())
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isLast)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: progress)
        .accessibilityLabel(isLast ? labels.getStarted : labels.next)
    }
}
