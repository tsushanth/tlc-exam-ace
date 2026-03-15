//
//  AnalyticsService.swift
//  TLCExamAce
//

import Foundation

// MARK: - Analytics Event
enum AnalyticsEvent {
    case appOpen
    case onboardingCompleted
    case examStarted(mode: String, category: String?)
    case examCompleted(mode: String, score: Int, passed: Bool)
    case questionAnswered(correct: Bool, category: String)
    case paywallViewed
    case purchaseStarted(productID: String)
    case purchaseCompleted(productID: String)
    case purchaseFailed(productID: String)
    case studySessionStarted(category: String)
    case studySessionCompleted(duration: Double)
    case languageChanged(language: String)
    case shareInvoked

    var name: String {
        switch self {
        case .appOpen: return "app_open"
        case .onboardingCompleted: return "onboarding_completed"
        case .examStarted: return "exam_started"
        case .examCompleted: return "exam_completed"
        case .questionAnswered: return "question_answered"
        case .paywallViewed: return "paywall_viewed"
        case .purchaseStarted: return "purchase_started"
        case .purchaseCompleted: return "purchase_completed"
        case .purchaseFailed: return "purchase_failed"
        case .studySessionStarted: return "study_session_started"
        case .studySessionCompleted: return "study_session_completed"
        case .languageChanged: return "language_changed"
        case .shareInvoked: return "share_invoked"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .examStarted(let mode, let cat):
            var p: [String: Any] = ["mode": mode]
            if let cat { p["category"] = cat }
            return p
        case .examCompleted(let mode, let score, let passed):
            return ["mode": mode, "score": score, "passed": passed]
        case .questionAnswered(let correct, let category):
            return ["correct": correct, "category": category]
        case .purchaseStarted(let id), .purchaseCompleted(let id), .purchaseFailed(let id):
            return ["product_id": id]
        case .studySessionStarted(let cat):
            return ["category": cat]
        case .studySessionCompleted(let dur):
            return ["duration_seconds": dur]
        case .languageChanged(let lang):
            return ["language": lang]
        default:
            return [:]
        }
    }
}

// MARK: - Analytics Service
@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()
    private var isInitialized = false
    private init() {}

    func initialize() {
        guard !isInitialized else { return }
        isInitialized = true
        // Firebase.configure() — add when GoogleService-Info.plist is configured
        #if DEBUG
        print("[Analytics] Initialized (debug mode)")
        #endif
    }

    func track(_ event: AnalyticsEvent) {
        #if DEBUG
        print("[Analytics] \(event.name): \(event.parameters)")
        #endif
        // Analytics.logEvent(event.name, parameters: event.parameters)
    }

    func setUserProperty(_ value: String?, forName name: String) {
        #if DEBUG
        print("[Analytics] SetUserProperty \(name) = \(value ?? "nil")")
        #endif
        // Analytics.setUserProperty(value, forName: name)
    }
}

// MARK: - ATT Service
@MainActor
final class ATTService {
    static let shared = ATTService()
    private init() {}

    func requestIfNeeded() async -> Bool {
        // Import AppTrackingTransparency when adding to project
        // let status = await ATTrackingManager.requestTrackingAuthorization()
        // return status == .authorized
        return false
    }
}
