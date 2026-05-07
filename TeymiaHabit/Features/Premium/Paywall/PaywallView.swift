import SwiftUI
import StoreKit

struct PaywallView: View {
    @State private var vm: PaywallViewModel

    init(storeKitService: StoreKitService) {
        _vm = State(
            initialValue: PaywallViewModel(storeKitService: storeKitService)
        )
    }

    var body: some View {
        PaywallContentView(vm: vm)
    }
}

// MARK: - Main Content View
struct PaywallContentView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: PaywallViewModel

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DS.Spacing.xl) {
                    header
                    features
                    footer
                }
                .padding(.horizontal, DS.Spacing.reg)
            }
            .background {
                LivelyFloatingBlobsBackground()
            }
            .toolbar {
                CloseToolbarButton()
            }
            .safeAreaBar(edge: .bottom) {
                bottomBar
                    .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { vm.selectDefaultProduct() }
        .alert("paywall_purchase_result_title", isPresented: $vm.showingAlert) {
            Button("paywall_ok_button") {}
        } message: {
            Text(vm.alertMessage)
        }
        .tint(DS.Colors.primary)
    }

    private var header: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("Teymia Habit")
                .font(DS.AppFont.largeTitle)
                .fontDesign(.rounded)
                .foregroundStyle(headerGradient)

            Text("Premium")
                .font(DS.AppFont.footnoteMedium)
                .fontDesign(.serif)
                .foregroundStyle(DS.Colors.onPrimary.gradient)
                .padding(.horizontal, DS.Spacing.xs)
                .padding(.vertical, DS.Spacing.xxs)
                .background(DS.Colors.primary.gradient, in: .capsule)
                .offset(x: DS.Spacing.xs)
        }
    }

    private var headerGradient: LinearGradient {
        LinearGradient(
            colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.8), DS.Colors.onPrimary.opacity(0.8)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var features: some View {
        VStack(spacing: DS.Spacing.lg) {
            ForEach(PaywallFeature.allFeatures) { feature in
                FeatureRow(feature: feature)
            }
        }
        .padding(DS.Spacing.reg)
        .glassEffect(.clear, in: .rect(cornerRadius: DS.Radius.xxl))
    }

    private var footer: some View {
        VStack(spacing: DS.Spacing.md) {
            Button {
                vm.restorePurchases { dismiss() }
            } label: {
                Text("paywall_restore_purchases_button")
                    .font(DS.AppFont.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DS.Colors.primary)
            }

            legalLinks
        }
        .padding(.top, DS.Spacing.xxl)
    }

    private var legalLinks: some View {
        VStack(spacing: DS.Spacing.reg) {
            Button {
                if let url = URL(string: "https://www.apple.com/family-sharing/") { openURL(url, prefersInApp: true) }
            } label: {
                Label {
                    Text("paywall_family_sharing_button")
                        .font(DS.AppFont.footnoteMedium)
                        .foregroundStyle(DS.Colors.primary)
                } icon: {
                    Image(systemName: "person.3.sequence.fill")
                        .font(DS.AppFont.footnoteMedium)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.indigo.gradient, .blue.gradient, .mint.gradient)
                }
            }

            HStack(spacing: DS.Spacing.xxl) {
                Button("paywall_terms_of_service") {
                    if let url = URL(
                        string: "https://www.notion.so/Terms-of-Service-204d5178e65a80b89993e555ffd3511f"
                    ) {
                        openURL(url, prefersInApp: true)
                    }
                }

                Button("paywall_privacy_policy") {
                    if let url = URL(string: "https://www.notion.so/Privacy-Policy-1ffd5178e65a80d4b255fd5491fba4a8") {
                        openURL(url, prefersInApp: true)
                    }
                }
            }
            .font(DS.AppFont.caption)
            .foregroundStyle(DS.Colors.secondary)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: DS.Spacing.reg) {
            ProductsRow(
                products: vm.products,
                selectedProduct: $vm.selectedProduct
            )

            PurchaseButton(
                selectedProduct: vm.selectedProduct,
                isPurchasing: vm.isPurchasing
            ) {
                vm.purchaseSelected { dismiss() }
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.reg)
        .padding(.bottom, DS.Spacing.xs)
    }
}

// MARK: - Feature Row
private struct FeatureRow: View {
    let feature: PaywallFeature
    var body: some View {
        HStack(spacing: DS.Spacing.reg) {
            Image(systemName: feature.icon)
                .font(.system(size: DS.IconSize.sm, weight: .medium))
                .frame(width: DS.IconSize.xxl, height: DS.IconSize.xxl)
                .background(DS.Colors.secondary.opacity(0.1), in: .circle)

            VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                Text(feature.title)
                    .font(DS.AppFont.headline)
                    .foregroundStyle(DS.Colors.primary)

                if let desc = feature.description {
                    Text(desc)
                        .font(DS.AppFont.subheadline)
                        .foregroundStyle(DS.Colors.secondary)
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
        HStack(spacing: DS.Spacing.sm) {
            ForEach(products) { product in
                PricingCardView(
                    product: product,
                    isSelected: selectedProduct?.id == product.id
                ) {
                    withAnimation(DS.Animations.easeInOut) {
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

    private var config: (icon: String, title: LocalizedStringResource) {
        product.paywallConfig
    }

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: config.icon)
                    .font(.system(size: DS.IconSize.xs))
                Text(config.title)
                    .font(DS.AppFont.caption)
                    .fontWeight(.semibold)
                Text(product.displayPrice)
                    .font(DS.AppFont.headline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
            }
            .foregroundStyle(isSelected ? DS.Colors.onPrimary : DS.Colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .contentShape(.rect)
            .padding(.horizontal, DS.Spacing.xs)
            .background {
                RoundedRectangle(cornerRadius: DS.Radius.xl)
                    .fill(.white.gradient)
                    .opacity(isSelected ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: DS.Radius.xl))
    }
}

// MARK: - Purchase Button
private struct PurchaseButton: View {
    let selectedProduct: Product?
    let isPurchasing: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.Spacing.sm) {
                if isPurchasing {
                    ProgressView()
                }

                Text(buttonTitle)
                    .font(DS.AppFont.headline)
                    .foregroundStyle(DS.Colors.primary.gradient)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .frame(height: DS.TouchTarget.large)
            .contentShape(.capsule)
        }
        .borderBeam(
            border: .white.opacity(0.8),
            beam: [.green, .blue, .purple, .orange, .indigo],
            beamBlur: 15,
            cornerRadius: DS.Radius.xl
        )
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: .capsule)
        .allowsHitTesting(!isPurchasing && selectedProduct != nil)
    }

    private var buttonTitle: LocalizedStringResource {
        if isPurchasing { return "paywall_processing_button" }
        guard let product = selectedProduct else { return "paywall_continue" }
        return product.ctaTitle
    }
}

// MARK: - Helpers

extension Product {
    var paywallConfig: (icon: String, title: LocalizedStringResource) {
        if id.contains("lifetime") { return ("infinity", "paywall_lifetime_plan") }
        if id.contains("yearly") { return ("gift", "paywall_yearly_plan") }
        return ("calendar.badge.checkmark", "paywall_monthly_plan")
    }

    var ctaTitle: LocalizedStringResource {
        if id.contains("lifetime") { return "paywall_lifetime_cta" }
        if id.contains("yearly") {
            let monthlyPrice = (price / 12).formatted(.currency(code: priceFormatStyle.currencyCode))
            return "paywall_start_trial_monthly \(monthlyPrice)"
        }
        return "paywall_subscribe_cta"
    }
}

#Preview {
    let container = PreviewContainer.container
    let appContainer = AppDependencyContainer(modelContext: container.mainContext)
    let vm = PaywallViewModel(storeKitService: appContainer.storeKitService)

    PaywallContentView(vm: vm)
        .environment(appContainer)
        .modelContainer(container)
}

