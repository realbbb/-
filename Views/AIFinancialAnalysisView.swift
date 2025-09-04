//
//  AIFinancialAnalysisView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct AIFinancialAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var analysisResult: String = ""
    @State private var isLoading = false
    @State private var selectedPeriod: AnalysisPeriod = .month
    @State private var showingError = false
    @State private var errorMessage = ""
    
    enum AnalysisPeriod: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case quarter = "本季度"
        case year = "本年"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Period Selection
                        periodSelectionSection
                        
                        // Analysis Result
                        if isLoading {
                            loadingSection
                        } else if !analysisResult.isEmpty {
                            analysisResultSection
                        } else {
                            emptyStateSection
                        }
                        
                        // Action Button
                        if !isLoading {
                            actionButtonSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("AI财务分析")
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
        .alert("分析失败", isPresented: $showingError) {
            Button("确定") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if analysisResult.isEmpty {
                performAnalysis()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(MatrixTheme.accentColor)
            
            Text("AI财务分析")
                .font(MatrixTheme.titleFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            Text("基于您的消费数据，AI为您提供个性化的财务建议")
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }
    
    private var periodSelectionSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("分析周期")
                    .font(MatrixTheme.headlineFont)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                HStack(spacing: 12) {
                    ForEach(AnalysisPeriod.allCases, id: \.self) { period in
                        MatrixFilterChip(
                            title: period.rawValue,
                            icon: "calendar",
                            isSelected: selectedPeriod == period
                        ) {
                            selectedPeriod = period
                            if !isLoading {
                                performAnalysis()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var loadingSection: some View {
        MatrixCard {
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: MatrixTheme.primaryColor))
                    .scaleEffect(1.5)
                
                Text("AI正在分析您的财务数据...")
                    .font(MatrixTheme.bodyFont)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
                
                Text("这可能需要几秒钟时间")
                    .font(MatrixTheme.captionFont)
                    .foregroundColor(MatrixTheme.tertiaryTextColor)
            }
            .padding(MatrixTheme.largeSpacing)
        }
    }
    
    private var analysisResultSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(MatrixTheme.accentColor)
                    
                    Text("分析结果")
                        .font(MatrixTheme.headlineFont)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                    
                    Spacer()
                    
                    Text(selectedPeriod.rawValue)
                        .font(MatrixTheme.captionFont)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MatrixTheme.surfaceColor)
                        .cornerRadius(8)
                }
                
                ScrollView {
                    Text(analysisResult)
                        .font(MatrixTheme.bodyFont)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                        .lineSpacing(4)
                }
                .frame(maxHeight: 300)
                .padding()
                .background(MatrixTheme.surfaceColor)
                .cornerRadius(MatrixTheme.smallCornerRadius)
                
                // Warning about bugs
                MatrixAlert(
                    title: "注意",
                    message: "当前版本的AI分析功能存在已知bug，分析结果仅供参考",
                    type: .warning
                )
            }
        }
    }
    
    private var emptyStateSection: some View {
        MatrixCard {
            MatrixEmptyStateView(
                icon: "chart.line.uptrend.xyaxis",
                title: "暂无分析数据",
                subtitle: "请先添加一些支出记录，然后重新进行分析"
            )
        }
    }
    
    private var actionButtonSection: some View {
        VStack(spacing: 16) {
            MatrixCyberpunkButton(
                title: "重新分析",
                icon: "arrow.clockwise"
            ) {
                performAnalysis()
            }
            
            if !analysisResult.isEmpty {
                MatrixButton(
                    title: "分享分析结果",
                    style: .secondary
                ) {
                    shareAnalysis()
                }
            }
        }
    }
    
    private func performAnalysis() {
        isLoading = true
        analysisResult = ""
        
        Task {
            do {
                // Get expenses for the selected period
                let expenses = getExpensesForPeriod(selectedPeriod)
                
                if expenses.isEmpty {
                    await MainActor.run {
                        isLoading = false
                    }
                    return
                }
                
                // Perform AI analysis
                let result = try await appViewModel.geminiService.analyzeFinancialData(expenses)
                
                await MainActor.run {
                    analysisResult = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func getExpensesForPeriod(_ period: AnalysisPeriod) -> [Expense] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .week:
            startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .month:
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .quarter:
            let quarter = calendar.component(.quarter, from: now)
            startDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: (quarter - 1) * 3 + 1)) ?? now
        case .year:
            startDate = calendar.dateInterval(of: .year, for: now)?.start ?? now
        }
        
        return appViewModel.expenses.filter { expense in
            expense.date >= startDate && expense.date <= now
        }
    }
    
    private func shareAnalysis() {
        let shareText = """
        AI财务分析报告 - \(selectedPeriod.rawValue)
        
        \(analysisResult)
        
        来自秋后算账App
        """
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}

#Preview {
    AIFinancialAnalysisView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}