//
//  Config.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import Foundation

struct Config {
    
    // MARK: - Supabase Configuration
    struct Supabase {
        static let url = "https://your-project.supabase.co"
        static let anonKey = "your-anon-key"
    }
    
    // MARK: - Gemini AI Configuration
    struct Gemini {
        static let apiKey = "your-gemini-api-key"
        static let baseURL = "https://generativelanguage.googleapis.com/v1beta"
        static let model = "gemini-pro"
    }
    
    // MARK: - Stripe Configuration
    struct Stripe {
        // 测试环境配置
        static let isTestMode = true
        
        // 测试密钥
        static let testPublishableKey = "pk_test_your_test_publishable_key"
        static let testSecretKey = "sk_test_your_test_secret_key"
        
        // 生产密钥
        static let livePublishableKey = "pk_live_your_live_publishable_key"
        static let liveSecretKey = "sk_live_your_live_secret_key"
        
        // 当前使用的密钥
        static var publishableKey: String {
            return isTestMode ? testPublishableKey : livePublishableKey
        }
        
        static var secretKey: String {
            return isTestMode ? testSecretKey : liveSecretKey
        }
        
        // 产品价格ID
        struct ProductPrices {
            // 测试价格ID
            struct Test {
                static let basicMonthly = "price_test_basic_monthly"
                static let premiumMonthly = "price_test_premium_monthly"
                static let professionalMonthly = "price_test_professional_monthly"
                static let basicYearly = "price_test_basic_yearly"
                static let premiumYearly = "price_test_premium_yearly"
                static let professionalYearly = "price_test_professional_yearly"
            }
            
            // 生产价格ID
            struct Live {
                static let basicMonthly = "price_live_basic_monthly"
                static let premiumMonthly = "price_live_premium_monthly"
                static let professionalMonthly = "price_live_professional_monthly"
                static let basicYearly = "price_live_basic_yearly"
                static let premiumYearly = "price_live_premium_yearly"
                static let professionalYearly = "price_live_professional_yearly"
            }
            
            // 当前使用的价格ID
            static var basicMonthly: String {
                return isTestMode ? Test.basicMonthly : Live.basicMonthly
            }
            
            static var premiumMonthly: String {
                return isTestMode ? Test.premiumMonthly : Live.premiumMonthly
            }
            
            static var professionalMonthly: String {
                return isTestMode ? Test.professionalMonthly : Live.professionalMonthly
            }
            
            static var basicYearly: String {
                return isTestMode ? Test.basicYearly : Live.basicYearly
            }
            
            static var premiumYearly: String {
                return isTestMode ? Test.premiumYearly : Live.premiumYearly
            }
            
            static var professionalYearly: String {
                return isTestMode ? Test.professionalYearly : Live.professionalYearly
            }
        }
    }
    
    // MARK: - App Configuration
    struct App {
        static let name = "AI自动记账助手"
        static let version = "1.0.0"
        static let buildNumber = "1"
    }
}