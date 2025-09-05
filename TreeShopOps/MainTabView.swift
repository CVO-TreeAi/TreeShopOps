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
            // Leads Tab
            NavigationView {
                LeadListView()
                    .environmentObject(leadManager)
            }
            .tabItem {
                Label("Leads", systemImage: "person.crop.circle.badge.plus")
            }
            
            // Proposals Tab
            NavigationView {
                ProposalListView()
                    .environmentObject(proposalManager)
                    .environmentObject(leadManager)
            }
            .tabItem {
                Label("Proposals", systemImage: "doc.text.fill")
            }
            
            // Work Orders Tab
            NavigationView {
                WorkOrderListView()
                    .environmentObject(workOrderManager)
            }
            .tabItem {
                Label("Work Orders", systemImage: "hammer.fill")
            }
            
            // Invoices Tab
            NavigationView {
                InvoiceListView()
                    .environmentObject(invoiceManager)
            }
            .tabItem {
                Label("Invoices", systemImage: "dollarsign.square.fill")
            }
            
            // Customers Tab
            NavigationView {
                CustomerListView()
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Customers", systemImage: "person.2.fill")
            }
            
            // Settings Tab
            NavigationView {
                SettingsMainView(pricingModel: pricingModel)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .accentColor(Color("TreeShopGreen"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}