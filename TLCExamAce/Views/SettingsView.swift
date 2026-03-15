//
//  SettingsView.swift
//  TLCExamAce
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppStateManager.self) private var appState
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.modelContext) private var context

    @State private var showPaywall = false
    @State private var showResetAlert = false
    @State private var dailyGoal: Int = 20
    @State private var notificationsEnabled: Bool = false
    @State private var examDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var showExamDatePicker = false

    var body: some View {
        NavigationStack {
            List {
                premiumSection
                studyPreferencesSection
                languageSection
                notificationsSection
                aboutSection
                dangerZoneSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .alert("Reset All Progress?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { resetProgress() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all your exam history and progress. This cannot be undone.")
        }
    }

    // MARK: - Premium Section
    private var premiumSection: some View {
        Section {
            if storeKit.isPremium {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(TLCColors.accent)
                    Text("Premium Active")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("Active")
                        .font(.caption.bold())
                        .foregroundStyle(TLCColors.success)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(TLCColors.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Premium")
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            Text("Unlock all features")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }

            Button("Restore Purchases") {
                Task { await storeKit.restorePurchases() }
            }
        } header: {
            Text("Subscription")
        }
    }

    // MARK: - Study Preferences
    private var studyPreferencesSection: some View {
        Section("Study Preferences") {
            Stepper("Daily Goal: \(dailyGoal) min", value: $dailyGoal, in: 5...120, step: 5)

            Button {
                showExamDatePicker.toggle()
            } label: {
                HStack {
                    Text("Exam Date")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(examDate, style: .date)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }

            if showExamDatePicker {
                DatePicker("", selection: $examDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
        }
    }

    // MARK: - Language
    private var languageSection: some View {
        Section("Language") {
            ForEach(AppLanguage.allCases) { language in
                let isLocked = language != .english && !storeKit.isPremium
                Button {
                    if isLocked {
                        showPaywall = true
                    } else {
                        appState.setLanguage(language)
                    }
                } label: {
                    HStack {
                        Text(language.flagEmoji)
                        Text(language.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(TLCColors.accent)
                                .font(.caption)
                        } else if appState.selectedLanguage == language {
                            Image(systemName: "checkmark")
                                .foregroundStyle(TLCColors.primary)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Notifications
    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Daily Study Reminder", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, enabled in
                    if enabled {
                        Task { await NotificationManager.shared.requestPermission() }
                    } else {
                        NotificationManager.shared.cancelAllNotifications()
                    }
                }
        }
    }

    // MARK: - About
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }

            Button("Rate TLC Exam Ace") {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id") {
                    UIApplication.shared.open(url)
                }
            }

            Button("Share App") {
                AnalyticsService.shared.track(.shareInvoked)
            }

            Link("Privacy Policy", destination: URL(string: "https://appfactory.com/privacy")!)
            Link("Terms of Service", destination: URL(string: "https://appfactory.com/terms")!)
        }
    }

    // MARK: - Danger Zone
    private var dangerZoneSection: some View {
        Section("Data") {
            Button("Reset All Progress", role: .destructive) {
                showResetAlert = true
            }
        }
    }

    // MARK: - Reset
    private func resetProgress() {
        let sessionDesc = FetchDescriptor<ExamSession>()
        let progressDesc = FetchDescriptor<TopicProgress>()

        if let sessions = try? context.fetch(sessionDesc) {
            sessions.forEach { context.delete($0) }
        }
        if let progress = try? context.fetch(progressDesc) {
            progress.forEach { context.delete($0) }
        }
        try? context.save()
    }
}
