//
//  ExpenseListView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @State private var showingAddExpense = false
    @State private var showingFilters = false
    @State private var selectedExpense: ExpenseData?
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                VStack(spacing: 0) {
                    // Search and Filter Bar
                    searchAndFilterBar
                    
                    // Expense List
                    expenseList
                }
            }
            .navigationTitle("支出记录")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(MatrixTheme.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
                .environmentObject(expenseViewModel)
        }
        .sheet(isPresented: $showingFilters) {
            FilterView()
                .environmentObject(expenseViewModel)
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseDetailView(expense: expense)
                .environmentObject(expenseViewModel)
        }
        .refreshable {
            expenseViewModel.loadExpenses()
        }
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(MatrixTheme.secondaryTextColor)
                
                TextField("搜索支出记录", text: $expenseViewModel.searchText)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !expenseViewModel.searchText.isEmpty {
                    Button(action: {
                        expenseViewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(MatrixTheme.secondaryTextColor)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(MatrixTheme.surfaceColor)
            .cornerRadius(MatrixTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                    .stroke(MatrixTheme.borderColor, lineWidth: 1)
            )
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Category Filter
                    if let selectedCategory = expenseViewModel.selectedCategory {
                        MatrixFilterChip(
                            title: selectedCategory.displayName,
                            icon: selectedCategory.icon,
                            isSelected: true
                        ) {
                            expenseViewModel.selectedCategory = nil
                        }
                    }
                    
                    // Date Range Filter
                    if expenseViewModel.dateRange != nil {
                        MatrixFilterChip(
                            title: "日期范围",
                            icon: "calendar",
                            isSelected: true
                        ) {
                            expenseViewModel.dateRange = nil
                        }
                    }
                    
                    // Filter Button
                    Button(action: {
                        showingFilters = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("筛选")
                        }
                        .font(.caption)
                        .foregroundColor(MatrixTheme.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(MatrixTheme.surfaceColor)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(MatrixTheme.accentColor, lineWidth: 1)
                        )
                    }
                    
                    // Clear All Filters
                    if expenseViewModel.selectedCategory != nil || expenseViewModel.dateRange != nil {
                        Button(action: {
                            expenseViewModel.clearFilters()
                        }) {
                            Text("清除")
                                .font(.caption)
                                .foregroundColor(MatrixTheme.errorColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(MatrixTheme.surfaceColor)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(MatrixTheme.errorColor, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var expenseList: some View {
        Group {
            if expenseViewModel.isLoading {
                MatrixLoadingView(message: "加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if expenseViewModel.filteredExpenses.isEmpty {
                MatrixEmptyStateView(
                    icon: "creditcard",
                    title: expenseViewModel.expenses.isEmpty ? "暂无支出记录" : "没有找到匹配的记录",
                    subtitle: expenseViewModel.expenses.isEmpty ? "开始记录您的第一笔支出吧" : "尝试调整筛选条件"
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(expenseViewModel.filteredExpenses) { expense in
                        ExpenseRowView(expense: expense)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                selectedExpense = expense
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("删除") {
                                    expenseViewModel.deleteExpense(expense)
                                }
                                .tint(MatrixTheme.errorColor)
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
        }
    }
}

// MARK: - Filter View

struct FilterView: View {
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempSelectedCategory: ExpenseCategory?
    @State private var tempDateRange: ClosedRange<Date>?
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Category Filter
                        categoryFilterSection
                        
                        // Date Range Filter
                        dateRangeFilterSection
                    }
                    .padding()
                }
            }
            .navigationTitle("筛选条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("应用") {
                        applyFilters()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
            }
        }
        .onAppear {
            tempSelectedCategory = expenseViewModel.selectedCategory
            tempDateRange = expenseViewModel.dateRange
            if let range = tempDateRange {
                startDate = range.lowerBound
                endDate = range.upperBound
            }
        }
    }
    
    private var categoryFilterSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("分类筛选")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        Button(action: {
                            if tempSelectedCategory == category {
                                tempSelectedCategory = nil
                            } else {
                                tempSelectedCategory = category
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: category.icon)
                                    .font(.title2)
                                    .foregroundColor(category.color)
                                
                                Text(category.displayName)
                                    .font(.caption)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(tempSelectedCategory == category ? MatrixTheme.primaryColor.opacity(0.2) : MatrixTheme.surfaceColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                tempSelectedCategory == category ? MatrixTheme.primaryColor : MatrixTheme.borderColor,
                                                lineWidth: tempSelectedCategory == category ? 2 : 1
                                            )
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private var dateRangeFilterSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("日期范围")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                VStack(spacing: 12) {
                    DatePicker(
                        "开始日期",
                        selection: $startDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(MatrixTheme.primaryColor)
                    
                    DatePicker(
                        "结束日期",
                        selection: $endDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(MatrixTheme.primaryColor)
                }
                
                HStack {
                    Button("清除日期筛选") {
                        tempDateRange = nil
                    }
                    .font(.caption)
                    .foregroundColor(MatrixTheme.errorColor)
                    
                    Spacer()
                    
                    Button("应用日期范围") {
                        if startDate <= endDate {
                            tempDateRange = startDate...endDate
                        }
                    }
                    .font(.caption)
                    .foregroundColor(MatrixTheme.accentColor)
                }
            }
        }
    }
    
    private func applyFilters() {
        expenseViewModel.selectedCategory = tempSelectedCategory
        expenseViewModel.dateRange = tempDateRange
        dismiss()
    }
}

#Preview {
    ExpenseListView()
        .environmentObject(ExpenseViewModel())
        .preferredColorScheme(.dark)
}