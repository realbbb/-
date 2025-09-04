//
//  StatisticsView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var statisticsViewModel: StatisticsViewModel
    @State private var showingAIAnalysis = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Period Selection
                        periodSelectionSection
                        
                        // Overview Cards
                        overviewSection
                        
                        // Category Distribution Chart
                        categoryChartSection
                        
                        // Trend Chart
                        trendChartSection
                        
                        // Detailed Statistics
                        detailedStatsSection
                        
                        // AI Analysis Button
                        aiAnalysisSection
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("财务统计")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        statisticsViewModel.loadStatistics()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(MatrixTheme.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAIAnalysis) {
            AIFinancialAnalysisView()
                .environmentObject(statisticsViewModel)
        }
        .onAppear {
            statisticsViewModel.loadStatistics()
        }
    }
    
    private var periodSelectionSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                    Button(action: {
                        statisticsViewModel.updatePeriod(period)
                    }) {
                        Text(period.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(
                                statisticsViewModel.selectedPeriod == period ?
                                MatrixTheme.backgroundColor : MatrixTheme.primaryTextColor
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        statisticsViewModel.selectedPeriod == period ?
                                        MatrixTheme.primaryColor : MatrixTheme.surfaceColor
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var overviewSection: some View {
        Group {
            if let stats = statisticsViewModel.statistics {
                HStack(spacing: 16) {
                    MatrixStatCard(
                        title: "总支出",
                        value: String(format: "¥%.2f", stats.totalAmount),
                        icon: "yensign.circle.fill",
                        color: MatrixTheme.errorColor
                    )
                    
                    MatrixStatCard(
                        title: "交易笔数",
                        value: "\(stats.transactionCount)",
                        icon: "number.circle.fill",
                        color: MatrixTheme.accentColor
                    )
                }
                
                HStack(spacing: 16) {
                    MatrixStatCard(
                        title: "平均金额",
                        value: String(format: "¥%.2f", stats.averageAmount),
                        icon: "chart.line.uptrend.xyaxis.circle.fill",
                        color: MatrixTheme.warningColor
                    )
                    
                    MatrixStatCard(
                        title: "最大支出",
                        value: String(format: "¥%.2f", stats.categoryBreakdown.first?.amount ?? 0),
                        icon: "arrow.up.circle.fill",
                        color: MatrixTheme.primaryColor
                    )
                }
            } else {
                MatrixLoadingView(message: "加载统计数据...")
                    .frame(height: 200)
            }
        }
    }
    
    private var categoryChartSection: some View {
        Group {
            if let stats = statisticsViewModel.statistics, !stats.categoryBreakdown.isEmpty {
                MatrixCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("分类分布")
                            .font(.headline)
                            .foregroundColor(MatrixTheme.primaryTextColor)
                        
                        Chart(stats.categoryBreakdown, id: \.category) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(item.category.color)
                            .opacity(0.8)
                        }
                        .frame(height: 200)
                        
                        // Legend
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(stats.categoryBreakdown.prefix(6), id: \.category) { item in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(item.category.color)
                                        .frame(width: 12, height: 12)
                                    
                                    Text(item.category.displayName)
                                        .font(.caption)
                                        .foregroundColor(MatrixTheme.primaryTextColor)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.1f%%", item.percentage))
                                        .font(.caption)
                                        .foregroundColor(MatrixTheme.secondaryTextColor)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var trendChartSection: some View {
        Group {
            if let stats = statisticsViewModel.statistics, !stats.monthlyTrend.isEmpty {
                MatrixCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("支出趋势")
                            .font(.headline)
                            .foregroundColor(MatrixTheme.primaryTextColor)
                        
                        Chart(stats.monthlyTrend, id: \.month) { item in
                            LineMark(
                                x: .value("Month", item.month),
                                y: .value("Amount", item.amount)
                            )
                            .foregroundStyle(MatrixTheme.primaryColor)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            AreaMark(
                                x: .value("Month", item.month),
                                y: .value("Amount", item.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [MatrixTheme.primaryColor.opacity(0.3), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .frame(height: 150)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine()
                                AxisValueLabel()
                                    .foregroundStyle(MatrixTheme.secondaryTextColor)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine()
                                AxisValueLabel()
                                    .foregroundStyle(MatrixTheme.secondaryTextColor)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var detailedStatsSection: some View {
        Group {
            if let stats = statisticsViewModel.statistics {
                MatrixCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("详细统计")
                            .font(.headline)
                            .foregroundColor(MatrixTheme.primaryTextColor)
                        
                        ForEach(stats.categoryBreakdown, id: \.category) { item in
                            HStack {
                                Image(systemName: item.category.icon)
                                    .foregroundColor(item.category.color)
                                    .frame(width: 20)
                                
                                Text(item.category.displayName)
                                    .foregroundColor(MatrixTheme.primaryTextColor)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(format: "¥%.2f", item.amount))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(MatrixTheme.primaryTextColor)
                                    
                                    Text("\(item.count)笔 · \(String(format: "%.1f%%", item.percentage))")
                                        .font(.caption)
                                        .foregroundColor(MatrixTheme.secondaryTextColor)
                                }
                            }
                            .padding(.vertical, 4)
                            
                            if item.category != stats.categoryBreakdown.last?.category {
                                Divider()
                                    .background(MatrixTheme.borderColor)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var aiAnalysisSection: some View {
        MatrixCyberpunkButton(
            title: "AI财务分析",
            icon: "brain.head.profile",
            action: {
                showingAIAnalysis = true
            }
        )
        .padding(.bottom, 20)
    }
}

// MARK: - Statistics Period

enum StatisticsPeriod: CaseIterable {
    case week, month, quarter, year, all
    
    var displayName: String {
        switch self {
        case .week: return "本周"
        case .month: return "本月"
        case .quarter: return "本季度"
        case .year: return "本年"
        case .all: return "全部"
        }
    }
}

// MARK: - Category Statistic

struct CategoryStatistic {
    let category: ExpenseCategory
    let amount: Double
    let count: Int
    let percentage: Double
}

#Preview {
    StatisticsView()
        .environmentObject(StatisticsViewModel())
        .preferredColorScheme(.dark)
}