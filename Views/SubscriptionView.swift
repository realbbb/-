//
//  SubscriptionView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedPlan: SubscriptionPlan?
    @State private var isLoading = false
    @State private var showingPayment = false
    
    let plans: [SubscriptionPlan] = [
        SubscriptionPlan(
            id: "basic_monthly",
            name: "基础版",
            price: "¥9.9",
            period: "月",
            features: ["基础记账功能", "语音输入", "简单统计"],
            isPopular: false
        ),
        SubscriptionPlan(
            id: "premium_monthly",
            name: "高级版",
            price: "¥19.9",
            period: "月",
            features: ["所有基础功能", "AI智能分析", "高级统计图表", "数据导出", "云端同步"],
            isPopular: true
        ),
        SubscriptionPlan(
            id: "professional_yearly",
            name: "专业版",
            price: "¥199",
            period: "年",
            features: ["所有高级功能", "无限制使用", "优先客服支持", "定制化报告", "API访问"],
            isPopular: false
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Current Status
                        currentStatusSection
                        
                        // Subscription Plans
                        plansSection
                        
                        // Features Comparison
                        featuresComparisonSection
                        
                        // Subscribe Button
                        subscribeButtonSection
                        
                        // Terms and Privacy
                        termsSection
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("订阅管理")
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
        .sheet(isPresented: $showingPayment) {
            PaymentView(plan: selectedPlan)
                .environmentObject(appViewModel)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(MatrixTheme.accentColor)
            
            Text("解锁全部功能")
                .font(MatrixTheme.titleFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            Text("升级到付费版本，享受完整的AI记账体验")
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }
    
    private var currentStatusSection: some View {
        MatrixCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前版本")
                        .font(MatrixTheme.captionFont)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                    
                    Text("黑客版 - 带支付功能")
                        .font(MatrixTheme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                    
                    Text("AI总结功能存在已知bug")
                        .font(MatrixTheme.captionFont)
                        .foregroundColor(MatrixTheme.warningColor)
                }
                
                Spacer()
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(MatrixTheme.warningColor)
                    .font(.title2)
            }
        }
    }
    
    private var plansSection: some View {
        VStack(spacing: 16) {
            Text("选择订阅计划")
                .font(MatrixTheme.headlineFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            ForEach(plans, id: \.id) { plan in
                SubscriptionPlanCard(
                    plan: plan,
                    isSelected: selectedPlan?.id == plan.id
                ) {
                    selectedPlan = plan
                }
            }
        }
    }
    
    private var featuresComparisonSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("功能对比")
                    .font(MatrixTheme.headlineFont)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                VStack(spacing: 12) {
                    FeatureComparisonRow(
                        feature: "基础记账",
                        free: true,
                        paid: true
                    )
                    
                    FeatureComparisonRow(
                        feature: "语音输入",
                        free: true,
                        paid: true
                    )
                    
                    FeatureComparisonRow(
                        feature: "AI智能分析",
                        free: false,
                        paid: true
                    )
                    
                    FeatureComparisonRow(
                        feature: "高级统计图表",
                        free: false,
                        paid: true
                    )
                    
                    FeatureComparisonRow(
                        feature: "数据导出",
                        free: false,
                        paid: true
                    )
                    
                    FeatureComparisonRow(
                        feature: "云端同步",
                        free: false,
                        paid: true
                    )
                    
                    FeatureComparisonRow(
                        feature: "优先客服支持",
                        free: false,
                        paid: true
                    )
                }
            }
        }
    }
    
    private var subscribeButtonSection: some View {
        Group {
            if let selectedPlan = selectedPlan {
                MatrixCyberpunkButton(
                    title: "订阅 \(selectedPlan.name) - \(selectedPlan.price)/\(selectedPlan.period)",
                    icon: "creditcard.fill"
                ) {
                    showingPayment = true
                }
                .disabled(isLoading)
            } else {
                MatrixButton(
                    title: "请选择订阅计划",
                    style: .secondary
                ) { }
                .disabled(true)
            }
        }
    }
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("订阅将自动续费，可随时在设置中取消")
                .font(MatrixTheme.captionFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("服务条款") {
                    // Open terms
                }
                .font(MatrixTheme.captionFont)
                .foregroundColor(MatrixTheme.accentColor)
                
                Button("隐私政策") {
                    // Open privacy policy
                }
                .font(MatrixTheme.captionFont)
                .foregroundColor(MatrixTheme.accentColor)
            }
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Subscription Plan Card

struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.name)
                            .font(MatrixTheme.headlineFont)
                            .foregroundColor(MatrixTheme.primaryTextColor)
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(plan.price)
                                .font(MatrixTheme.titleFont)
                                .foregroundColor(MatrixTheme.accentColor)
                            
                            Text("/\(plan.period)")
                                .font(MatrixTheme.bodyFont)
                                .foregroundColor(MatrixTheme.secondaryTextColor)
                        }
                    }
                    
                    Spacer()
                    
                    if plan.isPopular {
                        Text("推荐")
                            .font(MatrixTheme.captionFont)
                            .fontWeight(.medium)
                            .foregroundColor(MatrixTheme.backgroundColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(MatrixTheme.accentColor)
                            .cornerRadius(8)
                    }
                }
                
                // Features
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(MatrixTheme.successColor)
                                .font(.caption)
                            
                            Text(feature)
                                .font(MatrixTheme.bodyFont)
                                .foregroundColor(MatrixTheme.primaryTextColor)
                        }
                    }
                }
            }
            .padding(MatrixTheme.mediumSpacing)
            .background(MatrixTheme.cardColor)
            .cornerRadius(MatrixTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                    .stroke(
                        isSelected ? MatrixTheme.accentColor : MatrixTheme.borderColor,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feature Comparison Row

struct FeatureComparisonRow: View {
    let feature: String
    let free: Bool
    let paid: Bool
    
    var body: some View {
        HStack {
            Text(feature)
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            Spacer()
            
            HStack(spacing: 24) {
                // Free column
                Image(systemName: free ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(free ? MatrixTheme.successColor : MatrixTheme.errorColor)
                    .frame(width: 20)
                
                // Paid column
                Image(systemName: paid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(paid ? MatrixTheme.successColor : MatrixTheme.errorColor)
                    .frame(width: 20)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Payment View

struct PaymentView: View {
    let plan: SubscriptionPlan?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                VStack(spacing: 24) {
                    if let plan = plan {
                        // Plan Summary
                        MatrixCard {
                            VStack(spacing: 16) {
                                Text("订阅确认")
                                    .font(MatrixTheme.headlineFont)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                
                                HStack {
                                    Text(plan.name)
                                        .font(MatrixTheme.bodyFont)
                                        .foregroundColor(MatrixTheme.primaryTextColor)
                                    
                                    Spacer()
                                    
                                    Text("\(plan.price)/\(plan.period)")
                                        .font(MatrixTheme.bodyFont)
                                        .fontWeight(.medium)
                                        .foregroundColor(MatrixTheme.accentColor)
                                }
                            }
                        }
                        
                        // Payment Button
                        MatrixCyberpunkButton(
                            title: isProcessing ? "处理中..." : "确认支付",
                            icon: "creditcard.fill"
                        ) {
                            processPayment()
                        }
                        .disabled(isProcessing)
                        
                        Spacer()
                    }
                }
                .padding()
            }
            .navigationTitle("支付")
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
    
    private func processPayment() {
        guard let plan = plan else { return }
        
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            // Handle payment result
            dismiss()
        }
    }
}

// MARK: - Data Models

struct SubscriptionPlan {
    let id: String
    let name: String
    let price: String
    let period: String
    let features: [String]
    let isPopular: Bool
}

#Preview {
    SubscriptionView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}