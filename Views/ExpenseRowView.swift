//
//  ExpenseRowView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Category Icon
                categoryIconView
                
                // Expense Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.description)
                        .font(MatrixTheme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                        .lineLimit(1)
                    
                    HStack {
                        Text(expense.category)
                            .font(MatrixTheme.captionFont)
                            .foregroundColor(categoryColor(for: expense.category))
                        
                        Spacer()
                        
                        Text(expense.date, style: .date)
                            .font(MatrixTheme.captionFont)
                            .foregroundColor(MatrixTheme.secondaryTextColor)
                    }
                }
                
                Spacer()
                
                // Amount
                VStack(alignment: .trailing, spacing: 4) {
                    Text("-¥\(expense.amount, specifier: "%.2f")")
                        .font(MatrixTheme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(MatrixTheme.errorColor)
                    
                    Text(expense.date, style: .time)
                        .font(MatrixTheme.captionFont)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                }
            }
            .padding(MatrixTheme.mediumSpacing)
            .background(MatrixTheme.cardColor)
            .cornerRadius(MatrixTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                    .stroke(MatrixTheme.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryIconView: some View {
        Image(systemName: categoryIcon(for: expense.category))
            .font(.title3)
            .foregroundColor(categoryColor(for: expense.category))
            .frame(width: 40, height: 40)
            .background(categoryColor(for: expense.category).opacity(0.2))
            .cornerRadius(MatrixTheme.smallCornerRadius)
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

#Preview {
    VStack(spacing: 12) {
        ExpenseRowView(
            expense: Expense(
                id: UUID(),
                amount: 35.0,
                description: "星巴克咖啡",
                category: "餐饮",
                date: Date(),
                userId: UUID()
            )
        ) { }
        
        ExpenseRowView(
            expense: Expense(
                id: UUID(),
                amount: 120.0,
                description: "地铁卡充值",
                category: "交通",
                date: Date().addingTimeInterval(-86400),
                userId: UUID()
            )
        ) { }
    }
    .padding()
    .background(MatrixTheme.backgroundColor)
    .preferredColorScheme(.dark)
}