import SwiftUI

@main
struct AliaPlannerApp: App {
    @StateObject private var planner = PlannerStore()
    @StateObject private var account = AccountStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if account.isSignedIn {
                    PlannerView()
                } else {
                    AccountView()
                }
            }
                .environmentObject(planner)
                .environmentObject(account)
        }
    }
}
