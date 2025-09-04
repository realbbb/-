//
//  StripeService.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import Foundation
import Combine
import StripePaymentSheet

class StripeService: ObservableObject {
    static let shared = StripeService()
    
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let publishableKey = Config.Stripe.publishableKey
    private let secretKey = Config.Stripe.secretKey
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        StripeAPI.defaultPublishableKey = publishableKey
    }
    
    // MARK: - Payment Intent
    
    func createPaymentIntent(amount: Int, currency: String = "cny") -> AnyPublisher<String, Error> {
        let url = URL(string: "https://api.stripe.com/v1/payment_intents")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        let bodyString = "amount=\(amount)&currency=\(currency)&automatic_payment_methods[enabled]=true"
        request.httpBody = bodyString.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PaymentIntentResponse.self, decoder: JSONDecoder())
            .map { $0.clientSecret }
            .eraseToAnyPublisher()
    }
    
    // MARK: - One-time Payment
    
    func processOneTimePayment(amount: Double, currency: String = "cny") {
        isLoading = true
        errorMessage = nil
        
        let amountInCents = Int(amount * 100) // Convert to cents
        
        createPaymentIntent(amount: amountInCents, currency: currency)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.isLoading = false
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] clientSecret in
                    self?.setupPaymentSheet(clientSecret: clientSecret)
                }
            )
            .store(in: &cancellables)
    }
    
    private func setupPaymentSheet(clientSecret: String) {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = Config.App.name
        configuration.allowsDelayedPaymentMethods = true
        
        paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
        isLoading = false
    }
    
    func confirmPayment(presentingViewController: UIViewController) {
        guard let paymentSheet = paymentSheet else {
            errorMessage = "支付配置错误"
            return
        }
        
        paymentSheet.present(from: presentingViewController) { [weak self] result in
            DispatchQueue.main.async {
                self?.paymentResult = result
                self?.handlePaymentResult(result)
            }
        }
    }
    
    private func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            print("支付成功")
        case .canceled:
            print("支付取消")
        case .failed(let error):
            errorMessage = "支付失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Customer Management
    
    func createCustomer(email: String, name: String?) -> AnyPublisher<String, Error> {
        let url = URL(string: "https://api.stripe.com/v1/customers")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        var bodyComponents = ["email=\(email)"]
        if let name = name {
            bodyComponents.append("name=\(name)")
        }
        
        let bodyString = bodyComponents.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: CustomerResponse.self, decoder: JSONDecoder())
            .map { $0.id }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Setup Intent for Subscriptions
    
    func createSetupIntent(customerId: String) -> AnyPublisher<String, Error> {
        let url = URL(string: "https://api.stripe.com/v1/setup_intents")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        let bodyString = "customer=\(customerId)&automatic_payment_methods[enabled]=true"
        request.httpBody = bodyString.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SetupIntentResponse.self, decoder: JSONDecoder())
            .map { $0.clientSecret }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Subscription Management
    
    func createSubscription(customerId: String, priceId: String) -> AnyPublisher<SubscriptionResponse, Error> {
        let url = URL(string: "https://api.stripe.com/v1/subscriptions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        let bodyString = "customer=\(customerId)&items[0][price]=\(priceId)&payment_behavior=default_incomplete&payment_settings[save_default_payment_method]=on_subscription&expand[0]=latest_invoice.payment_intent"
        request.httpBody = bodyString.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SubscriptionResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func cancelSubscription(subscriptionId: String) -> AnyPublisher<Void, Error> {
        let url = URL(string: "https://api.stripe.com/v1/subscriptions/\(subscriptionId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func updateSubscription(subscriptionId: String, priceId: String) -> AnyPublisher<SubscriptionResponse, Error> {
        // First get the subscription to find the subscription item ID
        let getUrl = URL(string: "https://api.stripe.com/v1/subscriptions/\(subscriptionId)")!
        
        var getRequest = URLRequest(url: getUrl)
        getRequest.httpMethod = "GET"
        getRequest.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: getRequest)
            .map(\.data)
            .decode(type: SubscriptionResponse.self, decoder: JSONDecoder())
            .flatMap { [weak self] subscription -> AnyPublisher<SubscriptionResponse, Error> in
                guard let self = self,
                      let itemId = subscription.items.data.first?.id else {
                    return Fail(error: StripeError.invalidSubscription).eraseToAnyPublisher()
                }
                
                let updateUrl = URL(string: "https://api.stripe.com/v1/subscriptions/\(subscriptionId)")!
                
                var updateRequest = URLRequest(url: updateUrl)
                updateRequest.httpMethod = "POST"
                updateRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                updateRequest.setValue("Bearer \(self.secretKey)", forHTTPHeaderField: "Authorization")
                
                let bodyString = "items[0][id]=\(itemId)&items[0][price]=\(priceId)&proration_behavior=immediate_with_remainder"
                updateRequest.httpBody = bodyString.data(using: .utf8)
                
                return URLSession.shared.dataTaskPublisher(for: updateRequest)
                    .map(\.data)
                    .decode(type: SubscriptionResponse.self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Response Models

struct PaymentIntentResponse: Codable {
    let id: String
    let clientSecret: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientSecret = "client_secret"
    }
}

struct CustomerResponse: Codable {
    let id: String
    let email: String
    let name: String?
}

struct SetupIntentResponse: Codable {
    let id: String
    let clientSecret: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientSecret = "client_secret"
    }
}

struct SubscriptionResponse: Codable {
    let id: String
    let status: String
    let currentPeriodStart: Int
    let currentPeriodEnd: Int
    let cancelAtPeriodEnd: Bool
    let items: SubscriptionItemList
    let latestInvoice: Invoice?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case currentPeriodStart = "current_period_start"
        case currentPeriodEnd = "current_period_end"
        case cancelAtPeriodEnd = "cancel_at_period_end"
        case items
        case latestInvoice = "latest_invoice"
    }
}

struct SubscriptionItemList: Codable {
    let data: [SubscriptionItem]
}

struct SubscriptionItem: Codable {
    let id: String
    let price: Price
}

struct Price: Codable {
    let id: String
    let unitAmount: Int?
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case unitAmount = "unit_amount"
        case currency
    }
}

struct Invoice: Codable {
    let id: String
    let paymentIntent: PaymentIntent?
    
    enum CodingKeys: String, CodingKey {
        case id
        case paymentIntent = "payment_intent"
    }
}

struct PaymentIntent: Codable {
    let id: String
    let clientSecret: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientSecret = "client_secret"
    }
}

// MARK: - Error Types

enum StripeError: Error, LocalizedError {
    case invalidConfiguration
    case paymentFailed
    case invalidSubscription
    case networkError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "支付配置错误"
        case .paymentFailed:
            return "支付失败"
        case .invalidSubscription:
            return "订阅信息错误"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .unknown:
            return "未知错误"
        }
    }
}