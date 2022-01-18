//
//  ResultsObserver.swift
//  ECS10-CoreML-Demo
//
//  Created by Nick Arner on 10/20/19.
//  Copyright © 2019 Nick Arner. All rights reserved.
//

import Foundation
import SoundAnalysis

// Observer object that is called as analysis results are found.
class ResultsObserver : NSObject, SNResultsObserving, ObservableObject {
    
    @Published var classificationResult = String()
    @Published var classificationConfidence = Double()
    @Published var lastClassArray = [Bool](repeating: false, count: 2)
    @Published var userClassificationArray = [String]()
    var userMod = false
    
    func setMod(){
        self.userMod = true
        print("self.userMod",self.userMod)
    }
    
    func resetuserClassArray(){
        self.userClassificationArray = [String]()
    }
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        
        
        // Get the top classification.  
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }
        
        // Determine the time of this result.
        let formattedTime = String(format: "%.2f", result.timeRange.start.seconds)
        print("Analysis result for audio at time: \(formattedTime)")
        
        let confidence = classification.confidence * 100.0
        let percent = String(format: "%.2f%%", confidence)

        // Print the result as Sound: percentage confidence.
        print("\(classification.identifier): \(percent) confidence.\n")
        
        classificationResult = classification.identifier
        classificationConfidence = confidence
        
        if self.userMod {
            // TODO: 对整个转录序列进行分析并返回全部的结果，来判断是谁说的话
            self.userClassificationArray.append(classificationResult)
            print(self.userClassificationArray)
        } else {
        
        if classificationResult == "background"{
            lastClassArray.append(true)
        } else {
            lastClassArray.append(false)
        }
        lastClassArray.remove(at: 0)
        }}
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
