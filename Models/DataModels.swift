//
//  DataModels.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import Foundation
import SwiftUI

// MARK: - User Profile
struct UserProfile: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let avatarURL: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Expense Data
struct ExpenseData: Codable, Identifiable {
    let id: String
    let userId: String
    let amount: Double
    let description: String
    let category: ExpenseCategory
    let date: Date
    let inputType: InputType
    let aiAnalysis: AIAnalysis?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case amount
        case description
        case category
        case date
        case inputType = "input_type"
        case aiAnalysis = "ai_analysis"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case createdAt = "created_at"
    }
}

// MARK: - Subscription Plan
struct SubscriptionPlan: Identifiable, Codable {
    let id: String
    let name: String
    let displayName: String
    let price: Double
    let currency: String
    let interval: String // "month" or "year"
    let features: [String]
    let stripePriceId: String
    let isPopular: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case displayName = "display_name"
        case price
        case currency
        case interval
        case features
        case stripePriceId = "stripe_price_id"
        case isPopular = "is_popular"
    }
    
    static let free = SubscriptionPlan(
        id: "free",
        name: "free",
        displayName: "免费版",
        price: 0,
        currency: "CNY",
        interval: "month",
        features: ["基础记账功能", "简单统计", "最多100条记录"],
        stripePriceId: "",
        isPopular: false
    )
    
    static let basic = SubscriptionPlan(
        id: "basic",
        name: "basic",
        displayName: "基础版",
        price: 9.9,
        currency: "CNY",
        interval: "month",
        features: ["AI智能记账", "详细统计分析", "无限记录", "数据导出"],
        stripePriceId: Config.Stripe.ProductPrices.basicMonthly,
        isPopular: false
    )
    
    static let premium = SubscriptionPlan(
        id: "premium",
        name: "premium",
        displayName: "高级版",
        price: 19.9,
        currency: "CNY",
        interval: "month",
        features: ["所有基础功能", "AI财务分析", "预算管理", "多设备同步", "优先客服"],
        stripePriceId: Config.Stripe.ProductPrices.premiumMonthly,
        isPopular: true
    )
    
    static let professional = SubscriptionPlan(
        id: "professional",
        name: "professional",
        displayName: "专业版",
        price: 39.9,
        currency: "CNY",
        interval: "month",
        features: ["所有高级功能", "高级AI分析", "自定义报表", "API访问", "专属客服"],
        stripePriceId: Config.Stripe.ProductPrices.professionalMonthly,
        isPopular: false
    )
    
    static let allPlans = [free, basic, premium, professional]
}

// MARK: - Voice Transcription
struct VoiceTranscription: Codable {
    let text: String
    let confidence: Double
    let language: String
    let duration: TimeInterval
}

// MARK: - Input Type
enum InputType: String, Codable, CaseIterable {
    case voice = "voice"
    case text = "text"
    case manual = "manual"
    
    var displayName: String {
        switch self {
        case .voice:
            return "语音输入"
        case .text:
            return "文本输入"
        case .manual:
            return "手动输入"
        }
    }
}

// MARK: - Expense Category
enum ExpenseCategory: String, Codable, CaseIterable {
    case food = "food"
    case transport = "transport"
    case shopping = "shopping"
    case entertainment = "entertainment"
    case healthcare = "healthcare"
    case education = "education"
    case housing = "housing"
    case utilities = "utilities"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .food:
            return "餐饮"
        case .transport:
            return "交通"
        case .shopping:
            return "购物"
        case .entertainment:
            return "娱乐"
        case .healthcare:
            return "医疗"
        case .education:
            return "教育"
        case .housing:
            return "住房"
        case .utilities:
            return "水电"
        case .other:
            return "其他"
        }
    }
    
    var icon: String {
        switch self {
        case .food:
            return "fork.knife"
        case .transport:
            return "car.fill"
        case .shopping:
            return "bag.fill"
        case .entertainment:
            return "gamecontroller.fill"
        case .healthcare:
            return "cross.fill"
        case .education:
            return "book.fill"
        case .housing:
            return "house.fill"
        case .utilities:
            return "bolt.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food:
            return .orange
        case .transport:
            return .blue
        case .shopping:
            return .pink
        case .entertainment:
            return .purple
        case .healthcare:
            return .red
        case .education:
            return .green
        case .housing:
            return .brown
        case .utilities:
            return .yellow
        case .other:
            return .gray
        }
    }
}

// MARK: - Expense
struct Expense: Identifiable, Codable {
    let id: String
    let userId: String
    let amount: Double
    let description: String
    let category: ExpenseCategory
    let date: Date
    let inputType: InputType
    let aiAnalysis: AIAnalysis?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case amount
        case description
        case category
        case date
        case inputType = "input_type"
        case aiAnalysis = "ai_analysis"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - AI Analysis
struct AIAnalysis: Codable {
    let confidence: Double
    let suggestedCategory: ExpenseCategory
    let extractedAmount: Double?
    let extractedDescription: String?
    let reasoning: String
    let alternatives: [AlternativeAnalysis]?
    
    enum CodingKeys: String, CodingKey {
        case confidence
        case suggestedCategory = "suggested_category"
        case extractedAmount = "extracted_amount"
        case extractedDescription = "extracted_description"
        case reasoning
        case alternatives
    }
}

struct AlternativeAnalysis: Codable {
    let category: ExpenseCategory
    let confidence: Double
    let reasoning: String
}

// MARK: - Subscription
struct Subscription: Identifiable, Codable {
    let id: String
    let userId: String
    let planId: String
    let status: SubscriptionStatus
    let currentPeriodStart: Date
    let currentPeriodEnd: Date
    let cancelAtPeriodEnd: Bool
    let stripeSubscriptionId: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case planId = "plan_id"
        case status
        case currentPeriodStart = "current_period_start"
        case currentPeriodEnd = "current_period_end"
        case cancelAtPeriodEnd = "cancel_at_period_end"
        case stripeSubscriptionId = "stripe_subscription_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - User Subscription
struct UserSubscription: Codable {
    let subscription: Subscription?
    let plan: SubscriptionPlan
    
    var isActive: Bool {
        guard let subscription = subscription else { return false }
        return subscription.status == .active && subscription.currentPeriodEnd > Date()
    }
    
    var isPremium: Bool {
        return isActive && plan.id != "free"
    }
}

// MARK: - Subscription Status
enum SubscriptionStatus: String, Codable {
    case active = "active"
    case canceled = "canceled"
    case pastDue = "past_due"
    case unpaid = "unpaid"
    case trialing = "trialing"
    case incomplete = "incomplete"
    case incompleteExpired = "incomplete_expired"
    
    var displayName: String {
        switch self {
        case .active:
            return "活跃"
        case .canceled:
            return "已取消"
        case .pastDue:
            return "逾期"
        case .unpaid:
            return "未付款"
        case .trialing:
            return "试用中"
        case .incomplete:
            return "未完成"
        case .incompleteExpired:
            return "已过期"
        }
    }
}

// MARK: - Gemini API Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig?
    
    enum CodingKeys: String, CodingKey {
        case contents
        case generationConfig = "generation_config"
    }
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
    let role: String?
}

struct GeminiPart: Codable {
    let text: String?
    let inlineData: GeminiInlineData?
    
    enum CodingKeys: String, CodingKey {
        case text
        case inlineData = "inline_data"
    }
}

struct GeminiInlineData: Codable {
    let mimeType: String
    let data: String
    
    enum CodingKeys: String, CodingKey {
        case mimeType = "mime_type"
        case data
    }
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double?
    let topK: Int?
    let topP: Double?
    let maxOutputTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case temperature
        case topK = "top_k"
        case topP = "top_p"
        case maxOutputTokens = "max_output_tokens"
    }
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
    let usageMetadata: GeminiUsageMetadata?
    
    enum CodingKeys: String, CodingKey {
        case candidates
        case usageMetadata = "usage_metadata"
    }
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
    let finishReason: String?
    let index: Int?
    
    enum CodingKeys: String, CodingKey {
        case content
        case finishReason = "finish_reason"
        case index
    }
}

struct GeminiUsageMetadata: Codable {
    let promptTokenCount: Int?
    let candidatesTokenCount: Int?
    let totalTokenCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case promptTokenCount = "prompt_token_count"
        case candidatesTokenCount = "candidates_token_count"
        case totalTokenCount = "total_token_count"
    }
}

// MARK: - Statistics Models
struct ExpenseStatistics: Codable {
    let totalAmount: Double
    let transactionCount: Int
    let averageAmount: Double
    let categoryBreakdown: [CategoryStatistic]
    let monthlyTrend: [MonthlyExpense]
    let period: StatisticsPeriod
    
    enum CodingKeys: String, CodingKey {
        case totalAmount = "total_amount"
        case transactionCount = "transaction_count"
        case averageAmount = "average_amount"
        case categoryBreakdown = "category_breakdown"
        case monthlyTrend = "monthly_trend"
        case period
    }
}

struct CategoryStatistic: Codable, Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let amount: Double
    let count: Int
    let percentage: Double
    
    enum CodingKeys: String, CodingKey {
        case category, amount, count, percentage
    }
}

struct MonthlyExpense: Codable, Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case month, amount, count
    }
}

enum StatisticsPeriod: String, Codable, CaseIterable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    case all = "all"
    
    var displayName: String {
        switch self {
        case .week:
            return "本周"
        case .month:
            return "本月"
        case .quarter:
            return "本季度"
        case .year:
            return "本年"
        case .all:
            return "全部"
        }
    }
}

struct TrendData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

// MARK: - UI Models
struct TextInput {
    var text: String = ""
    var isProcessing: Bool = false
    var error: String? = nil
}

struct AppState {
    var selectedTab: TabSelection = .home
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showingAlert: Bool = false
}

enum TabSelection: String, CaseIterable {
    case home = "home"
    case expenses = "expenses"
    case statistics = "statistics"
    case settings = "settings"
    
    var displayName: String {
        switch self {
        case .home:
            return "首页"
        case .expenses:
            return "支出"
        case .statistics:
            return "统计"
        case .settings:
            return "设置"
        }
    }
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .expenses:
            return "list.bullet"
        case .statistics:
            return "chart.bar.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}