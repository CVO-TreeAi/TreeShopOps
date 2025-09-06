import SwiftUI

// MARK: - Shared State Container
class AppStateManager: ObservableObject {
    @Published var leadManager = LeadManager()
    @Published var proposalManager = ProposalManager()
    @Published var workOrderManager = WorkOrderManager()
    @Published var invoiceManager = InvoiceManager()
    @Published var customerManager = CustomerManager()
    @Published var pricingModel = PricingModel()
    
    
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