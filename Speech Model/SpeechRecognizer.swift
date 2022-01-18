//
//  SpeechRecognizer.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/8/3.
//

import AVFoundation
import Foundation
import Speech
import SwiftUI
import Combine
import SoundAnalysis


class SpeechRecognizerLive: ObservableObject {   //NSObject,SFSpeechRecognizerDelegate

        
    @State var viewRouter: ViewRouter
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))//locale: Locale(identifier: "zh-CN")
    private var audioEngine = AVAudioEngine()
    var firstLaaunch = true
    var lastSpeek = ""
    var speek = ""
    
    @State var userData:UserInfo
    @State var chatHistory: UserChatHistory
    var audioFileUrl:URL?
    private var checkBool = false
    let analysisQueue = DispatchQueue(label: "com.example.AnalysisQueue")
    var soundModel: SoundModel?
    var userSoundModel: SoundModel?
    var timer : Timer?
    var buffArray: [AVAudioPCMBuffer] = []
    var timeStamp = 0
    var file: AVAudioFile?
    var sign = false
    var lastSpecker = String()
    var nowId = 0
    var isSpeckEnd = true
    
    private var detectionCancellable: AnyCancellable? = nil
    
    
    init(viewRouter: ViewRouter,userData:UserInfo,chatHistory:UserChatHistory){
        
        self.viewRouter = viewRouter
        self.soundModel = SoundModel()
        self.userData = userData
        self.chatHistory = chatHistory
            
    }
    
    func initUserSoundModel() {
        self.userSoundModel = SoundModel(from: self.userData.appModelURL!)
        print("self.userSoundModel",self.userSoundModel)
    }
        
    func initAudio(logName: String) throws {
        
        
        audioFileUrl = self.userData.createdMeetingLogURLFolder(logName: logName)
        // Cancel the previous task if it's running.
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
        
//        self.viewRouter.needReturn = 0
        
        // Configure the audio session for the app.
            if self.firstLaaunch{
                self.firstLaaunch = false
            }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .default, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        self.startRecording()
        
        let recordingFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        self.userSoundModel?.startAudioAnalysis(inputFormat: recordingFormat)
        self.soundModel?.startAudioAnalysis(inputFormat: recordingFormat)

        print("userSoundModel",self.userSoundModel)
        self.audioFileUrl = self.userData.appMeetingLogURL!.appendingPathComponent("\(logName).wav")
        
        file = try! AVAudioFile(forWriting: self.audioFileUrl!, settings: recordingFormat.settings)

        if self.timeStamp == 0 {
            self.timeStamp = getNowTimeStampMillisecond()
        }
        inputNode.installTap(onBus: 0, bufferSize: 16384, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                            
                try! self.file?.write(from: buffer)
            
               
                
                self.analysisQueue.async {
                    self.soundModel!.streamAnalyzer.analyze(buffer,
                                                  atAudioFramePosition: when.sampleTime)
                    // TODO: 加上是不是背景音的判断
                    if self.soundModel!.resultsObserver.classificationResult != "background" {
                self.userSoundModel!.streamAnalyzer.analyze(buffer,
                                              atAudioFramePosition: when.sampleTime)
                print("self.userSoundModel.analyze",self.userSoundModel!.resultsObserver.userClassificationArray)
                    }
                  }

            DispatchQueue.main.sync {
                let nowTimeStamp = getNowTimeStampMillisecond()
                
            if (nowTimeStamp - self.timeStamp)>650 {
                // MARK: 判断是否全是Ture
                self.sign = self.checkSign(classificationResult: self.soundModel!.resultsObserver.lastClassArray)
                print("self.sign:\(self.sign)")
                if self.sign {
                    if self.isSpeckEnd {
                        
                    self.pauseRecording()
                    self.userSoundModel!.resultsObserver.resetuserClassArray()
                    self.isSpeckEnd = false
                    self.sign = false
                    self.startRecording()
                    }
                
                    // 加入之前的缓存
                    for i in self.buffArray{
                        self.recognitionRequest?.append(i)
                    }
                    self.buffArray = []

                }
                self.timeStamp = nowTimeStamp
            }
            }

            self.recognitionRequest?.append(buffer)
            
            // 加入之前的缓存
            self.buffArray.append(buffer)
            if self.buffArray.count>6{
                self.buffArray.remove(at: 0)
            }
            
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func startRecording() {
        self.nowId = self.chatHistory.getLastId()
//        self.analysisQueue.async { [self] in

        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
//        }
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [self] result, error in
               
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                isFinal = result.isFinal
                self.speek = result.bestTranscription.formattedString
                print(self.speek)
                self.sendTranscript()
                
            }
            
            if error != nil || isFinal {

            }
        }
//        }
    }
    
    func sendTranscript(){
        self.viewRouter.transcript = self.speek
//                self.relay(speech, message: self.lastSpeek)
        self.viewRouter.needReturn.toggle()
        self.viewRouter.needReturnId = self.nowId
    }


    func pauseRecording() {
        guard let task = self.recognitionTask else {
            fatalError("Error")
        }
        task.cancel()
        task.finish()
//        self.viewRouter.needReturn = 0
        self.recognitionRequest?.endAudio()
    }
    
    func stopRecording() {
//        self.viewRouter.needReturn = 0
        audioEngine.inputNode.removeTap(onBus: 0)
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
            self.recognitionRequest = nil
            self.recognitionTask = nil
                
    }
            
    private func relay(_ binding: Binding<String>, message: String) {
        DispatchQueue.main.async {
            binding.wrappedValue = message
        }
    }
    
    private func checkSign(classificationResult: Array<Bool>) -> Bool {
//        DispatchQueue.main.async {
        for i in classificationResult {
            if !i {
                return false
            }
        }
        return true
    }
    
    func checkUser() -> String {
    //        DispatchQueue.main.async {
        
        var maxValue = 0
        var userName = String()
        let dictionary = self.userSoundModel!.resultsObserver.userClassificationArray.reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        
        print(self.userSoundModel!.resultsObserver.userClassificationArray)
        self.userSoundModel!.resultsObserver.resetuserClassArray()
        for obj in dictionary {
            if obj.value > maxValue {
                maxValue = obj.value
                userName = obj.key
            }
        }
//        self.analysisQueue.async {
        
//        }

        if userName != String() {
            self.lastSpecker = userName
        } else {
            if self.lastSpecker != String(){
                userName = "114154.$"
                
            } else { userName = "Unknow"}
            
        }
        print("说话人是：",userName)

        return userName
    }



}



