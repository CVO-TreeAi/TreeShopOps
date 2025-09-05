import SwiftUI

struct MainTabView: View {
    @StateObject private var leadManager = LeadManager()
    @StateObject private var proposalManager = ProposalManager()
    @StateObject private var workOrderManager = WorkOrderManager()
    @StateObject private var invoiceManager = InvoiceManager()
    @StateObject private var customerManager = CustomerManager()
    @StateObject private var pricingModel = PricingModel()
    
    var body: some View {
        TabView {
            // Dashboard Tab (Home)
            NavigationView {
                DashboardView()
                    .environmentObject(leadManager)
                    .environmentObject(proposalManager)
                    .environmentObject(workOrderManager)
                    .environmentObject(invoiceManager)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            
            // Pipeline Tab (combines Leads, Proposals, Work Orders)
            NavigationView {
                PipelineView()
                    .environmentObject(leadManager)
                    .environmentObject(proposalManager)
                    .environmentObject(workOrderManager)
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Pipeline", systemImage: "arrow.right.circle")
            }
            
            // Invoices Tab
            NavigationView {
                InvoiceListView()
                    .environmentObject(invoiceManager)
                    .environmentObject(workOrderManager)
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Invoices", systemImage: "dollarsign.square.fill")
            }
            
            // Customers Tab
            NavigationView {
                CustomerListView()
                    .environmentObject(customerManager)
                    .environmentObject(leadManager)
                    .environmentObject(proposalManager)
                    .environmentObject(workOrderManager)
                    .environmentObject(invoiceManager)
            }
            .tabItem {
                Label("Customers", systemImage: "person.2.fill")
            }
            
            // Menu Tab
            NavigationView {
                MenuView(pricingModel: pricingModel)
            }
            .tabItem {
                Label("Menu", systemImage: "ellipsis")
            }
        }
        .accentColor(Color("TreeShopGreen"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}