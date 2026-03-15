//
//  PaywallView.swift
//  TLCExamAce
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product? = nil
    @State private var isPurchasing: Bool = false
    @State private var errorMessage: String? = nil

    let features: [(icon: String, title: String, subtitle: String)] = [
        ("timer", "Full Timed Exam Mode", "Simulate the real TLC exam experience"),
        ("exclamationmark.circle.fill", "Weak Area Training", "AI-powered personalized practice"),
        ("globe", "All Languages", "English, Spanish, Chinese & Bengali"),
        ("list.bullet.rectangle.fill", "Complete Question Bank", "500+ real TLC exam questions"),
        ("chart.bar.fill", "Detailed Analytics", "Track every topic and category"),
        ("infinity", "Unlimited Tests", "Practice as much as you need"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    productsSection
                    footerSection
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(TLCColors.surface)
            .navigationTitle("Go Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            AnalyticsService.shared.track(.paywallViewed)
            if storeKit.subscriptions.isEmpty {
                Task { await storeKit.loadProducts() }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(TLCColors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "car.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(TLCColors.primary)
            }
            Text("Pass Your TLC Exam")
                .font(.title.bold())
            Text("Unlock the full question bank, timed exams, and multilingual support.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    // MARK: - Features
    private var featuresSection: some View {
        VStack(spacing: 12) {
            ForEach(features, id: \.title) { feature in
                HStack(spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.title3)
                        .foregroundStyle(TLCColors.primary)
                        .frame(width: 36, height: 36)
                        .background(TLCColors.primary.opacity(0.1))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.subheadline.bold())
                        Text(feature.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(TLCColors.success)
                }
            }
        }
        .padding()
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Products
    private var productsSection: some View {
        VStack(spacing: 12) {
            if storeKit.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if storeKit.allProducts.isEmpty {
                Text("Unable to load products. Please check your connection.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ForEach(storeKit.allProducts, id: \.id) { product in
                    ProductCard(
                        product: product,
                        isSelected: selectedProduct?.id == product.id
                    ) {
                        selectedProduct = product
                    }
                }
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(TLCColors.danger)
                    .multilineTextAlignment(.center)
            }

            if let product = selectedProduct ?? storeKit.allProducts.first {
                Button {
                    Task { await purchase(product) }
                } label: {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Subscribe \(product.displayPrice) \(product.periodLabel)")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isPurchasing)
            }

            Button {
                Task { await storeKit.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(.caption)
                    .foregroundStyle(TLCColors.primary)
            }
        }
    }

    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 6) {
            Text("Cancel anytime. Subscription auto-renews unless cancelled at least 24 hours before renewal date.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                Button("Privacy Policy") { }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Button("Terms of Service") { }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Purchase
    private func purchase(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil
        AnalyticsService.shared.track(.purchaseStarted(productID: product.id))
        do {
            _ = try await storeKit.purchase(product)
            AnalyticsService.shared.track(.purchaseCompleted(productID: product.id))
            dismiss()
        } catch StoreKitError.userCancelled {
            // No error shown for user cancellation
        } catch {
            errorMessage = error.localizedDescription
            AnalyticsService.shared.track(.purchaseFailed(productID: product.id))
        }
        isPurchasing = false
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(.subheadline.bold())
                        if product.isPopular {
                            Text("BEST VALUE")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(TLCColors.accent)
                                .foregroundStyle(.black)
                                .clipShape(Capsule())
                        }
                    }
                    if let savings = product.savingsLabel {
                        Text(savings)
                            .font(.caption)
                            .foregroundStyle(TLCColors.success)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.headline.bold())
                    Text(product.periodLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(isSelected ? TLCColors.primary.opacity(0.08) : TLCColors.cardBG)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? TLCColors.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .foregroundStyle(.primary)
    }
}
