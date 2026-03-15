//
//  TLCExamAceApp.swift
//  TLCExamAce
//
//  Main app entry point with SwiftData, StoreKit 2, and SDK integrations
//

import SwiftUI
import SwiftData

@main
struct TLCExamAceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let modelContainer: ModelContainer
    @State private var appState = AppStateManager()
    @State private var storeKit = StoreKitManager()

    init() {
        do {
            let schema = Schema([
                UserProfile.self,
                ExamSession.self,
                TopicProgress.self,
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(storeKit)
                .onAppear {
                    Task {
                        await storeKit.updatePurchasedProducts()
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if DEBUG
        print("[TLCExamAce] App launched")
        #endif

        // Initialize Analytics
        Task { @MainActor in
            AnalyticsService.shared.initialize()
            AnalyticsService.shared.track(.appOpen)
        }

        // Request ATT permission after short delay
        Task { @MainActor in
            _ = await ATTService.shared.requestIfNeeded()
        }

        return true
    }
}

// MARK: - App State Manager
@MainActor
@Observable
class AppStateManager {
    var hasCompletedOnboarding: Bool
    var selectedLanguage: AppLanguage
    var isFirstLaunch: Bool

    private let defaults = UserDefaults.standard

    init() {
        hasCompletedOnboarding = defaults.bool(forKey: "com.appfactory.tlcexamace.onboarding")
        isFirstLaunch = !defaults.bool(forKey: "com.appfactory.tlcexamace.launched")
        let langRaw = defaults.string(forKey: "com.appfactory.tlcexamace.language") ?? AppLanguage.english.rawValue
        selectedLanguage = AppLanguage(rawValue: langRaw) ?? .english
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        isFirstLaunch = false
        defaults.set(true, forKey: "com.appfactory.tlcexamace.onboarding")
        defaults.set(true, forKey: "com.appfactory.tlcexamace.launched")
    }

    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        defaults.set(language.rawValue, forKey: "com.appfactory.tlcexamace.language")
    }
}

// MARK: - App Language
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case chinese = "zh"
    case bengali = "bn"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .chinese: return "中文"
        case .bengali: return "বাংলা"
        }
    }

    var flagEmoji: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .chinese: return "🇨🇳"
        case .bengali: return "🇧🇩"
        }
    }
}
