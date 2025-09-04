//
//  SettingsView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingSubscription = false
    @State private var showingProfile = false
    @State private var showingDeleteConfirmation = false
    
    // Settings toggles
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("voice_recording_enabled") private var voiceRecordingEnabled = true
    @AppStorage("auto_backup_enabled") private var autoBackupEnabled = false
    @AppStorage("biometric_auth_enabled") private var biometricAuthEnabled = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User Profile Section
                        userProfileSection
                        
                        // Subscription Section
                        subscriptionSection
                        
                        // App Settings
                        appSettingsSection
                        
                        // Help & Support
                        helpSupportSection
                        
                        // Account Actions
                        accountActionsSection
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileEditView()
                .environmentObject(appViewModel)
        }
        .alert("删除账户", isPresented: $showingDeleteConfirmation) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                // Delete account action
            }
        } message: {
            Text("此操作不可撤销，将永久删除您的账户和所有数据。")
        }
    }
    
    private var userProfileSection: some View {
        MatrixCard {
            HStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [MatrixTheme.primaryColor, MatrixTheme.accentColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(appViewModel.currentUser?.name.prefix(1).uppercased() ?? "U")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appViewModel.currentUser?.name ?? "用户")
                        .font(.headline)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                    
                    Text(appViewModel.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                    
                    Text("黑客版用户")
                        .font(.caption)
                        .foregroundColor(MatrixTheme.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(MatrixTheme.accentColor.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: {
                    showingProfile = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(MatrixTheme.accentColor)
                }
            }
        }
    }
    
    private var subscriptionSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("订阅状态")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("黑客版 - 带支付功能")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(MatrixTheme.primaryTextColor)
                        
                        Text("AI总结功能存在已知bug")
                            .font(.caption)
                            .foregroundColor(MatrixTheme.warningColor)
                    }
                    
                    Spacer()
                    
                    Button("管理订阅") {
                        showingSubscription = true
                    }
                    .font(.caption)
                    .foregroundColor(MatrixTheme.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(MatrixTheme.surfaceColor)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MatrixTheme.accentColor, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var appSettingsSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("应用设置")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                VStack(spacing: 12) {
                    SettingsToggleRow(
                        title: "推送通知",
                        subtitle: "接收支出提醒和统计报告",
                        icon: "bell.fill",
                        isOn: $notificationsEnabled
                    )
                    
                    SettingsToggleRow(
                        title: "语音录制",
                        subtitle: "允许应用录制语音进行AI分析",
                        icon: "mic.fill",
                        isOn: $voiceRecordingEnabled
                    )
                    
                    SettingsToggleRow(
                        title: "自动备份",
                        subtitle: "自动备份数据到云端",
                        icon: "icloud.fill",
                        isOn: $autoBackupEnabled
                    )
                    
                    SettingsToggleRow(
                        title: "生物识别认证",
                        subtitle: "使用Face ID或Touch ID登录",
                        icon: "faceid",
                        isOn: $biometricAuthEnabled
                    )
                }
            }
        }
    }
    
    private var helpSupportSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("帮助与支持")
                    .font(.headline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                VStack(spacing: 12) {
                    SettingsActionRow(
                        title: "使用帮助",
                        icon: "questionmark.circle.fill",
                        action: { /* Help action */ }
                    )
                    
                    SettingsActionRow(
                        title: "评价应用",
                        icon: "star.fill",
                        action: { /* Rate app action */ }
                    )
                    
                    SettingsActionRow(
                        title: "联系我们",
                        icon: "envelope.fill",
                        action: { /* Contact action */ }
                    )
                    
                    SettingsActionRow(
                        title: "隐私政策",
                        icon: "hand.raised.fill",
                        action: { /* Privacy policy action */ }
                    )
                    
                    SettingsActionRow(
                        title: "服务条款",
                        icon: "doc.text.fill",
                        action: { /* Terms action */ }
                    )
                }
            }
        }
    }
    
    private var accountActionsSection: some View {
        VStack(spacing: 12) {
            MatrixButton(
                title: "退出登录",
                style: .secondary,
                action: {
                    appViewModel.signOut()
                }
            )
            
            Button("删除账户") {
                showingDeleteConfirmation = true
            }
            .font(.subheadline)
            .foregroundColor(MatrixTheme.errorColor)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(MatrixTheme.errorColor.opacity(0.1))
            .cornerRadius(MatrixTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                    .stroke(MatrixTheme.errorColor, lineWidth: 1)
            )
        }
    }
}

// MARK: - Settings Row Components

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(MatrixTheme.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(MatrixTheme.primaryColor)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsActionRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(MatrixTheme.accentColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Edit View

struct ProfileEditView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                VStack(spacing: 24) {
                    // Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [MatrixTheme.primaryColor, MatrixTheme.accentColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(name.prefix(1).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 16) {
                        MatrixTextField(
                            placeholder: "姓名",
                            text: $name,
                            icon: "person"
                        )
                        
                        MatrixTextField(
                            placeholder: "邮箱",
                            text: $email,
                            icon: "envelope"
                        )
                        .disabled(true) // Email usually can't be changed
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("编辑资料")
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
                        // Save profile changes
                        dismiss()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
            }
        }
        .onAppear {
            name = appViewModel.currentUser?.name ?? ""
            email = appViewModel.currentUser?.email ?? ""
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}