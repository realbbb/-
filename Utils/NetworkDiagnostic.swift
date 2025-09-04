//
//  NetworkDiagnostic.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import Foundation
import Network
import Combine

class NetworkDiagnostic: ObservableObject {
    static let shared = NetworkDiagnostic()
    
    @Published var isConnected = false
    @Published var connectionType: NWInterface.InterfaceType?
    @Published var diagnosticResults: [DiagnosticResult] = []
    @Published var isRunningDiagnostic = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
                self?.logConnectionStatus(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    private func logConnectionStatus(_ path: NWPath) {
        let status = path.status == .satisfied ? "Connected" : "Disconnected"
        let type = path.availableInterfaces.first?.type.description ?? "Unknown"
        
        print("[NetworkDiagnostic] Status: \(status), Type: \(type)")
        
        if path.status != .satisfied {
            let result = DiagnosticResult(
                test: "Network Connection",
                status: .failed,
                message: "No network connection available",
                timestamp: Date()
            )
            
            DispatchQueue.main.async {
                self.diagnosticResults.append(result)
            }
        }
    }
    
    // MARK: - Diagnostic Tests
    
    func runFullDiagnostic() {
        guard !isRunningDiagnostic else { return }
        
        isRunningDiagnostic = true
        diagnosticResults.removeAll()
        
        let tests = [
            testBasicConnectivity,
            testGoogleConnectivity,
            testAppleConnectivity,
            testGoogleAIConnectivity,
            testGeminiAPI
        ]
        
        runTests(tests) { [weak self] in
            DispatchQueue.main.async {
                self?.isRunningDiagnostic = false
            }
        }
    }
    
    private func runTests(_ tests: [(@escaping (DiagnosticResult) -> Void) -> Void], completion: @escaping () -> Void) {
        guard !tests.isEmpty else {
            completion()
            return
        }
        
        let test = tests.first!
        let remainingTests = Array(tests.dropFirst())
        
        test { [weak self] result in
            DispatchQueue.main.async {
                self?.diagnosticResults.append(result)
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                self?.runTests(remainingTests, completion: completion)
            }
        }
    }
    
    // MARK: - Individual Tests
    
    private func testBasicConnectivity(completion: @escaping (DiagnosticResult) -> Void) {
        let result = DiagnosticResult(
            test: "Basic Connectivity",
            status: isConnected ? .passed : .failed,
            message: isConnected ? "Network connection available" : "No network connection",
            timestamp: Date()
        )
        completion(result)
    }
    
    private func testGoogleConnectivity(completion: @escaping (DiagnosticResult) -> Void) {
        testURLConnectivity(
            url: "https://www.google.com",
            testName: "Google Connectivity",
            completion: completion
        )
    }
    
    private func testAppleConnectivity(completion: @escaping (DiagnosticResult) -> Void) {
        testURLConnectivity(
            url: "https://www.apple.com",
            testName: "Apple Connectivity",
            completion: completion
        )
    }
    
    private func testGoogleAIConnectivity(completion: @escaping (DiagnosticResult) -> Void) {
        testURLConnectivity(
            url: "https://generativelanguage.googleapis.com",
            testName: "Google AI Connectivity",
            completion: completion
        )
    }
    
    private func testGeminiAPI(completion: @escaping (DiagnosticResult) -> Void) {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let result: DiagnosticResult
            
            if let error = error {
                result = DiagnosticResult(
                    test: "Gemini API",
                    status: .failed,
                    message: "API request failed: \(error.localizedDescription)",
                    timestamp: Date()
                )
            } else if let httpResponse = response as? HTTPURLResponse {
                let status: DiagnosticStatus = (200...299).contains(httpResponse.statusCode) ? .passed : .warning
                let message = "HTTP \(httpResponse.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                
                result = DiagnosticResult(
                    test: "Gemini API",
                    status: status,
                    message: message,
                    timestamp: Date()
                )
            } else {
                result = DiagnosticResult(
                    test: "Gemini API",
                    status: .failed,
                    message: "Unknown response",
                    timestamp: Date()
                )
            }
            
            completion(result)
        }.resume()
    }
    
    private func testURLConnectivity(url: String, testName: String, completion: @escaping (DiagnosticResult) -> Void) {
        guard let url = URL(string: url) else {
            let result = DiagnosticResult(
                test: testName,
                status: .failed,
                message: "Invalid URL",
                timestamp: Date()
            )
            completion(result)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            let result: DiagnosticResult
            
            if let error = error {
                result = DiagnosticResult(
                    test: testName,
                    status: .failed,
                    message: "Connection failed: \(error.localizedDescription)",
                    timestamp: Date()
                )
            } else if let httpResponse = response as? HTTPURLResponse {
                let status: DiagnosticStatus = (200...299).contains(httpResponse.statusCode) ? .passed : .warning
                let message = "HTTP \(httpResponse.statusCode)"
                
                result = DiagnosticResult(
                    test: testName,
                    status: status,
                    message: message,
                    timestamp: Date()
                )
            } else {
                result = DiagnosticResult(
                    test: testName,
                    status: .failed,
                    message: "Unknown response",
                    timestamp: Date()
                )
            }
            
            completion(result)
        }.resume()
    }
    
    // MARK: - Helper Methods
    
    func clearResults() {
        diagnosticResults.removeAll()
    }
    
    var overallStatus: DiagnosticStatus {
        guard !diagnosticResults.isEmpty else { return .unknown }
        
        if diagnosticResults.contains(where: { $0.status == .failed }) {
            return .failed
        } else if diagnosticResults.contains(where: { $0.status == .warning }) {
            return .warning
        } else {
            return .passed
        }
    }
}

// MARK: - Data Models

struct DiagnosticResult: Identifiable {
    let id = UUID()
    let test: String
    let status: DiagnosticStatus
    let message: String
    let timestamp: Date
}

enum DiagnosticStatus {
    case passed, warning, failed, unknown
    
    var color: Color {
        switch self {
        case .passed: return .green
        case .warning: return .orange
        case .failed: return .red
        case .unknown: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .passed: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .failed: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Extensions

extension NWInterface.InterfaceType {
    var description: String {
        switch self {
        case .wifi: return "WiFi"
        case .cellular: return "Cellular"
        case .wiredEthernet: return "Ethernet"
        case .loopback: return "Loopback"
        case .other: return "Other"
        @unknown default: return "Unknown"
        }
    }
}

import SwiftUI

// Add Color extension for DiagnosticStatus
extension Color {
    static let diagnosticGreen = Color.green
    static let diagnosticOrange = Color.orange
    static let diagnosticRed = Color.red
    static let diagnosticGray = Color.gray
}