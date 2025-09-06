import SwiftUI

// MARK: - Shared State Container
class AppStateManager: ObservableObject {
    @Published var leadManager = LeadManager()
    @Published var proposalManager = ProposalManager()
    @Published var workOrderManager = WorkOrderManager()
    @Published var invoiceManager = InvoiceManager()
    @Published var customerManager = CustomerManager()
    @Published var pricingModel = PricingModel()
    
    private var dataLoadTask: Task<Void, Never>?
    
    init() {
        // Initialize in background to prevent UI blocking
        dataLoadTask = Task.detached(priority: .userInitiated) { [weak self] in
            await self?.preloadData()
        }
    }
    
    deinit {
        dataLoadTask?.cancel()
    }
    
    @MainActor
    private func preloadData() async {
        // Pre-load data in background to improve initial performance
        // This ensures data is available when views first appear
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                _ = await self?.leadManager.leads
            }
            group.addTask { [weak self] in
                _ = await self?.proposalManager.proposals
            }
            group.addTask { [weak self] in
                _ = await self?.workOrderManager.workOrders
            }
            group.addTask { [weak self] in
                _ = await self?.invoiceManager.invoices
            }
            group.addTask { [weak self] in
                _ = await self?.customerManager.customers
            }
        }
    }
}

struct MainTabView: View {
    @StateObject private var appState = AppStateManager()
    
    var body: some View {
        TabView {
            // Dashboard Tab (Home) - Minimal environment objects
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            
            // Pipeline Tab
            NavigationView {
                PipelineView()
            }
            .tabItem {
                Label("Pipeline", systemImage: "arrow.right.circle")
            }
            
            // Invoices Tab
            NavigationView {
                InvoiceListView()
            }
            .tabItem {
                Label("Invoices", systemImage: "dollarsign.square.fill")
            }
            
            // Customers Tab
            NavigationView {
                CustomerListView()
            }
            .tabItem {
                Label("Customers", systemImage: "person.2.fill")
            }
            
            // Menu Tab
            NavigationView {
                MenuView(pricingModel: appState.pricingModel)
            }
            .tabItem {
                Label("Menu", systemImage: "ellipsis")
            }
        }
        .environmentObject(appState)
        .accentColor(Color("TreeShopGreen"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}