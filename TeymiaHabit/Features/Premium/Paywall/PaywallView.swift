import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    @State private var vm: PaywallViewModel?

    var body: some View {
        Group {
            if let vm {
                PaywallContentView(vm: vm)
            }
        }
        .task {
            guard vm == nil else { return }
            vm = PaywallViewModel(storeKitService: appContainer.storeKitService)
        }
    }
}

// MARK: - Main Content View
private struct PaywallContentView: View {
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
                .padding(.horizontal, DS.Spacing.lg)
            }
            .background { LivelyFloatingBlobsBackground() }
            .toolbar { CloseToolbarButton() }
            .safeAreaBar(edge: .bottom) { bottomBar }
        }
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
                .font(DS.AppFont.largeTitle).fontDesign(.rounded)
                .foregroundStyle(UIStyle.headerGradient)
                
            Text("Premium")
                .font(DS.AppFont.footnoteMedium).fontDesign(.serif)
                .foregroundStyle(DS.Colors.onPrimary.gradient)
                .padding(.horizontal, DS.Spacing.xs)
                .padding(.vertical, DS.Spacing.xxs)
                .background(DS.Colors.primary.gradient, in: .capsule)
                .offset(x: DS.Spacing.xs)
        }
    }
    
    private var features: some View {
        VStack(spacing: DS.Spacing.lg) {
            ForEach(PaywallFeature.allFeatures) { feature in
                FeatureRow(feature: feature)
            }
        }
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
                isPurchasing: vm.isPurchasing,
                isLoading: vm.products.isEmpty
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
            if products.isEmpty {
                ForEach(0..<3, id: \.self) { _ in
                    PricingCardView(state: .skeleton)
                }
            } else {
                ForEach(products) { product in
                    PricingCardView(state: .data(product, isSelected: selectedProduct?.id == product.id)) {
                        selectedProduct = product
                    }
                }
            }
        }
    }
}

// MARK: - Pricing Card
private struct PricingCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let state: State
    var action: (() -> Void)? = nil
    
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        Button { action?() } label: {
            VStack(spacing: DS.Spacing.xs) {
                content
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding(.horizontal, DS.Spacing.xs)
            .contentShape(.rect(cornerRadius: DS.Radius.xl))
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: DS.Radius.xl))
        .overlay {
                if case let .data(_, isSelected) = state, isSelected {
                    RoundedRectangle(cornerRadius: DS.Radius.xl)
                        .stroke(DS.Colors.primary.gradient, lineWidth: 2)
                }
            }
        .animation(DS.Animations.easeInOut, value: isSelected)
        .allowsHitTesting(!isSkeleton)
        .shimmer(.init(
            highlight: .white,
            blur: 20,
            highlightOpacity: isDark ? 0.4 : 1,
            delay: isSkeleton ? 0 : 1.7
        ))
        .contentShape(.rect(cornerRadius: DS.Radius.xl))
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .skeleton:
            Capsule().fill(DS.Colors.secondary.opacity(0.2)).frame(width: 40, height: 12)
            Capsule().fill(DS.Colors.secondary.opacity(0.2)).frame(width: 60, height: 12)
            Capsule().fill(DS.Colors.secondary.opacity(0.2)).frame(width: 70, height: 12)
        case .data(let product, _):
            let config = product.paywallConfig
            Image(systemName: config.icon)
                .font(.system(size: DS.IconSize.xs))
                .foregroundStyle(DS.Colors.primary)
            Text(config.title)
                .font(DS.AppFont.caption).fontWeight(.semibold)
                .foregroundStyle(DS.Colors.primary)
            Text(product.displayPrice)
                .font(DS.AppFont.headline).fontWeight(.bold)
                .fontDesign(.monospaced)
                .foregroundStyle(DS.Colors.primary)
        }
    }
    
    // State
    enum State {
        case skeleton
        case data(Product, isSelected: Bool)
        
        var check: Bool {
            if case .skeleton = self { return true }
            return false
        }
    }
    
    private var isSkeleton: Bool { state.check }
    private var isSelected: Bool {
        if case let.data(_, selected) = state { return selected }
        return false
    }
}

// MARK: - Purchase Button
private struct PurchaseButton: View {
    let selectedProduct: Product?
    let isPurchasing: Bool
    let isLoading: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.Spacing.sm) {
                if isPurchasing {
                    ProgressView()
                }
                
                if isLoading {
                    Capsule()
                        .fill(DS.Colors.secondary.opacity(0.2))
                        .frame(width: 280, height: 24)
                } else {
                    Text(buttonTitle)
                        .font(DS.AppFont.headline)
                        .foregroundStyle(DS.Colors.primary.gradient)
                }
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
        .glassEffect(.regular.interactive(), in: .capsule)
        .allowsHitTesting(!isLoading && !isPurchasing && selectedProduct != nil)
        .overlay {
            if isLoading {
                Color.clear
                    .shimmer(ShimmerConfig(highlight: DS.Colors.primary, blur: 40, highlightOpacity: 0.3, delay: 0))
            }
        }
    }

    private var buttonTitle: LocalizedStringResource {
        if isPurchasing { return "paywall_processing_button" }
        guard let product = selectedProduct else { return "paywall_continue" }
        return product.ctaTitle
    }
}

// MARK: - Helpers & Logic Extensions

private enum UIStyle {
    static let headerGradient = LinearGradient(
        colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.8), DS.Colors.onPrimary.opacity(0.8)],
        startPoint: .top, endPoint: .bottom
    )
}

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
