import SwiftUI

@main
struct TreeShopOpsApp: App {
    @StateObject private var businessConfig = BusinessConfigManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(businessConfig)
        }
    }
}