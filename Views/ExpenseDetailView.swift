//
//  ExpenseDetailView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct ExpenseDetailView: View {
    let expense: Expense
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount Card
                        amountCard
                        
                        // Details Card
                        detailsCard
                        
                        // Category Card
                        categoryCard
                        
                        // Date Card
                        dateCard
                        
                        // Actions
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("支出详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("编辑") {
                        showingEditView = true
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditExpenseView(expense: expense)
                .environmentObject(appViewModel)
        }
        .alert("删除支出", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) {
                deleteExpense()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("确定要删除这条支出记录吗？此操作无法撤销。")
        }
    }
    
    private var amountCard: some View {
        MatrixCard {
            VStack(spacing: 16) {
                Image(systemName: "yensign.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(MatrixTheme.errorColor)
                
                Text("¥\(expense.amount, specifier: "%.2f")")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Text("支出金额")
                    .font(MatrixTheme.captionFont)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var detailsCard: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(MatrixTheme.accentColor)
                    
                    Text("描述")
                        .font(MatrixTheme.headlineFont)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                }
                
                Text(expense.description)
                    .font(MatrixTheme.bodyFont)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .padding()
                    .background(MatrixTheme.surfaceColor)
                    .cornerRadius(MatrixTheme.smallCornerRadius)
            }
        }
    }
    
    private var categoryCard: some View {
        MatrixCard {
            HStack {
                Image(systemName: categoryIcon(for: expense.category))
                    .font(.title2)
                    .foregroundColor(categoryColor(for: expense.category))
                    .frame(width: 40, height: 40)
                    .background(categoryColor(for: expense.category).opacity(0.2))
                    .cornerRadius(MatrixTheme.smallCornerRadius)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("分类")
                        .font(MatrixTheme.captionFont)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                    
                    Text(expense.category)
                        .font(MatrixTheme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                }
                
                Spacer()
            }
        }
    }
    
    private var dateCard: some View {
        MatrixCard {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(MatrixTheme.infoColor)
                    .frame(width: 40, height: 40)
                    .background(MatrixTheme.infoColor.opacity(0.2))
                    .cornerRadius(MatrixTheme.smallCornerRadius)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("日期")
                        .font(MatrixTheme.captionFont)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                    
                    Text(expense.date, style: .date)
                        .font(MatrixTheme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("时间")
                        .font(MatrixTheme.captionFont)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                    
                    Text(expense.date, style: .time)
                        .font(MatrixTheme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            MatrixButton(
                title: "编辑支出",
                style: .primary
            ) {
                showingEditView = true
            }
            
            MatrixButton(
                title: "删除支出",
                style: .secondary
            ) {
                showingDeleteAlert = true
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
    
    private func deleteExpense() {
        Task {
            do {
                try await appViewModel.deleteExpense(expense)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                // Handle error
                print("Failed to delete expense: \(error)")
            }
        }
    }
}

// MARK: - Edit Expense View

struct EditExpenseView: View {
    let expense: Expense
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var amount: String
    @State private var description: String
    @State private var category: String
    @State private var date: Date
    @State private var isLoading = false
    
    let categories = ["餐饮", "交通", "购物", "娱乐", "医疗", "教育", "住房", "其他"]
    
    init(expense: Expense) {
        self.expense = expense
        self._amount = State(initialValue: String(format: "%.2f", expense.amount))
        self._description = State(initialValue: expense.description)
        self._category = State(initialValue: expense.category)
        self._date = State(initialValue: expense.date)
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
                                
                                MatrixTextField(
                                    placeholder: "输入金额",
                                    text: $amount,
                                    icon: "yensign.circle"
                                )
                                .keyboardType(.decimalPad)
                            }
                        }
                        
                        // Description Input
                        MatrixCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("描述")
                                    .font(MatrixTheme.headlineFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                
                                MatrixTextField(
                                    placeholder: "输入描述",
                                    text: $description,
                                    icon: "text.alignleft"
                                )
                            }
                        }
                        
                        // Category Selection
                        MatrixCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("分类")
                                    .font(MatrixTheme.headlineFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(categories, id: \.self) { cat in
                                        Button(action: {
                                            category = cat
                                        }) {
                                            HStack {
                                                Image(systemName: categoryIcon(for: cat))
                                                    .foregroundColor(categoryColor(for: cat))
                                                
                                                Text(cat)
                                                    .font(MatrixTheme.bodyFont)
                                                    .foregroundColor(
                                                        category == cat ?
                                                        MatrixTheme.backgroundColor :
                                                        MatrixTheme.primaryTextColor
                                                    )
                                                
                                                Spacer()
                                            }
                                            .padding()
                                            .background(
                                                category == cat ?
                                                categoryColor(for: cat) :
                                                MatrixTheme.surfaceColor
                                            )
                                            .cornerRadius(MatrixTheme.smallCornerRadius)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: MatrixTheme.smallCornerRadius)
                                                    .stroke(
                                                        category == cat ?
                                                        categoryColor(for: cat) :
                                                        MatrixTheme.borderColor,
                                                        lineWidth: 1
                                                    )
                                            )
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
                                    selection: $date,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                            }
                        }
                        
                        // Save Button
                        MatrixCyberpunkButton(
                            title: isLoading ? "保存中..." : "保存更改",
                            icon: "checkmark.circle.fill"
                        ) {
                            saveChanges()
                        }
                        .disabled(isLoading || amount.isEmpty || description.isEmpty)
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
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        isLoading = true
        
        let updatedExpense = Expense(
            id: expense.id,
            amount: amountValue,
            description: description,
            category: category,
            date: date,
            userId: expense.userId
        )
        
        Task {
            do {
                try await appViewModel.updateExpense(updatedExpense)
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

#Preview {
    ExpenseDetailView(
        expense: Expense(
            id: UUID(),
            amount: 35.0,
            description: "星巴克咖啡",
            category: "餐饮",
            date: Date(),
            userId: UUID()
        )
    )
    .environmentObject(AppViewModel())
    .preferredColorScheme(.dark)
}