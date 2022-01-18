//
//  AudioRecorderView.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI

struct AudioRecorderView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var audioRecorder: AudioRecorder
       
       var body: some View {
        NavigationView {
        VStack {
            
            RecordingsList(audioRecorder: self.audioRecorder)
            if self.audioRecorder.recording == false {
                        Button(action: {self.audioRecorder.startRecording()}) {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .foregroundColor(.red)
                                .padding(.bottom, 40)
                        }
                    } else {
                        Button(action: {self.audioRecorder.stopRecording()}) {
                            Image(systemName: "stop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .foregroundColor(.red)
                                .padding(.bottom, 40)
                        }
                    }
                }.navigationBarTitle("Voice recorder")
        }
}
}

struct AudioRecorderView_Previews: PreviewProvider {
    
    static var previews: some View {
        AudioRecorderView(audioRecorder: AudioRecorder()).environmentObject(ViewRouter())
    }
}
