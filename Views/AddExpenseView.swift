//
//  AddExpenseView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var selectedDate = Date()
    @State private var notes: String = ""
    
    @State private var showingCategoryPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var isFormValid: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        return !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount Input
                        amountSection
                        
                        // Description Input
                        descriptionSection
                        
                        // Category Selection
                        categorySection
                        
                        // Date Selection
                        dateSection
                        
                        // Notes Input
                        notesSection
                        
                        // Save Button
                        saveButton
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("添加支出")
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
        .alert("提示", isPresented: $showingAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(selectedCategory: $selectedCategory)
        }
    }
    
    private var amountSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("金额")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                HStack {
                    Text("¥")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(MatrixTheme.primaryColor)
                    
                    TextField("0.00", text: $amount)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(MatrixTheme.surfaceColor)
                .cornerRadius(MatrixTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                        .stroke(MatrixTheme.borderColor, lineWidth: 1)
                )
            }
        }
    }
    
    private var descriptionSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("描述")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                TextField("请输入支出描述", text: $description)
                    .font(.body)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(MatrixTheme.surfaceColor)
                    .cornerRadius(MatrixTheme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                            .stroke(MatrixTheme.borderColor, lineWidth: 1)
                    )
            }
        }
    }
    
    private var categorySection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("分类")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Button(action: {
                    showingCategoryPicker = true
                }) {
                    HStack {
                        Image(systemName: selectedCategory.icon)
                            .font(.title2)
                            .foregroundColor(selectedCategory.color)
                        
                        Text(selectedCategory.displayName)
                            .font(.body)
                            .foregroundColor(MatrixTheme.primaryTextColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(MatrixTheme.secondaryTextColor)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(MatrixTheme.surfaceColor)
                    .cornerRadius(MatrixTheme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                            .stroke(MatrixTheme.borderColor, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var dateSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("日期")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .accentColor(MatrixTheme.primaryColor)
            }
        }
    }
    
    private var notesSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("备注")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                TextField("添加备注（可选）", text: $notes, axis: .vertical)
                    .font(.body)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .lineLimit(3...6)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(MatrixTheme.surfaceColor)
                    .cornerRadius(MatrixTheme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                            .stroke(MatrixTheme.borderColor, lineWidth: 1)
                    )
            }
        }
    }
    
    private var saveButton: some View {
        MatrixButton(
            title: "保存支出",
            isLoading: expenseViewModel.isLoading,
            action: saveExpense
        )
        .disabled(!isFormValid)
        .padding(.top, 16)
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else {
            alertMessage = "请输入有效的金额"
            showingAlert = true
            return
        }
        
        guard amountValue > 0 else {
            alertMessage = "金额必须大于0"
            showingAlert = true
            return
        }
        
        guard let userId = UserDefaults.standard.string(forKey: "current_user_id") else {
            alertMessage = "用户信息错误，请重新登录"
            showingAlert = true
            return
        }
        
        let expense = ExpenseData(
            id: UUID().uuidString,
            userId: userId,
            amount: amountValue,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        expenseViewModel.addExpense(expense)
        dismiss()
    }
}

// MARK: - Category Picker View

struct CategoryPickerView: View {
    @Binding var selectedCategory: ExpenseCategory
    @Environment(\.dismiss) private var dismiss
    
    private let categories = ExpenseCategory.allCases
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(categories, id: \.self) { category in
                            CategoryCard(
                                category: category,
                                isSelected: category == selectedCategory
                            ) {
                                selectedCategory = category
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("选择分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title)
                    .foregroundColor(category.color)
                
                Text(category.displayName)
                    .font(.caption)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                    .fill(isSelected ? MatrixTheme.primaryColor.opacity(0.2) : MatrixTheme.surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                            .stroke(
                                isSelected ? MatrixTheme.primaryColor : MatrixTheme.borderColor,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(ExpenseViewModel())
        .preferredColorScheme(.dark)
}