//
//  MainTabView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var expenseViewModel = ExpenseViewModel()
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    
    var body: some View {
        TabView(selection: $appViewModel.appState.selectedTab) {
            HomeView()
                .environmentObject(appViewModel)
                .environmentObject(expenseViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
                .tag(TabSelection.home)
            
            ExpenseListView()
                .environmentObject(expenseViewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("账单")
                }
                .tag(TabSelection.expenses)
            
            StatisticsView()
                .environmentObject(statisticsViewModel)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("统计")
                }
                .tag(TabSelection.statistics)
            
            SettingsView()
                .environmentObject(appViewModel)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
                .tag(TabSelection.settings)
        }
        .accentColor(MatrixTheme.primaryColor)
        .background(MatrixTheme.backgroundColor)
        .preferredColorScheme(.dark)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(MatrixTheme.surfaceColor)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(MatrixTheme.secondaryTextColor)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(MatrixTheme.secondaryTextColor)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(MatrixTheme.primaryColor)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(MatrixTheme.primaryColor)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @State private var showingVoiceInput = false
    @State private var showingTextInput = false
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Recent Expenses
                        recentExpensesSection
                        
                        // Quick Stats
                        quickStatsSection
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("秋后算账")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    MatrixToolbarButton("person.circle") {
                        // Profile action
                    }
                }
            }
        }
        .sheet(isPresented: $showingVoiceInput) {
            VoiceInputView { audioData in
                expenseViewModel.processAudioExpense(audioData: audioData)
            }
        }
        .sheet(isPresented: $showingTextInput) {
            TextInputView { text in
                expenseViewModel.processTextExpense(text: text)
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
                .environmentObject(expenseViewModel)
        }
    }
    
    private var headerSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("欢迎回来")
                            .font(.title2)
                            .foregroundColor(MatrixTheme.primaryTextColor)
                        
                        if let user = appViewModel.currentUser {
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(MatrixTheme.primaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(MatrixTheme.accentColor)
                }
                
                Text("AI智能记账，让每一笔支出都清晰可见")
                    .font(.caption)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快速记账")
                .font(.headline)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            HStack(spacing: 16) {
                MatrixCyberpunkButton(
                    title: "语音记账",
                    icon: "mic.fill",
                    action: { showingVoiceInput = true }
                )
                
                MatrixCyberpunkButton(
                    title: "文字记账",
                    icon: "text.bubble.fill",
                    action: { showingTextInput = true }
                )
                
                MatrixCyberpunkButton(
                    title: "手动记账",
                    icon: "plus.circle.fill",
                    action: { showingAddExpense = true }
                )
            }
        }
    }
    
    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("最近支出")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Spacer()
                
                NavigationLink("查看全部") {
                    ExpenseListView()
                        .environmentObject(expenseViewModel)
                }
                .font(.caption)
                .foregroundColor(MatrixTheme.accentColor)
            }
            
            if expenseViewModel.expenses.isEmpty {
                MatrixEmptyStateView(
                    icon: "creditcard",
                    title: "暂无支出记录",
                    subtitle: "开始记录您的第一笔支出吧"
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(expenseViewModel.expenses.prefix(3))) { expense in
                        ExpenseRowView(expense: expense)
                    }
                }
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("本月概览")
                .font(.headline)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            let thisMonthExpenses = expenseViewModel.expenses.filter { expense in
                Calendar.current.isDate(expense.date, equalTo: Date(), toGranularity: .month)
            }
            
            let totalAmount = thisMonthExpenses.reduce(0) { $0 + $1.amount }
            let transactionCount = thisMonthExpenses.count
            
            HStack(spacing: 16) {
                MatrixStatCard(
                    title: "总支出",
                    value: String(format: "¥%.2f", totalAmount),
                    icon: "yensign.circle.fill",
                    color: MatrixTheme.errorColor
                )
                
                MatrixStatCard(
                    title: "笔数",
                    value: "\(transactionCount)",
                    icon: "number.circle.fill",
                    color: MatrixTheme.accentColor
                )
            }
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}