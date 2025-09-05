import SwiftUI

struct MainTabView: View {
    @StateObject private var customerManager = CustomerManager()
    @StateObject private var proposalManager = ProposalManager()
    
    var body: some View {
        TabView {
            // Pricing Tab
            ContentView()
                .environmentObject(customerManager)
                .environmentObject(proposalManager)
                .tabItem {
                    Label("Pricing", systemImage: "dollarsign.circle.fill")
                }
            
            // Proposals Tab
            NavigationView {
                ProposalListView()
                    .environmentObject(proposalManager)
            }
            .tabItem {
                Label("Proposals", systemImage: "doc.text.fill")
            }
            
            // Customers Tab
            NavigationView {
                CustomerListView()
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Customers", systemImage: "person.2.fill")
            }
        }
        .accentColor(Color("TreeShopGreen"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}