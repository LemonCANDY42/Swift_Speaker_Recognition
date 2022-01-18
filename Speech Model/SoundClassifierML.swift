//
//  CoreMl.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/8/6.
//
import SoundAnalysis
import AVFoundation
import Foundation
import Speech
import CoreML

var customRequest:SNClassifySoundRequest!

func makeRequest(_ customModel: MLModel)  -> SNClassifySoundRequest {
    // If applicable, create a request with a custom sound classification model.

    do {
        customRequest = try SNClassifySoundRequest(mlModel: customModel)
        return customRequest!
    } catch {
    
        return customRequest!
    }
}


class SoundModel: ObservableObject {
        
    var model: MLModel?
    let soundClassifier = SoundMulticategorization()
    var streamAnalyzer: SNAudioStreamAnalyzer!

    let classifySoundRequest: SNClassifySoundRequest!
    @Published var resultsObserver = ResultsObserver()
    
    init() {
        model = soundClassifier.model
        print("model: \(model)")
        classifySoundRequest = makeRequest(model!)
        print(model!.modelDescription)
//        print(model!.modelDescription.isUpdatable)
        
    }
    
    init(from modelUrl: URL) {
        do {
            let compiledUrl = try MLModel.compileModel(at: modelUrl)
            model = try MLModel(contentsOf: compiledUrl)
        } catch {print(modelUrl,error)}
        print("model: \(model)")
        print(model!.modelDescription)
        classifySoundRequest = makeRequest(model!)
        resultsObserver.setMod()
    }
    
    func startAudioAnalysis(inputFormat: AVAudioFormat) {
        
        // Create a new stream analyzer.
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        print("Add a sound classification request that reports to an observer.")
        // Add a sound classification request that reports to an observer.
        do {
        try streamAnalyzer!.add(classifySoundRequest!,
                               withObserver: resultsObserver)
        }   catch {
            print("streamAnalyzer is \(error)")
        }
            
    }
    
}
