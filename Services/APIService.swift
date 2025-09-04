//
//  APIService.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import Foundation
import Combine

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = Config.Supabase.url
    private let apiKey = Config.Supabase.anonKey
    private let geminiService = GeminiService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        let url = URL(string: "\(baseURL)/auth/v1/token?grant_type=password")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        
        let body = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .map { $0.user }
            .eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String, name: String) -> AnyPublisher<User, Error> {
        let url = URL(string: "\(baseURL)/auth/v1/signup")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        
        let body = [
            "email": email,
            "password": password,
            "data": ["name": name]
        ] as [String : Any]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .map { $0.user }
            .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        let url = URL(string: "\(baseURL)/auth/v1/logout")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(getCurrentUserToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func getCurrentUser() -> AnyPublisher<User?, Error> {
        guard let token = getCurrentUserToken() else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/auth/v1/user")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: User.self, decoder: JSONDecoder())
            .map { $0 as User? }
            .catch { _ in Just(nil) }
            .eraseToAnyPublisher()
    }
    
    private func getCurrentUserToken() -> String? {
        // 这里应该从安全存储（如Keychain）中获取token
        return UserDefaults.standard.string(forKey: "user_token")
    }
    
    // MARK: - Expenses
    
    func createExpense(_ expense: ExpenseData) -> AnyPublisher<ExpenseData, Error> {
        let url = URL(string: "\(baseURL)/rest/v1/expenses")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(getCurrentUserToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(expense)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ExpenseData.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .eraseToAnyPublisher()
    }
    
    func getExpenses(userId: String, limit: Int = 100, offset: Int = 0) -> AnyPublisher<[ExpenseData], Error> {
        let url = URL(string: "\(baseURL)/rest/v1/expenses?user_id=eq.\(userId)&limit=\(limit)&offset=\(offset)&order=created_at.desc")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(getCurrentUserToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [ExpenseData].self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .eraseToAnyPublisher()
    }
    
    func updateExpense(_ expense: ExpenseData) -> AnyPublisher<ExpenseData, Error> {
        let url = URL(string: "\(baseURL)/rest/v1/expenses?id=eq.\(expense.id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(getCurrentUserToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(expense)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ExpenseData.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .eraseToAnyPublisher()
    }
    
    func deleteExpense(id: String) -> AnyPublisher<Void, Error> {
        let url = URL(string: "\(baseURL)/rest/v1/expenses?id=eq.\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(getCurrentUserToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - AI Processing
    
    func processAudioExpense(audioData: Data) -> AnyPublisher<ExpenseData, Error> {
        return geminiService.analyzeAudio(audioData)
            .flatMap { [weak self] analysis -> AnyPublisher<ExpenseData, Error> in
                guard let self = self else {
                    return Fail(error: APIError.unknown).eraseToAnyPublisher()
                }
                
                let expense = ExpenseData(
                    id: UUID().uuidString,
                    userId: self.getCurrentUserId(),
                    amount: analysis.extractedAmount ?? 0,
                    description: analysis.extractedDescription ?? "",
                    category: analysis.suggestedCategory,
                    date: Date(),
                    inputType: .voice,
                    aiAnalysis: analysis,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                return self.createExpense(expense)
            }
            .eraseToAnyPublisher()
    }
    
    func processTextExpense(text: String) -> AnyPublisher<ExpenseData, Error> {
        return geminiService.analyzeText(text)
            .flatMap { [weak self] analysis -> AnyPublisher<ExpenseData, Error> in
                guard let self = self else {
                    return Fail(error: APIError.unknown).eraseToAnyPublisher()
                }
                
                let expense = ExpenseData(
                    id: UUID().uuidString,
                    userId: self.getCurrentUserId(),
                    amount: analysis.extractedAmount ?? 0,
                    description: analysis.extractedDescription ?? text,
                    category: analysis.suggestedCategory,
                    date: Date(),
                    inputType: .text,
                    aiAnalysis: analysis,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                return self.createExpense(expense)
            }
            .eraseToAnyPublisher()
    }
    
    private func getCurrentUserId() -> String {
        // 这里应该从当前用户会话中获取用户ID
        return UserDefaults.standard.string(forKey: "current_user_id") ?? ""
    }
    
    // MARK: - Subscription
    
    func updateUserSubscription(userId: String, subscriptionData: [String: Any]) -> AnyPublisher<Void, Error> {
        let url = URL(string: "\(baseURL)/rest/v1/user_subscriptions?user_id=eq.\(userId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(getCurrentUserToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: subscriptionData)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

// MARK: - Supporting Types

struct AuthResponse: Codable {
    let user: User
    let session: Session?
}

struct Session: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "没有数据"
        case .decodingError:
            return "数据解析错误"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .unknown:
            return "未知错误"
        }
    }
}