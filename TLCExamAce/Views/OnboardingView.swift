//
//  OnboardingView.swift
//  TLCExamAce
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppStateManager.self) private var appState
    @State private var currentPage: Int = 0
    @State private var selectedLicense: LicenseType = .fhv
    @State private var selectedLanguage: AppLanguage = .english

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "car.fill",
            iconColor: .blue,
            title: "Pass Your TLC Exam",
            subtitle: "Practice with 500+ real TLC exam questions covering NYC geography, laws, and regulations.",
            bgColor: Color.blue.opacity(0.08)
        ),
        OnboardingPage(
            icon: "timer",
            iconColor: .orange,
            title: "Timed Exam Simulation",
            subtitle: "Experience the real exam pressure with our timed practice mode. 40 questions, 60 minutes.",
            bgColor: Color.orange.opacity(0.08)
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            iconColor: .green,
            title: "Track Your Progress",
            subtitle: "See your weak areas, track improvement, and know when you're ready to test.",
            bgColor: Color.green.opacity(0.08)
        ),
        OnboardingPage(
            icon: "globe",
            iconColor: .purple,
            title: "Study in Your Language",
            subtitle: "Practice in English, Spanish, Chinese, or Bengali.",
            bgColor: Color.purple.opacity(0.08)
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { idx in
                    OnboardingPageView(page: pages[idx])
                        .tag(idx)
                }

                // Final setup page
                setupPage.tag(pages.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<(pages.count + 1), id: \.self) { idx in
                    Circle()
                        .fill(idx == currentPage ? TLCColors.primary : Color.gray.opacity(0.3))
                        .frame(width: idx == currentPage ? 10 : 6, height: idx == currentPage ? 10 : 6)
                        .animation(.spring(), value: currentPage)
                }
            }
            .padding(.vertical, 16)

            // CTA Button
            Button {
                if currentPage < pages.count {
                    withAnimation { currentPage += 1 }
                } else {
                    finishOnboarding()
                }
            } label: {
                Text(currentPage < pages.count ? "Continue" : "Get Started")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 40)

            if currentPage < pages.count {
                Button("Skip") {
                    withAnimation { currentPage = pages.count }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
            }
        }
        .background(TLCColors.surface)
    }

    private var setupPage: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(TLCColors.primary)
                    Text("Quick Setup")
                        .font(.title.bold())
                    Text("Personalize your experience")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // License Type
                VStack(alignment: .leading, spacing: 12) {
                    Text("Which license are you studying for?")
                        .font(.headline)

                    ForEach([LicenseType.fhv, .taxi, .lpep], id: \.self) { type in
                        Button {
                            selectedLicense = type
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(type.rawValue)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.primary)
                                    Text(type.fullName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedLicense == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(TLCColors.primary)
                                }
                            }
                            .padding(14)
                            .background(selectedLicense == type ? TLCColors.primary.opacity(0.08) : TLCColors.cardBG)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedLicense == type ? TLCColors.primary : Color.clear, lineWidth: 1.5))
                        }
                    }
                }

                // Language
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preferred language")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(AppLanguage.allCases) { lang in
                            Button {
                                selectedLanguage = lang
                            } label: {
                                HStack {
                                    Text(lang.flagEmoji)
                                    Text(lang.displayName)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selectedLanguage == lang {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(TLCColors.primary)
                                            .font(.caption)
                                    }
                                }
                                .padding(12)
                                .background(selectedLanguage == lang ? TLCColors.primary.opacity(0.08) : TLCColors.cardBG)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedLanguage == lang ? TLCColors.primary : Color.clear, lineWidth: 1.5))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }

    private func finishOnboarding() {
        appState.setLanguage(selectedLanguage)
        Task { @MainActor in
            await NotificationManager.shared.requestPermission()
        }
        AnalyticsService.shared.track(.onboardingCompleted)
        appState.completeOnboarding()
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let bgColor: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(page.bgColor)
                    .frame(width: 150, height: 150)
                Image(systemName: page.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(page.iconColor)
            }
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
