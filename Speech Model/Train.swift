//
//  Train.swift
//  Train
//
//  Created by Kenny Zhou on 2021/8/10.
//

import Foundation
#if os(iOS)
import CreateML
#endif
import CoreML

@available(iOS 15.0, *)
class TrainModle {
    
    var UserData: UserInfo?
    
//    var MLSoundClassifierModle: MLJob<MLSoundClassifier>?
//    var mlProgress: MLProgress?
    var MLSoundClassifierModle: MLSoundClassifier?
    
    let reportInterval = 1
    let checkpointInterval = 1
    let iterations = 50
    let maxIterations = 500
    let overlapFactor = 0.75
    
    init(){
        
    }
    
    func train(path:URL) {
            self.MLSoundClassifierModle = try! MLSoundClassifier(trainingData: .labeledDirectories(at: path), parameters: MLSoundClassifier.ModelParameters(validation: MLSoundClassifier.ModelParameters.ValidationData.split(strategy: .automatic), maxIterations: maxIterations, overlapFactor: overlapFactor, algorithm: MLSoundClassifier.ModelParameters.ModelAlgorithmType.transferLearning(featureExtractor: MLSoundClassifier.ModelParameters.FeatureExtractorType.vggish(revision: 1), classifier: MLSoundClassifier.ModelParameters.ClassifierType.logisticRegressor)))
        self.MLSoundClassifierModle

//        return self.mlProgress!

    }
    
}



