//
//  VoiceInputView.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import SwiftUI
import AVFoundation

struct VoiceInputView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var isRecording = false
    @State private var audioLevel: CGFloat = 0
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingPermissionAlert = false
    @State private var transcriptionText = ""
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CyberpunkBackgroundView()
                
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Recording Visualization
                    recordingVisualization
                    
                    // Recording Controls
                    recordingControls
                    
                    // Transcription Result
                    if !transcriptionText.isEmpty {
                        transcriptionSection
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("语音记账")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        stopRecording()
                        dismiss()
                    }
                    .foregroundColor(MatrixTheme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !transcriptionText.isEmpty {
                        Button("确认") {
                            processTranscription()
                        }
                        .foregroundColor(MatrixTheme.accentColor)
                        .disabled(isProcessing)
                    }
                }
            }
        }
        .alert("需要麦克风权限", isPresented: $showingPermissionAlert) {
            Button("设置") {
                openSettings()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("请在设置中允许应用访问麦克风以使用语音记账功能")
        }
        .onAppear {
            checkMicrophonePermission()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.fill")
                .font(.system(size: 48))
                .foregroundColor(isRecording ? MatrixTheme.errorColor : MatrixTheme.accentColor)
                .scaleEffect(isRecording ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isRecording)
            
            Text(isRecording ? "正在录音..." : "点击开始语音记账")
                .font(MatrixTheme.headlineFont)
                .foregroundColor(MatrixTheme.primaryTextColor)
            
            if isRecording {
                Text(formatTime(recordingTime))
                    .font(MatrixTheme.bodyFont)
                    .foregroundColor(MatrixTheme.secondaryTextColor)
                    .monospacedDigit()
            }
        }
    }
    
    private var recordingVisualization: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(MatrixTheme.borderColor, lineWidth: 2)
                .frame(width: 200, height: 200)
            
            // Audio level visualization
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .stroke(
                        MatrixTheme.primaryColor.opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(
                        width: 200 + CGFloat(index) * 20,
                        height: 200 + CGFloat(index) * 20
                    )
                    .scaleEffect(isRecording ? 1 + audioLevel * CGFloat(index + 1) * 0.1 : 1)
                    .opacity(isRecording ? 0.8 - Double(index) * 0.15 : 0)
                    .animation(
                        .easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true),
                        value: audioLevel
                    )
            }
            
            // Center microphone
            Circle()
                .fill(
                    isRecording ?
                    MatrixTheme.errorColor :
                    MatrixTheme.primaryColor
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(MatrixTheme.backgroundColor)
                )
                .scaleEffect(isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
        }
    }
    
    private var recordingControls: some View {
        HStack(spacing: 32) {
            // Record/Stop Button
            Button(action: toggleRecording) {
                Circle()
                    .fill(isRecording ? MatrixTheme.errorColor : MatrixTheme.primaryColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.title)
                            .foregroundColor(MatrixTheme.backgroundColor)
                    )
                    .scaleEffect(isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isRecording)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isProcessing)
        }
    }
    
    private var transcriptionSection: some View {
        MatrixCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("识别结果")
                        .font(MatrixTheme.headlineFont)
                        .foregroundColor(MatrixTheme.primaryTextColor)
                    
                    Spacer()
                    
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: MatrixTheme.primaryColor))
                            .scaleEffect(0.8)
                    }
                }
                
                Text(transcriptionText)
                    .font(MatrixTheme.bodyFont)
                    .foregroundColor(MatrixTheme.primaryTextColor)
                    .padding()
                    .background(MatrixTheme.surfaceColor)
                    .cornerRadius(MatrixTheme.smallCornerRadius)
                
                HStack {
                    MatrixButton(
                        title: "重新录音",
                        style: .secondary
                    ) {
                        transcriptionText = ""
                        recordingTime = 0
                    }
                    
                    MatrixButton(
                        title: "确认使用",
                        style: .primary
                    ) {
                        processTranscription()
                    }
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard !isRecording else { return }
        
        isRecording = true
        recordingTime = 0
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
            // Simulate audio level
            audioLevel = CGFloat.random(in: 0.1...1.0)
        }
        
        // TODO: Implement actual audio recording
        print("Started recording")
    }
    
    private func stopRecording() {
        guard isRecording else { return }
        
        isRecording = false
        timer?.invalidate()
        timer = nil
        audioLevel = 0
        
        // TODO: Implement actual audio recording stop
        print("Stopped recording")
        
        // Simulate transcription
        simulateTranscription()
    }
    
    private func simulateTranscription() {
        isProcessing = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            transcriptionText = "今天在星巴克买了一杯咖啡，花了35元"
            isProcessing = false
        }
    }
    
    private func processTranscription() {
        isProcessing = true
        
        // Process with Gemini API
        Task {
            do {
                let result = try await appViewModel.geminiService.analyzeText(transcriptionText)
                
                await MainActor.run {
                    // Handle the result
                    isProcessing = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    // Handle error
                }
            }
        }
    }
    
    private func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            break
        case .denied:
            showingPermissionAlert = true
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if !granted {
                        showingPermissionAlert = true
                    }
                }
            }
        @unknown default:
            showingPermissionAlert = true
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VoiceInputView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}