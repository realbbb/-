//
//  LaunchScreenView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var showMatrix = false
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            // Background
            MatrixTheme.backgroundColor
                .ignoresSafeArea()
            
            // Matrix effect background
            if showMatrix {
                matrixBackground
            }
            
            // Main content
            VStack(spacing: 32) {
                // App Icon
                appIconSection
                
                // App Name
                appNameSection
                
                // Version Info
                versionSection
                
                // Loading indicator
                loadingSection
            }
            .opacity(opacity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private var matrixBackground: some View {
        GeometryReader { geometry in
            ForEach(0..<15, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<30, id: \.self) { row in
                        Text(matrixCharacter())
                            .font(.system(size: 14, family: .monospaced))
                            .foregroundColor(
                                MatrixTheme.primaryColor
                                    .opacity(Double.random(in: 0.1...0.6))
                            )
                    }
                }
                .offset(
                    x: CGFloat(column) * (geometry.size.width / 15),
                    y: isAnimating ? geometry.size.height : -200
                )
                .animation(
                    .linear(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            }
        }
        .clipped()
    }
    
    private var appIconSection: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            MatrixTheme.primaryColor.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(
                    .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Main icon background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            MatrixTheme.primaryColor,
                            MatrixTheme.accentColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Circle()
                        .stroke(MatrixTheme.primaryColor, lineWidth: 2)
                )
            
            // Icon symbol
            Image(systemName: "yensign.circle.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(MatrixTheme.backgroundColor)
        }
    }
    
    private var appNameSection: some View {
        VStack(spacing: 8) {
            Text("秋后算账")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(MatrixTheme.primaryTextColor)
                .tracking(2)
            
            Text("AI智能记账助手")
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
        }
    }
    
    private var versionSection: some View {
        VStack(spacing: 4) {
            Text("黑客版 v1.0")
                .font(MatrixTheme.captionFont)
                .foregroundColor(MatrixTheme.accentColor)
            
            Text("带支付功能 · AI总结存在bug")
                .font(.system(size: 10, family: .monospaced))
                .foregroundColor(MatrixTheme.warningColor)
        }
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            // Custom loading animation
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(MatrixTheme.primaryColor)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            
            Text("正在初始化...")
                .font(MatrixTheme.captionFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
        }
    }
    
    private func matrixCharacter() -> String {
        let characters = "01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン¥$€£"
        return String(characters.randomElement() ?? "0")
    }
    
    private func startAnimations() {
        // Start matrix background
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showMatrix = true
        }
        
        // Fade in main content
        withAnimation(.easeInOut(duration: 1.0)) {
            opacity = 1.0
        }
        
        // Start loading animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = true
        }
    }
}

#Preview {
    LaunchScreenView()
        .preferredColorScheme(.dark)
}