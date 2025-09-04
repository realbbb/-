//
//  CyberpunkBackgroundView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

struct CyberpunkBackgroundView: View {
    @State private var animationOffset: CGFloat = 0
    @State private var glitchOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base background
            MatrixTheme.backgroundColor
                .ignoresSafeArea()
            
            // Matrix rain effect
            matrixRainEffect
            
            // Grid overlay
            gridOverlay
            
            // Glitch effect
            glitchEffect
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private var matrixRainEffect: some View {
        GeometryReader { geometry in
            ForEach(0..<20, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<50, id: \.self) { row in
                        Text(matrixCharacter())
                            .font(.system(size: 12, family: .monospaced))
                            .foregroundColor(
                                MatrixTheme.primaryColor
                                    .opacity(Double.random(in: 0.1...0.8))
                            )
                            .animation(
                                .easeInOut(duration: Double.random(in: 0.5...2.0))
                                    .repeatForever(autoreverses: true),
                                value: animationOffset
                            )
                    }
                }
                .offset(
                    x: CGFloat(column) * (geometry.size.width / 20),
                    y: animationOffset + CGFloat(column * 10)
                )
            }
        }
        .clipped()
    }
    
    private var gridOverlay: some View {
        GeometryReader { geometry in
            Path { path in
                // Vertical lines
                for i in stride(from: 0, through: geometry.size.width, by: 50) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i, y: geometry.size.height))
                }
                
                // Horizontal lines
                for i in stride(from: 0, through: geometry.size.height, by: 50) {
                    path.move(to: CGPoint(x: 0, y: i))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: i))
                }
            }
            .stroke(
                MatrixTheme.primaryColor.opacity(0.1),
                lineWidth: 0.5
            )
        }
    }
    
    private var glitchEffect: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        MatrixTheme.primaryColor.opacity(0.05),
                        Color.clear,
                        MatrixTheme.accentColor.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .offset(x: glitchOffset)
            .animation(
                .easeInOut(duration: 0.1)
                    .repeatForever(autoreverses: true),
                value: glitchOffset
            )
    }
    
    private func matrixCharacter() -> String {
        let characters = "01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
        return String(characters.randomElement() ?? "0")
    }
    
    private func startAnimations() {
        // Matrix rain animation
        withAnimation(
            .linear(duration: 10)
                .repeatForever(autoreverses: false)
        ) {
            animationOffset = 1000
        }
        
        // Glitch effect
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...5), repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                glitchOffset = Double.random(in: -5...5)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    glitchOffset = 0
                }
            }
        }
    }
}

#Preview {
    CyberpunkBackgroundView()
        .preferredColorScheme(.dark)
}