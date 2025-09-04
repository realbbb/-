//
//  ExpenseConfirmationView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct ExpenseConfirmationView: View {
    let expenseData: ExpenseData
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var isLoading = false
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Expense Preview
                        expensePreviewCard
                        
                        // AI Analysis
                        if !expenseData.aiAnalysis.isEmpty {
                            aiAnalysisCard
                        }
                        
                        // Actions
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("确认支出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditExpenseDataView(expenseData: expenseData) { updatedData in
                // Handle updated data
                confirmExpense(updatedData)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(MatrixTheme.successColor)
            
            Text("AI识别完成")
                .font(MatrixTheme.titleFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            Text("请确认以下信息是否正确")
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }
    
    private var expensePreviewCard: some View {
        MatrixCard {
            VStack(spacing: 20) {
                // Amount
                VStack(spacing: 8) {
                    Text("金额")
                        .font(MatrixTheme.captionFont)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                    
                    Text("¥\(expenseData.amount, specifier: "%.2f")")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(MatrixTheme.errorColor)
                }
                
                Divider()
                    .background(MatrixTheme.dividerColor)
                
                // Details Grid
                VStack(spacing: 16) {
                    detailRow(title: "描述", value: expenseData.description, icon: "text.alignleft")
                    detailRow(title: "分类", value: expenseData.category, icon: categoryIcon(for: expenseData.category))
                    detailRow(title: "日期", value: formatDate(expenseData.date), icon: "calendar")
                }
            }
        }
    }
    
    private var aiAnalysisCard: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(MatrixTheme.accentColor)
                    
                    Text("AI分析")
                        .font(MatrixTheme.headlineFont)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                }
                
                Text(expenseData.aiAnalysis)
                    .font(MatrixTheme.bodyFont)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .padding()
                    .background(MatrixTheme.surfaceColor)
                    .cornerRadius(MatrixTheme.smallCornerRadius)
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            MatrixCyberpunkButton(
                title: isLoading ? "保存中..." : "确认并保存",
                icon: "checkmark.circle.fill"
            ) {
                confirmExpense(expenseData)
            }
            .disabled(isLoading)
            
            MatrixButton(
                title: "编辑信息",
                style: .secondary
            ) {
                showingEditView = true
            }
            .disabled(isLoading)
        }
    }
    
    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(MatrixTheme.accentColor)
                .frame(width: 20)
            
            Text(title)
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
            
            Spacer()
            
            Text(value)
                .font(MatrixTheme.bodyFont)
                .fontWeight(.medium)
                .foregroundColor(MatrixTheme.primaryTextColor)
        }
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "餐饮": return "fork.knife"
        case "交通": return "car.fill"
        case "购物": return "bag.fill"
        case "娱乐": return "gamecontroller.fill"
        case "医疗": return "cross.case.fill"
        case "教育": return "book.fill"
        case "住房": return "house.fill"
        case "其他": return "ellipsis.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func confirmExpense(_ data: ExpenseData) {
        isLoading = true
        
        let expense = Expense(
            id: UUID(),
            amount: data.amount,
            description: data.description,
            category: data.category,
            date: data.date,
            userId: appViewModel.currentUser?.id ?? UUID()
        )
        
        Task {
            do {
                try await appViewModel.addExpense(expense)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    // Handle error
                }
            }
        }
    }
}

// MARK: - Edit Expense Data View

struct EditExpenseDataView: View {
    @State private var expenseData: ExpenseData
    let onSave: (ExpenseData) -> Void
    @Environment(\.dismiss) private var dismiss
    
    let categories = ["餐饮", "交通", "购物", "娱乐", "医疗", "教育", "住房", "其他"]
    
    init(expenseData: ExpenseData, onSave: @escaping (ExpenseData) -> Void) {
        self._expenseData = State(initialValue: expenseData)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount Input
                        MatrixCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("金额")
                                    .font(MatrixTheme.headlineFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                
                                TextField("输入金额", value: $expenseData.amount, format: .number)
                                    .font(MatrixTheme.bodyFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                    .padding()
                                    .background(MatrixTheme.surfaceColor)
                                    .cornerRadius(MatrixTheme.cornerRadius)
                                    .keyboardType(.decimalPad)
                            }
                        }
                        
                        // Description Input
                        MatrixCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("描述")
                                    .font(MatrixTheme.headlineFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                
                                TextField("输入描述", text: $expenseData.description)
                                    .font(MatrixTheme.bodyFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                    .padding()
                                    .background(MatrixTheme.surfaceColor)
                                    .cornerRadius(MatrixTheme.cornerRadius)
                            }
                        }
                        
                        // Category Selection
                        MatrixCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("分类")
                                    .font(MatrixTheme.headlineFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(categories, id: \.self) { category in
                                        Button(action: {
                                            expenseData.category = category
                                        }) {
                                            HStack {
                                                Image(systemName: categoryIcon(for: category))
                                                    .foregroundColor(categoryColor(for: category))
                                                
                                                Text(category)
                                                    .font(MatrixTheme.bodyFont)
                                                    .foregroundColor(
                                                        expenseData.category == category ?
                                                        MatrixTheme.backgroundColor :
                                                        MatrixTheme.primaryTextColor
                                                    )
                                                
                                                Spacer()
                                            }
                                            .padding()
                                            .background(
                                                expenseData.category == category ?
                                                categoryColor(for: category) :
                                                MatrixTheme.surfaceColor
                                            )
                                            .cornerRadius(MatrixTheme.smallCornerRadius)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        // Date Picker
                        MatrixCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("日期")
                                    .font(MatrixTheme.headlineFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                
                                DatePicker(
                                    "选择日期",
                                    selection: $expenseData.date,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("编辑支出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave(expenseData)
                        dismiss()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
            }
        }
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "餐饮": return "fork.knife"
        case "交通": return "car.fill"
        case "购物": return "bag.fill"
        case "娱乐": return "gamecontroller.fill"
        case "医疗": return "cross.case.fill"
        case "教育": return "book.fill"
        case "住房": return "house.fill"
        case "其他": return "ellipsis.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "餐饮": return .orange
        case "交通": return .blue
        case "购物": return .purple
        case "娱乐": return .pink
        case "医疗": return .red
        case "教育": return .green
        case "住房": return .brown
        case "其他": return .gray
        default: return MatrixTheme.accentColor
        }
    }
}

// MARK: - Data Model

struct ExpenseData {
    var amount: Double
    var description: String
    var category: String
    var date: Date
    var aiAnalysis: String
}

#Preview {
    ExpenseConfirmationView(
        expenseData: ExpenseData(
            amount: 35.0,
            description: "星巴克咖啡",
            category: "餐饮",
            date: Date(),
            aiAnalysis: "这是一笔餐饮支出，在星巴克购买咖啡。建议控制此类非必需消费的频率。"
        )
    )
    .environmentObject(AppViewModel())
    .preferredColorScheme(.dark)
}