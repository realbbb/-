//
//  AuthenticationView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var appViewModel = AppViewModel()
    @State private var isShowingSignup = false
    
    var body: some View {
        ZStack {
            CyberpunkBackgroundView()
            
            VStack {
                if isShowingSignup {
                    SignupView(isShowingSignup: $isShowingSignup)
                        .environmentObject(appViewModel)
                } else {
                    LoginView(isShowingSignup: $isShowingSignup)
                        .environmentObject(appViewModel)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("错误", isPresented: $appViewModel.showingAlert) {
            Button("确定") {
                appViewModel.clearError()
            }
        } message: {
            Text(appViewModel.errorMessage ?? "未知错误")
        }
    }
}

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Binding var isShowingSignup: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo and Title
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(MatrixTheme.primaryColor)
                
                Text("秋后算账")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Text("AI智能记账助手")
                    .font(.subheadline)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
            }
            .padding(.top, 40)
            
            // Login Form
            VStack(spacing: 20) {
                MatrixTextField(
                    placeholder: "邮箱地址",
                    text: $email,
                    icon: "envelope"
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                MatrixTextField(
                    placeholder: "密码",
                    text: $password,
                    icon: "lock",
                    isSecure: true
                )
                
                HStack {
                    Button(action: {
                        rememberMe.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(rememberMe ? MatrixTheme.primaryColor : MatrixTheme.secondaryTextColor)
                            
                            Text("记住我")
                                .font(.caption)
                                .foregroundColor(MatrixTheme.secondaryTextColor)
                        }
                    }
                    
                    Spacer()
                    
                    Button("忘记密码？") {
                        // Forgot password action
                    }
                    .font(.caption)
                    .foregroundColor(MatrixTheme.accentColor)
                }
            }
            .padding(.horizontal, 32)
            
            // Login Button
            VStack(spacing: 16) {
                MatrixButton(
                    title: "登录",
                    isLoading: appViewModel.isLoading,
                    action: {
                        appViewModel.signIn(email: email, password: password)
                    }
                )
                .disabled(email.isEmpty || password.isEmpty)
                .padding(.horizontal, 32)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(MatrixTheme.borderColor)
                    
                    Text("或")
                        .font(.caption)
                        .foregroundColor(MatrixTheme.secondaryTextColor)
                        .padding(.horizontal, 16)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(MatrixTheme.borderColor)
                }
                .padding(.horizontal, 32)
                
                // Sign Up Link
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingSignup = true
                    }
                }) {
                    HStack {
                        Text("还没有账户？")
                            .foregroundColor(MatrixTheme.secondaryTextColor)
                        
                        Text("立即注册")
                            .foregroundColor(MatrixTheme.accentColor)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Signup View

struct SignupView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Binding var isShowingSignup: Bool
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    
    private var passwordStrength: PasswordStrength {
        return evaluatePasswordStrength(password)
    }
    
    private var isFormValid: Bool {
        return !name.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               password == confirmPassword &&
               passwordStrength != .weak &&
               agreeToTerms
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingSignup = false
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("返回登录")
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                
                Text("创建账户")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Text("加入AI智能记账的世界")
                    .font(.subheadline)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
            }
            .padding(.top, 20)
            
            // Signup Form
            VStack(spacing: 20) {
                MatrixTextField(
                    placeholder: "姓名",
                    text: $name,
                    icon: "person"
                )
                
                MatrixTextField(
                    placeholder: "邮箱地址",
                    text: $email,
                    icon: "envelope"
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                VStack(spacing: 8) {
                    MatrixTextField(
                        placeholder: "密码",
                        text: $password,
                        icon: "lock",
                        isSecure: true
                    )
                    
                    if !password.isEmpty {
                        PasswordStrengthIndicator(strength: passwordStrength)
                    }
                }
                
                MatrixTextField(
                    placeholder: "确认密码",
                    text: $confirmPassword,
                    icon: "lock",
                    isSecure: true
                )
                
                if !confirmPassword.isEmpty && password != confirmPassword {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(MatrixTheme.errorColor)
                        Text("密码不匹配")
                            .font(.caption)
                            .foregroundColor(MatrixTheme.errorColor)
                        Spacer()
                    }
                }
                
                // Terms Agreement
                Button(action: {
                    agreeToTerms.toggle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                            .foregroundColor(agreeToTerms ? MatrixTheme.primaryColor : MatrixTheme.secondaryTextColor)
                        
                        Text("我同意")
                            .font(.caption)
                            .foregroundColor(MatrixTheme.secondaryTextColor)
                        
                        Button("服务条款") {
                            // Terms action
                        }
                        .font(.caption)
                        .foregroundColor(MatrixTheme.accentColor)
                        
                        Text("和")
                            .font(.caption)
                            .foregroundColor(MatrixTheme.secondaryTextColor)
                        
                        Button("隐私政策") {
                            // Privacy policy action
                        }
                        .font(.caption)
                        .foregroundColor(MatrixTheme.accentColor)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 32)
            
            // Signup Button
            MatrixButton(
                title: "创建账户",
                isLoading: appViewModel.isLoading,
                action: {
                    appViewModel.signUp(email: email, password: password, name: name)
                }
            )
            .disabled(!isFormValid)
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    private func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        let length = password.count
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumbers = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChars = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        var score = 0
        if length >= 8 { score += 1 }
        if hasUppercase { score += 1 }
        if hasLowercase { score += 1 }
        if hasNumbers { score += 1 }
        if hasSpecialChars { score += 1 }
        
        switch score {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }
}

// MARK: - Password Strength Indicator

struct PasswordStrengthIndicator: View {
    let strength: PasswordStrength
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .frame(height: 4)
                    .foregroundColor(colorForIndex(index))
                    .cornerRadius(2)
            }
            
            Spacer()
            
            Text(strength.description)
                .font(.caption2)
                .foregroundColor(strength.color)
        }
        .padding(.horizontal, 16)
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        switch strength {
        case .weak:
            return index == 0 ? MatrixTheme.errorColor : MatrixTheme.borderColor
        case .medium:
            return index <= 1 ? MatrixTheme.warningColor : MatrixTheme.borderColor
        case .strong:
            return MatrixTheme.successColor
        }
    }
}

enum PasswordStrength {
    case weak, medium, strong
    
    var description: String {
        switch self {
        case .weak: return "弱"
        case .medium: return "中等"
        case .strong: return "强"
        }
    }
    
    var color: Color {
        switch self {
        case .weak: return MatrixTheme.errorColor
        case .medium: return MatrixTheme.warningColor
        case .strong: return MatrixTheme.successColor
        }
    }
}

#Preview {
    AuthenticationView()
        .preferredColorScheme(.dark)
}