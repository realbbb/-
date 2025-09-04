//
//  app2App.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI
import SwiftData
import StripePaymentSheet

@main
struct app2App: App {
    @StateObject private var appViewModel = AppViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    // 配置Stripe
                    StripeAPI.defaultPublishableKey = Config.Stripe.publishableKey
                    
                    // 检查用户登录状态
                    appViewModel.checkAuthenticationStatus()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        Group {
            if appViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(appViewModel)
            } else {
                AuthenticationView()
                    .environmentObject(appViewModel)
            }
        }
        .background(MatrixTheme.Colors.background)
        .preferredColorScheme(.dark)
    }
}