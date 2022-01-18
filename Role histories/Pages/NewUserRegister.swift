//
//  NewUserRegister.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI
import AVFoundation
import Lottie

struct NewUserRegister: View {
    // 倒计时
    let timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common).autoconnect()

    
    // @State private var counter = 0
    let pinText = "请念出以下文本，并在结束后按确认按钮"
    
    @ObservedObject var audioRecorder = AudioRecorder()
    
    @State var speckText: String = "\"你好世界\""
    @State var UserData:UserInfo?
    var sendTitle: String
    @State var speckEnd = false
    @State var recordEnd = false
    @State var userName:String?
    
    @State var timeCount = 0
    
    @Binding var isShow:Bool
    
    var body: some View {
        NavigationView {

            VStack {
                //向LottieView函数传入"love.json"动画
//                LottieView(name: "voice")
//                    .frame(width:100, height:100)
                Spacer()
                LottieUIView(filename: "voice",times: 5)
                    .frame(width:100, height:100)
                Text(speckText)
                Spacer()
                Button(action: {
                    audioRecorder.stopRecording()
                    print("结束录音")
                    self.isShow = false
                    
                }) {
                    Group {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                            .resizable()
                            .aspectRatio(1.1, contentMode: .fit)
//                            .foregroundColor(.blue)
                    }
                        .frame(width: 66)
                        
                }.disabled(!self.recordEnd)
                Spacer()
            }
            .navigationTitle(sendTitle)
    
        }.onDisappear{
//            audioRecorder.stopRecording()
//            print("结束录音")
            self.isShow = false
        }
        .onAppear {
            let synthesizer = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: pinText)
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
            utterance.rate = 0.5
            synthesizer.speak(utterance)}
        
        .onReceive(timer) { time in
            self.timeCount += 1

            
            if self.timeCount==5{
                self.speckEnd = true
            }
            if self.timeCount==7{
                self.recordEnd = true
            timer.upstream.connect().cancel()
            }
            
//            specker(string: pinText)

            }
        .onChange(of: self.speckEnd, perform: {value in
            print(self.speckEnd,"self.speckEnd is changed")
            if self.speckEnd{
                let path = (self.UserData?.appVoiceDataURL)!.appendingPathComponent(self.userName!)
                audioRecorder.pathSet(path: path)
                audioRecorder.startRecording()
                print("开始录音")
            }
        })
    }
}


func specker(string: String) {
    
    let utterance = AVSpeechUtterance(string: string)
    utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
    utterance.rate = 0.5
    
    let synthesizer = AVSpeechSynthesizer()
    synthesizer.speak(utterance)
    
    
}


//struct NewUserRegister_Previews: PreviewProvider {
//    static var previews: some View {
//        NewUserRegister(sendTitle:"你好")
//    }
//}
