//
//  ContentView.swift
//  TLCExamAce
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppStateManager.self) private var appState
    @Environment(StoreKitManager.self) private var storeKit
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home, study, exam, progress, settings

        var title: String {
            switch self {
            case .home: return "Home"
            case .study: return "Study"
            case .exam: return "Exam"
            case .progress: return "Progress"
            case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .study: return "book.fill"
            case .exam: return "pencil.and.list.clipboard"
            case .progress: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label(Tab.home.title, systemImage: Tab.home.icon) }
                .tag(Tab.home)

            StudyView()
                .tabItem { Label(Tab.study.title, systemImage: Tab.study.icon) }
                .tag(Tab.study)

            ExamView()
                .tabItem { Label(Tab.exam.title, systemImage: Tab.exam.icon) }
                .tag(Tab.exam)

            TLCProgressView()
                .tabItem { Label(Tab.progress.title, systemImage: Tab.progress.icon) }
                .tag(Tab.progress)

            SettingsView()
                .tabItem { Label(Tab.settings.title, systemImage: Tab.settings.icon) }
                .tag(Tab.settings)
        }
        .tint(TLCColors.primary)
    }
}

// MARK: - Design System
enum TLCColors {
    static let primary = Color(red: 0.0, green: 0.36, blue: 0.80)       // NYC taxi blue
    static let accent = Color(red: 0.98, green: 0.76, blue: 0.0)        // NYC taxi yellow
    static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let danger = Color(red: 0.95, green: 0.27, blue: 0.27)
    static let warning = Color(red: 1.0, green: 0.62, blue: 0.0)
    static let surface = Color(UIColor.secondarySystemBackground)
    static let cardBG = Color(UIColor.systemBackground)
}

#Preview {
    ContentView()
        .environment(AppStateManager())
        .environment(StoreKitManager())
}
