//
//  TrainView.swift
//  TrainView
//
//  Created by Kenny Zhou on 2021/8/12.
//

import SwiftUI

@available(iOS 15.0, *)
struct TrainView: View {
    @State var userData: UserInfo
    
    @State var trainProgress: TrainModle
    @State var speechRecognizer: SpeechRecognizerLive
    @State var progressValue:Float = 0
    @State var progressTotal:Float = 100
    
    @State var checkTimer = false
    
    let timer = Timer.publish(every: 0.5, tolerance: 0.1, on: .main, in: .common).autoconnect()
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {

        NavigationView {
            VStack {
                ProgressView("Training", value:self.progressValue,total:self.progressTotal)
                    .progressViewStyle(CirclerPercentProgressViewStyle())
                    .frame(width: 120, height: 120,alignment: .center)
                .padding()
                
            }
            .onReceive(timer) { time in
                
                
                if self.progressValue > 85 && self.progressValue != 100 {
                    self.checkTimer = true
                    self.progressValue = 100
                } else {self.progressValue += 15}
                if self.checkTimer {
                    do{
                    try self.trainProgress.MLSoundClassifierModle!.write(to: self.userData.appModelURL!)
                        self.speechRecognizer.initUserSoundModel()
                        self.userData.hadBeTrain = true
                    } catch {print("ERROR",error)}
                    
                    print(self.trainProgress.MLSoundClassifierModle!.validationMetrics.description)
                    timer.upstream.connect().cancel()

                    self.presentation.wrappedValue.dismiss()
                }
                self.checkTimer = false
                
            }
            
            
        }.onAppear{
            // MARK: 开始训练
            self.trainProgress.train(path: self.userData.appVoiceDataURL!)
            self.progressValue = 15
            
        }
//                .onReceive(trainProgress.train(path: UserData.appVoiceDataURL!, sessionDirectory: UserData.appTrainSessionURL!).checkpoints .receive(on: RunLoop.main), perform: { value in
//                self.progressValue = Float(value.iteration)
//                print(value.iteration)
//                print(value.metrics)
//            })
        }
 
    }


//struct TrainView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrainView()
//    }
//}
