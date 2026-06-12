import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(StoreKitService.self) private var storeKitService
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var alertMessage: LocalizedStringKey = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    header
                    features
                    footer
                }
                .padding(.horizontal, Spacing.reg)
            }
            .background { LivelyFloatingBlobsBackground() }
            .toolbar { DismissToolbarButton() }
            .safeAreaBar(edge: .bottom) {
                bottomBar
                    .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { selectDefaultProduct() }
        .alert("Purchase Result", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .tint(.primary)
    }

    private var header: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("Teymia Habit")
                .font(.largeTitle).bold()
                .fontDesign(.rounded)
                .foregroundStyle(headerGradient)

            Text("Premium")
                .font(.footnote)
                .fontWeight(.medium)
                .fontDesign(.serif)
                .foregroundStyle(.onPrimary.gradient)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, Spacing.xxs)
                .background(Color.primary.gradient, in: .capsule)
                .offset(x: Spacing.xs)
        }
    }

    private var headerGradient: LinearGradient {
        LinearGradient(
            colors: [Color.primary, Color.primary.opacity(0.8), .onPrimary.opacity(0.8)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var features: some View {
        VStack(spacing: Spacing.lg) {
            ForEach(PaywallFeature.allFeatures) { feature in
                FeatureRow(feature: feature)
            }
        }
        .padding(Spacing.reg)
        .glassEffect(.clear, in: .rect(cornerRadius: Radius.xxl))
    }

    private var footer: some View {
        VStack(spacing: Spacing.md) {
            Button {
                restorePurchases()
            } label: {
                Text("Restore Purchases")
                    .font( .subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
            }

            legalLinks
        }
        .padding(.top, Spacing.xxl)
    }

    private var legalLinks: some View {
        VStack(spacing: Spacing.reg) {
            Button {
                if let url = URL(string: "https://www.apple.com/family-sharing/") { openURL(url, prefersInApp: true) }
            } label: {
                Label {
                    Text("Supports Family Sharing")
                        .font(.footnote)
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.footnote)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.indigo.gradient, .blue.gradient, .mint.gradient)
                }
            }

            HStack(spacing: Spacing.xxl) {
                Button("Terms of Service") {
                    if let url = URL(
                        string: "https://www.notion.so/Terms-of-Service-204d5178e65a80b89993e555ffd3511f"
                    ) {
                        openURL(url, prefersInApp: true)
                    }
                }

                Button("Privacy Policy") {
                    if let url = URL(string: "https://www.notion.so/Privacy-Policy-1ffd5178e65a80d4b255fd5491fba4a8") {
                        openURL(url, prefersInApp: true)
                    }
                }
            }
            .font( .caption)
            .foregroundStyle(Color.secondary)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: Spacing.reg) {
            ProductsRow(
                products: storeKitService.products,
                selectedProduct: $selectedProduct
            )

            PurchaseButton(
                selectedProduct: selectedProduct,
                isPurchasing: isPurchasing
            ) {
                purchaseSelected()
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.reg)
        .padding(.bottom, Spacing.xs)
    }

    // MARK: - Actions

    private func selectDefaultProduct() {
        guard !storeKitService.products.isEmpty else { return }
        selectedProduct = storeKitService.products.first { $0.id.contains("yearly") }
        ?? storeKitService.products.first
    }

    private func purchaseSelected() {
          guard let product = selectedProduct, !isPurchasing else { return }
          isPurchasing = true

          Task {
              do {
                  let result = try await storeKitService.purchase(product)
                  isPurchasing = false
                  switch result {
                  case .success:
                      await storeKitService.updatePremiumStatus()
                      if storeKitService.isPremium {
                          dismiss()
                      }
                  case .cancelled:
                      break
                  case .pending:
                      alertMessage = "Your purchase is pending approval."
                      showingAlert = true
                  }
              } catch {
                  isPurchasing = false
                  alertMessage = "Purchase failed. Please try again."
                  showingAlert = true
              }
          }
      }

    private func restorePurchases() {
         isPurchasing = true

         Task {
             do {
                 try await storeKitService.restorePurchases()
                 isPurchasing = false
                 await storeKitService.updatePremiumStatus()
                 if storeKitService.isPremium {
                     dismiss()
                 } else {
                     alertMessage = "No previous purchases found."
                     showingAlert = true
                 }
             } catch {
                 isPurchasing = false
                 alertMessage = "Restore failed. No purchases available."
                 showingAlert = true
             }
         }
     }
}

// MARK: - Feature Row
private struct FeatureRow: View {
    let feature: PaywallFeature
    var body: some View {
        HStack(spacing: Spacing.reg) {
            Image(systemName: feature.icon)
                .font(.system(size: IconSize.sm, weight: .medium))
                .frame(size: IconSize.xxl)
                .background(.secondary.opacity(0.1), in: .circle)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(feature.title)
                    .font( .headline)
                    .foregroundStyle(Color.primary)

                if let desc = feature.description {
                    Text(desc)
                        .font( .subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            Spacer()
        }
    }
}

// MARK: - Products Row
private struct ProductsRow: View {
    let products: [Product]
    @Binding var selectedProduct: Product?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(products) { product in
                PricingCardView(
                    product: product,
                    isSelected: selectedProduct?.id == product.id
                ) {
                    withAnimation( Animations.easeInOut) {
                        selectedProduct = product
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedProduct)
    }
}

// MARK: - Pricing Card
private struct PricingCardView: View {
    let product: Product
    let isSelected: Bool
    let action: () -> Void

    private var config: (icon: String, title: LocalizedStringKey) {
        product.paywallConfig
    }

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: Spacing.xs) {
                Image(systemName: config.icon)
                    .font(.system(size: IconSize.xs))
                Text(config.title)
                    .font( .caption)
                    .fontWeight(.semibold)
                Text(product.displayPrice)
                    .font( .headline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
            }
            .foregroundStyle(isSelected ? .onPrimary : .appPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .contentShape(.rect)
            .padding(.horizontal, Spacing.xs)
            .background {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(.white.gradient)
                    .opacity(isSelected ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: Radius.xl))
    }
}

// MARK: - Purchase Button
private struct PurchaseButton: View {
    let selectedProduct: Product?
    let isPurchasing: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                if isPurchasing {
                    ProgressView()
                }

                Text(buttonTitle)
                    .font( .headline)
                    .foregroundStyle(Color.primary.gradient)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .frame(height: TouchTarget.large)
            .contentShape(.capsule)
        }
        .borderBeam(
            border: .white.opacity(0.8),
            beam: [.green, .blue, .purple, .orange, .indigo],
            beamBlur: 15,
            cornerRadius: Radius.xl
        )
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: .capsule)
        .allowsHitTesting(!isPurchasing && selectedProduct != nil)
    }

    private var buttonTitle: LocalizedStringKey {
        if isPurchasing {
            return "Processing..."
        }
        guard let product = selectedProduct else {
            return "Сontinue"
        }
        return product.ctaTitle
    }
}

// MARK: - Helpers

extension Product {
    var paywallConfig: (icon: String, title: LocalizedStringKey) {
        if id.contains("lifetime") {
            return ("infinity", "Lifetime")
        }
        if id.contains("yearly") {
            return ("gift", "Yearly")
        }
        return ("calendar.badge.checkmark", "Monthly")
    }

    var ctaTitle: LocalizedStringKey {
        if id.contains("lifetime") {
            return "Get Lifetime"
        }
        if id.contains("yearly") {
            let monthlyPrice = (price / 12).formatted(.currency(code: priceFormatStyle.currencyCode))
            return "Start 7 days free \(monthlyPrice)"
        }
        return "Subscribe"
    }
}
