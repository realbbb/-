//
//  AppViewModel.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import Foundation
import Combine
import SwiftUI

class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAlert = false
    @Published var appState = AppState()
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication
    
    func checkAuthenticationStatus() {
        isLoading = true
        
        apiService.getCurrentUser()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Authentication check failed: \(error)")
                        self?.isAuthenticated = false
                        self?.currentUser = nil
                    }
                },
                receiveValue: { [weak self] user in
                    self?.currentUser = user
                    self?.isAuthenticated = user != nil
                }
            )
            .store(in: &cancellables)
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        apiService.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] user in
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    // 保存用户token到本地
                    UserDefaults.standard.set(user.id, forKey: "current_user_id")
                }
            )
            .store(in: &cancellables)
    }
    
    func signUp(email: String, password: String, name: String) {
        isLoading = true
        errorMessage = nil
        
        apiService.signUp(email: email, password: password, name: name)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] user in
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    // 保存用户token到本地
                    UserDefaults.standard.set(user.id, forKey: "current_user_id")
                }
            )
            .store(in: &cancellables)
    }
    
    func signOut() {
        isLoading = true
        
        apiService.signOut()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    // 无论成功失败都清除本地状态
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                    UserDefaults.standard.removeObject(forKey: "current_user_id")
                    UserDefaults.standard.removeObject(forKey: "user_token")
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
        showingAlert = false
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showingAlert = true
    }
}

// MARK: - Expense ViewModel

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [ExpenseData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAlert = false
    
    // Filters
    @Published var selectedCategory: ExpenseCategory?
    @Published var searchText = ""
    @Published var dateRange: ClosedRange<Date>?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var filteredExpenses: [ExpenseData] {
        var filtered = expenses
        
        // Category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Date range filter
        if let range = dateRange {
            filtered = filtered.filter { range.contains($0.date) }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    init() {
        loadExpenses()
    }
    
    func loadExpenses() {
        guard let userId = UserDefaults.standard.string(forKey: "current_user_id") else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        apiService.getExpenses(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] expenses in
                    self?.expenses = expenses
                }
            )
            .store(in: &cancellables)
    }
    
    func addExpense(_ expense: ExpenseData) {
        apiService.createExpense(expense)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] newExpense in
                    self?.expenses.insert(newExpense, at: 0)
                }
            )
            .store(in: &cancellables)
    }
    
    func updateExpense(_ expense: ExpenseData) {
        apiService.updateExpense(expense)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] updatedExpense in
                    if let index = self?.expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                        self?.expenses[index] = updatedExpense
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteExpense(_ expense: ExpenseData) {
        apiService.deleteExpense(id: expense.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.expenses.removeAll { $0.id == expense.id }
                }
            )
            .store(in: &cancellables)
    }
    
    func processAudioExpense(audioData: Data) {
        isLoading = true
        
        apiService.processAudioExpense(audioData: audioData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] expense in
                    self?.expenses.insert(expense, at: 0)
                }
            )
            .store(in: &cancellables)
    }
    
    func processTextExpense(text: String) {
        isLoading = true
        
        apiService.processTextExpense(text: text)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] expense in
                    self?.expenses.insert(expense, at: 0)
                }
            )
            .store(in: &cancellables)
    }
    
    func clearFilters() {
        selectedCategory = nil
        searchText = ""
        dateRange = nil
    }
    
    func clearError() {
        errorMessage = nil
        showingAlert = false
    }
}

// MARK: - Text Input ViewModel

class TextInputViewModel: ObservableObject {
    @Published var textInput = TextInput()
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func processText(_ text: String, completion: @escaping (Result<ExpenseData, Error>) -> Void) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(TextInputError.emptyText))
            return
        }
        
        isProcessing = true
        textInput.isProcessing = true
        textInput.error = nil
        
        apiService.processTextExpense(text: text)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    self?.isProcessing = false
                    self?.textInput.isProcessing = false
                    
                    if case .failure(let error) = result {
                        self?.textInput.error = error.localizedDescription
                        self?.errorMessage = error.localizedDescription
                        completion(.failure(error))
                    }
                },
                receiveValue: { [weak self] expense in
                    self?.textInput.text = ""
                    completion(.success(expense))
                }
            )
            .store(in: &cancellables)
    }
    
    func clearInput() {
        textInput.text = ""
        textInput.error = nil
        errorMessage = nil
    }
}

enum TextInputError: Error, LocalizedError {
    case emptyText
    
    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "请输入文本内容"
        }
    }
}

// MARK: - Statistics ViewModel

class StatisticsViewModel: ObservableObject {
    @Published var statistics: ExpenseStatistics?
    @Published var selectedPeriod: StatisticsPeriod = .month
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var aiAnalysis: String?
    @Published var isLoadingAIAnalysis = false
    
    private let apiService = APIService.shared
    private let geminiService = GeminiService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var expenses: [ExpenseData] = []
    
    init() {
        loadStatistics()
    }
    
    func loadStatistics() {
        guard let userId = UserDefaults.standard.string(forKey: "current_user_id") else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        apiService.getExpenses(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] expenses in
                    self?.expenses = expenses
                    self?.calculateStatistics()
                }
            )
            .store(in: &cancellables)
    }
    
    func calculateStatistics() {
        let filteredExpenses = filterExpensesByPeriod(expenses, period: selectedPeriod)
        
        let totalAmount = filteredExpenses.reduce(0) { $0 + $1.amount }
        let transactionCount = filteredExpenses.count
        let averageAmount = transactionCount > 0 ? totalAmount / Double(transactionCount) : 0
        
        // Calculate category breakdown
        let categoryGroups = Dictionary(grouping: filteredExpenses) { $0.category }
        let categoryBreakdown = categoryGroups.map { category, expenses in
            let amount = expenses.reduce(0) { $0 + $1.amount }
            let percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0
            return CategoryStatistic(
                category: category,
                amount: amount,
                count: expenses.count,
                percentage: percentage
            )
        }.sorted { $0.amount > $1.amount }
        
        // Calculate monthly trend
        let monthlyGroups = Dictionary(grouping: filteredExpenses) { expense in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            return formatter.string(from: expense.date)
        }
        
        let monthlyTrend = monthlyGroups.map { month, expenses in
            MonthlyExpense(
                month: month,
                amount: expenses.reduce(0) { $0 + $1.amount },
                count: expenses.count
            )
        }.sorted { $0.month < $1.month }
        
        statistics = ExpenseStatistics(
            totalAmount: totalAmount,
            transactionCount: transactionCount,
            averageAmount: averageAmount,
            categoryBreakdown: categoryBreakdown,
            monthlyTrend: monthlyTrend,
            period: selectedPeriod
        )
    }
    
    func generateAIAnalysis() {
        guard !expenses.isEmpty else {
            errorMessage = "没有足够的数据进行AI分析"
            return
        }
        
        isLoadingAIAnalysis = true
        
        geminiService.analyzeFinancialData(expenses)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingAIAnalysis = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] analysis in
                    self?.aiAnalysis = analysis
                }
            )
            .store(in: &cancellables)
    }
    
    private func filterExpensesByPeriod(_ expenses: [ExpenseData], period: StatisticsPeriod) -> [ExpenseData] {
        let now = Date()
        let calendar = Calendar.current
        
        switch period {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return expenses.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return expenses.filter { $0.date >= monthAgo }
        case .quarter:
            let quarterAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return expenses.filter { $0.date >= quarterAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return expenses.filter { $0.date >= yearAgo }
        case .all:
            return expenses
        }
    }
    
    func updatePeriod(_ period: StatisticsPeriod) {
        selectedPeriod = period
        calculateStatistics()
    }
    
    func clearError() {
        errorMessage = nil
    }
}