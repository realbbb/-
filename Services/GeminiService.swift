//
//  GeminiService.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import Foundation
import Combine

class GeminiService: ObservableObject {
    static let shared = GeminiService()
    
    private let apiKey = Config.Gemini.apiKey
    private let baseURL = Config.Gemini.baseURL
    private let model = Config.Gemini.model
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Audio Analysis
    
    func analyzeAudio(_ audioData: Data) -> AnyPublisher<AIAnalysis, Error> {
        // 首先转录音频
        return transcribeAudio(audioData)
            .flatMap { [weak self] transcription -> AnyPublisher<AIAnalysis, Error> in
                guard let self = self else {
                    return Fail(error: GeminiError.unknown).eraseToAnyPublisher()
                }
                return self.analyzeText(transcription.text)
            }
            .eraseToAnyPublisher()
    }
    
    private func transcribeAudio(_ audioData: Data) -> AnyPublisher<VoiceTranscription, Error> {
        let url = URL(string: "\(baseURL)/models/\(model):generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let base64Audio = audioData.base64EncodedString()
        
        let geminiRequest = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(
                            text: "请转录这段音频内容，并识别其中的消费信息。",
                            inlineData: nil
                        ),
                        GeminiPart(
                            text: nil,
                            inlineData: GeminiInlineData(
                                mimeType: "audio/wav",
                                data: base64Audio
                            )
                        )
                    ],
                    role: "user"
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.1,
                topK: 1,
                topP: 0.8,
                maxOutputTokens: 1024
            )
        )
        
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(geminiRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GeminiResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let candidate = response.candidates.first,
                      let text = candidate.content.parts.first?.text else {
                    throw GeminiError.noResponse
                }
                
                return VoiceTranscription(
                    text: text,
                    confidence: 0.9, // Gemini doesn't provide confidence scores
                    language: "zh-CN",
                    duration: 0 // We don't have duration info
                )
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Text Analysis
    
    func analyzeText(_ text: String) -> AnyPublisher<AIAnalysis, Error> {
        let url = URL(string: "\(baseURL)/models/\(model):generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        请分析以下文本中的消费信息，并以JSON格式返回结果：
        
        文本："\(text)"
        
        请返回以下格式的JSON：
        {
            "confidence": 0.95,
            "suggested_category": "food",
            "extracted_amount": 25.50,
            "extracted_description": "午餐",
            "reasoning": "根据文本内容分析...",
            "alternatives": [
                {
                    "category": "entertainment",
                    "confidence": 0.3,
                    "reasoning": "可能的替代分类原因"
                }
            ]
        }
        
        支持的分类包括：food, transport, shopping, entertainment, healthcare, education, housing, utilities, other
        
        如果无法识别金额，请设置extracted_amount为null。
        如果无法确定描述，请设置extracted_description为null。
        confidence应该是0-1之间的数值，表示分析的置信度。
        """
        
        let geminiRequest = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: prompt, inlineData: nil)
                    ],
                    role: "user"
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.1,
                topK: 1,
                topP: 0.8,
                maxOutputTokens: 1024
            )
        )
        
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(geminiRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GeminiResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let candidate = response.candidates.first,
                      let text = candidate.content.parts.first?.text else {
                    throw GeminiError.noResponse
                }
                
                return try self.parseAIAnalysis(from: text)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Financial Analysis
    
    func analyzeFinancialData(_ expenses: [ExpenseData]) -> AnyPublisher<String, Error> {
        let url = URL(string: "\(baseURL)/models/\(model):generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 准备支出数据摘要
        let expenseSummary = expenses.map { expense in
            "金额: \(expense.amount), 分类: \(expense.category.displayName), 描述: \(expense.description), 日期: \(DateFormatter.shortDate.string(from: expense.date))"
        }.joined(separator: "\n")
        
        let prompt = """
        请分析以下财务数据，并提供详细的财务分析报告：
        
        支出记录：
        \(expenseSummary)
        
        请提供以下内容的分析：
        1. 支出总览和趋势
        2. 各类别支出分析
        3. 异常支出识别
        4. 节省建议
        5. 预算建议
        
        请用中文回答，语言要专业但易懂。
        """
        
        let geminiRequest = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: prompt, inlineData: nil)
                    ],
                    role: "user"
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.3,
                topK: 10,
                topP: 0.9,
                maxOutputTokens: 2048
            )
        )
        
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(geminiRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GeminiResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let candidate = response.candidates.first,
                      let text = candidate.content.parts.first?.text else {
                    throw GeminiError.noResponse
                }
                
                return text
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    private func parseAIAnalysis(from text: String) throws -> AIAnalysis {
        // 尝试从文本中提取JSON
        guard let jsonStart = text.range(of: "{"),
              let jsonEnd = text.range(of: "}", options: .backwards) else {
            throw GeminiError.invalidResponse
        }
        
        let jsonString = String(text[jsonStart.lowerBound...jsonEnd.upperBound])
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(AIAnalysis.self, from: jsonData)
        } catch {
            // 如果JSON解析失败，创建一个默认的分析结果
            return AIAnalysis(
                confidence: 0.5,
                suggestedCategory: .other,
                extractedAmount: nil,
                extractedDescription: text,
                reasoning: "AI分析结果解析失败，使用默认分类",
                alternatives: nil
            )
        }
    }
}

// MARK: - Error Types

enum GeminiError: Error, LocalizedError {
    case invalidAPIKey
    case noResponse
    case invalidResponse
    case networkError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "无效的API密钥"
        case .noResponse:
            return "AI服务无响应"
        case .invalidResponse:
            return "AI响应格式错误"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .unknown:
            return "未知错误"
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
}