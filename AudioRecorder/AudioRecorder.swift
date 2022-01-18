//
//  AudioRecorder.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation



class AudioRecorder: ObservableObject {
    
    var pathURL:URL!
    
    // MARK: 创建一个记录会话
    let recordingSession = AVAudioSession.sharedInstance()
    
    init() {
//        super.init()

//        self.fetchRecordings()
    }
    
    func pathSet(path:URL){
        self.pathURL = path
    }
    
    // MARK:  通知观察视图有关更改的信息
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    // MARK: 初始化一个AVAudioRecorder
    var audioRecorder: AVAudioRecorder!
    
    
    // MARK: 创建一个数组来保存录音
    var recordings = [Recording]()
    
    // MARK: 使用objectWillChange属性更新订阅视图
    var recording = false {
            didSet {
                objectWillChange.send(self)
            }
        }
    
    func startRecording() {
        

        // MARK: 保存录音的位置
        let documentPath = self.pathURL
        print(documentPath!)
        // MARK: 应以录制的日期和时间命名，并具有 .wav 格式
        let fileName = "\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).wav"
        
        let audioFilename = documentPath!.appendingPathComponent(fileName)
        print("录音保存在\(audioFilename)")
        
        
        // MARK: 定义一些设置
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM), // AAC:kAudioFormatMPEG4AAC
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // MARK: 为录音会话定义类型并激活它。如果失败，将输出相应的错误
        do {
                    try recordingSession.setCategory(.record, mode: .default)
                    try recordingSession.setActive(true)
                } catch {
                    print("Failed to set up recording session")
            }
        
        // MARK: 通知ContentView记录正在运行，以便它可以自我更新并显示停止按钮而不是开始按钮
        do {
                    audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                    audioRecorder.record()

                    recording = true
                } catch {
                    print("Could not start recording")
                }
        }
    
    func stopRecording() {
        audioRecorder.stop()
//        do {
//            try recordingSession.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
//        } catch{print(error)}
        recording = false
        
//        fetchRecordings()
    }
    
    
    // MARK: 访问存储的录音
    func fetchRecordings() {
        // MARK: 必须先清空我们的录音数组，以避免多次显示录音。然后我们访问音频文件所在的文档文件夹并循环浏览所有这些文件
        recordings.removeAll()
        let fileManager = FileManager.default
        let documentDirectory = self.pathURL
        print(documentDirectory!)
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory!, includingPropertiesForKeys: nil)
        
        // MARK: 在fetchRecordings的 for-in 循环中，我们现在可以将此函数用于相应的录音。然后我们为每个音频文件创建一个Recording实例并将其添加到我们的记录数组中。
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
            recordings.append(recording)
            
            recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
            
            objectWillChange.send(self)

    }
}
}


