//
//  NetworkDiagnosticView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct NetworkDiagnosticView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var networkDiagnostic = NetworkDiagnostic()
    @State private var isRunningDiagnostic = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Network Status
                        networkStatusSection
                        
                        // Diagnostic Results
                        diagnosticResultsSection
                        
                        // Actions
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("网络诊断")
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
        .onAppear {
            networkDiagnostic.startMonitoring()
        }
        .onDisappear {
            networkDiagnostic.stopMonitoring()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "network")
                .font(.system(size: 48))
                .foregroundColor(networkDiagnostic.isConnected ? MatrixTheme.successColor : MatrixTheme.errorColor)
            
            Text("网络诊断")
                .font(MatrixTheme.titleFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            Text("检查网络连接状态和服务可用性")
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }
    
    private var networkStatusSection: some View {
        MatrixCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "wifi")
                        .foregroundColor(networkDiagnostic.isConnected ? MatrixTheme.successColor : MatrixTheme.errorColor)
                    
                    Text("网络状态")
                        .font(MatrixTheme.headlineFont)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                    
                    Spacer()
                    
                    Text(networkDiagnostic.isConnected ? "已连接" : "未连接")
                        .font(MatrixTheme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(networkDiagnostic.isConnected ? MatrixTheme.successColor : MatrixTheme.errorColor)
                }
                
                if networkDiagnostic.isConnected {
                    VStack(alignment: .leading, spacing: 8) {
                        statusRow(title: "连接类型", value: networkDiagnostic.connectionType)
                        statusRow(title: "最后更新", value: formatDate(networkDiagnostic.lastUpdate))
                    }
                }
            }
        }
    }
    
    private var diagnosticResultsSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.shield")
                        .foregroundColor(MatrixTheme.accentColor)
                    
                    Text("诊断结果")
                        .font(MatrixTheme.headlineFont)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                    
                    Spacer()
                    
                    if isRunningDiagnostic {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: MatrixTheme.primaryColor))
                            .scaleEffect(0.8)
                    }
                }
                
                VStack(spacing: 12) {
                    diagnosticRow(
                        title: "基础连接",
                        status: networkDiagnostic.basicConnectivityResult,
                        icon: "globe"
                    )
                    
                    diagnosticRow(
                        title: "Google服务",
                        status: networkDiagnostic.googleConnectivityResult,
                        icon: "magnifyingglass"
                    )
                    
                    diagnosticRow(
                        title: "Apple服务",
                        status: networkDiagnostic.appleConnectivityResult,
                        icon: "applelogo"
                    )
                    
                    diagnosticRow(
                        title: "AI服务",
                        status: networkDiagnostic.aiConnectivityResult,
                        icon: "brain.head.profile"
                    )
                    
                    diagnosticRow(
                        title: "Gemini API",
                        status: networkDiagnostic.geminiApiResult,
                        icon: "sparkles"
                    )
                }
                
                if !networkDiagnostic.logs.isEmpty {
                    Divider()
                        .background(MatrixTheme.dividerColor)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("诊断日志")
                            .font(MatrixTheme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(MatrixTheme.primaryTextColor)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(networkDiagnostic.logs.suffix(10), id: \.self) { log in
                                    Text(log)
                                        .font(.system(size: 10, family: .monospaced))
                                        .foregroundColor(MatrixTheme.secondaryTextColor)
                                }
                            }
                        }
                        .frame(maxHeight: 100)
                        .padding(8)
                        .background(MatrixTheme.surfaceColor)
                        .cornerRadius(MatrixTheme.smallCornerRadius)
                    }
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            MatrixCyberpunkButton(
                title: isRunningDiagnostic ? "诊断中..." : "运行诊断",
                icon: "play.circle.fill"
            ) {
                runDiagnostic()
            }
            .disabled(isRunningDiagnostic)
            
            MatrixButton(
                title: "清除日志",
                style: .secondary
            ) {
                networkDiagnostic.clearLogs()
            }
        }
    }
    
    private func statusRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
            
            Spacer()
            
            Text(value)
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
        }
    }
    
    private func diagnosticRow(title: String, status: NetworkDiagnostic.TestResult, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(statusColor(for: status))
                .frame(width: 20)
            
            Text(title)
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: statusIcon(for: status))
                    .foregroundColor(statusColor(for: status))
                
                Text(statusText(for: status))
                    .font(MatrixTheme.captionFont)
                    .foregroundColor(statusColor(for: status))
            }
        }
        .padding(.vertical, 4)
    }
    
    private func statusIcon(for result: NetworkDiagnostic.TestResult) -> String {
        switch result {
        case .notTested: return "minus.circle"
        case .testing: return "clock"
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }
    
    private func statusColor(for result: NetworkDiagnostic.TestResult) -> Color {
        switch result {
        case .notTested: return MatrixTheme.secondaryTextColor
        case .testing: return MatrixTheme.warningColor
        case .success: return MatrixTheme.successColor
        case .failure: return MatrixTheme.errorColor
        }
    }
    
    private func statusText(for result: NetworkDiagnostic.TestResult) -> String {
        switch result {
        case .notTested: return "未测试"
        case .testing: return "测试中"
        case .success: return "正常"
        case .failure: return "失败"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func runDiagnostic() {
        isRunningDiagnostic = true
        
        Task {
            await networkDiagnostic.runFullDiagnostic()
            
            await MainActor.run {
                isRunningDiagnostic = false
            }
        }
    }
}

#Preview {
    NetworkDiagnosticView()
        .preferredColorScheme(.dark)
}