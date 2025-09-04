//
//  MatrixTheme.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI

// MARK: - Matrix Theme

struct MatrixTheme {
    // MARK: - Colors
    static let primaryColor = Color(red: 0.0, green: 1.0, blue: 0.0) // Matrix green
    static let secondaryColor = Color(red: 0.0, green: 0.8, blue: 0.0)
    static let accentColor = Color(red: 0.0, green: 0.9, blue: 0.4)
    static let backgroundColor = Color.black
    static let surfaceColor = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let cardColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    
    // Text Colors
    static let primaryTextColor = Color.white
    static let secondaryTextColor = Color(red: 0.7, green: 0.7, blue: 0.7)
    static let tertiaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // Status Colors
    static let successColor = Color(red: 0.0, green: 1.0, blue: 0.0)
    static let warningColor = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let errorColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    static let infoColor = Color(red: 0.0, green: 0.8, blue: 1.0)
    
    // Border and Divider
    static let borderColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let dividerColor = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    // MARK: - Typography
    static let titleFont = Font.system(size: 28, weight: .bold, design: .monospaced)
    static let headlineFont = Font.system(size: 22, weight: .semibold, design: .monospaced)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .monospaced)
    static let captionFont = Font.system(size: 12, weight: .regular, design: .monospaced)
    
    // MARK: - Spacing
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // MARK: - Corner Radius
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 16
    
    // MARK: - Shadows
    static let shadowColor = Color.black.opacity(0.3)
    static let shadowRadius: CGFloat = 8
    static let shadowOffset = CGSize(width: 0, height: 4)
}

// MARK: - Matrix UI Components

struct MatrixButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, tertiary
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MatrixTheme.bodyFont)
                .fontWeight(.medium)
                .foregroundColor(foregroundColor)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(MatrixTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return MatrixTheme.backgroundColor
        case .secondary: return MatrixTheme.primaryColor
        case .tertiary: return MatrixTheme.primaryTextColor
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return MatrixTheme.primaryColor
        case .secondary: return MatrixTheme.surfaceColor
        case .tertiary: return Color.clear
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary: return MatrixTheme.primaryColor
        case .secondary: return MatrixTheme.primaryColor
        case .tertiary: return MatrixTheme.borderColor
        }
    }
}

struct MatrixCyberpunkButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
                
                Text(title)
                    .font(MatrixTheme.bodyFont)
                    .fontWeight(.medium)
            }
            .foregroundColor(MatrixTheme.backgroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [MatrixTheme.primaryColor, MatrixTheme.accentColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(MatrixTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [MatrixTheme.primaryColor, MatrixTheme.accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: MatrixTheme.primaryColor.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MatrixToolbarButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(MatrixTheme.primaryColor)
                .frame(width: 44, height: 44)
                .background(MatrixTheme.surfaceColor)
                .cornerRadius(MatrixTheme.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: MatrixTheme.smallCornerRadius)
                        .stroke(MatrixTheme.primaryColor, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MatrixCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(MatrixTheme.mediumSpacing)
            .background(MatrixTheme.cardColor)
            .cornerRadius(MatrixTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                    .stroke(MatrixTheme.borderColor, lineWidth: 1)
            )
            .shadow(
                color: MatrixTheme.shadowColor,
                radius: MatrixTheme.shadowRadius,
                x: MatrixTheme.shadowOffset.width,
                y: MatrixTheme.shadowOffset.height
            )
    }
}

struct MatrixTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isSecure: Bool
    
    init(placeholder: String, text: Binding<String>, icon: String? = nil, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
                    .frame(width: 20)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .font(MatrixTheme.bodyFont)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .font(MatrixTheme.bodyFont)
            }
        }
        .padding(.horizontal, MatrixTheme.mediumSpacing)
        .padding(.vertical, 12)
        .background(MatrixTheme.surfaceColor)
        .cornerRadius(MatrixTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                .stroke(MatrixTheme.borderColor, lineWidth: 1)
        )
    }
}

struct MatrixLoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: MatrixTheme.primaryColor))
                .scaleEffect(1.2)
            
            Text(message)
                .font(MatrixTheme.bodyFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
        }
        .padding(MatrixTheme.largeSpacing)
        .background(MatrixTheme.cardColor)
        .cornerRadius(MatrixTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                .stroke(MatrixTheme.borderColor, lineWidth: 1)
        )
    }
}

struct MatrixAlert: View {
    let title: String
    let message: String
    let type: AlertType
    
    enum AlertType {
        case success, warning, error, info
        
        var color: Color {
            switch self {
            case .success: return MatrixTheme.successColor
            case .warning: return MatrixTheme.warningColor
            case .error: return MatrixTheme.errorColor
            case .info: return MatrixTheme.infoColor
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MatrixTheme.bodyFont)
                    .fontWeight(.medium)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Text(message)
                    .font(MatrixTheme.captionFont)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
            }
            
            Spacer()
        }
        .padding(MatrixTheme.mediumSpacing)
        .background(MatrixTheme.cardColor)
        .cornerRadius(MatrixTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                .stroke(type.color, lineWidth: 1)
        )
    }
}

struct MatrixFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? MatrixTheme.backgroundColor : MatrixTheme.primaryColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? MatrixTheme.primaryColor : MatrixTheme.surfaceColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(MatrixTheme.primaryColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MatrixStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(MatrixTheme.headlineFont)
                .fontWeight(.bold)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            Text(title)
                .font(MatrixTheme.captionFont)
                .foregroundColor(MatrixTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(MatrixTheme.mediumSpacing)
        .background(MatrixTheme.cardColor)
        .cornerRadius(MatrixTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: MatrixTheme.cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct MatrixEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(MatrixTheme.secondaryTextColor)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(MatrixTheme.headlineFont)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                
                Text(subtitle)
                    .font(MatrixTheme.bodyFont)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(MatrixTheme.extraLargeSpacing)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        MatrixButton(title: "Primary Button", style: .primary) { }
        MatrixButton(title: "Secondary Button", style: .secondary) { }
        MatrixCyberpunkButton(title: "Cyberpunk Button", icon: "bolt.fill") { }
        
        MatrixCard {
            Text("Matrix Card Content")
                .foregroundColor(MatrixTheme.primaryTextColor)
        }
        
        MatrixTextField(placeholder: "Enter text", text: .constant(""), icon: "person")
        
        MatrixAlert(
            title: "Success",
            message: "Operation completed successfully",
            type: .success
        )
    }
    .padding()
    .background(MatrixTheme.backgroundColor)
    .preferredColorScheme(.dark)
}