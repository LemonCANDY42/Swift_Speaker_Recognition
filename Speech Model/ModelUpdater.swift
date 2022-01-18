////
////  ModelUpdate.swift
////  Role histories
////
////  Created by Kenny Zhou on 2021/8/9.
////
//
//import SwiftUI
//import CoreML
//
//
///// Class that handles predictions and updating of SoundMulticategorization model.
//struct ModelUpdater {
//    // MARK: - Private Type Properties
//    /// The updated Drawing Classifier model.
//    private static var updatedClassifier: SoundMulticategorization?
//    /// The default Drawing Classifier model.
//    private static var defaultClassifier: SoundMulticategorization {
//        do {
//            return try SoundMulticategorization(configuration: .init())
//        } catch {
//            fatalError("Couldn't load SoundMulticategorization due to: \(error.localizedDescription)")
//        }
//    }
//
//    // The Drawing Classifier model currently in use.
//    private static var liveModel: SoundMulticategorization {
//        updatedClassifier ?? defaultClassifier
//    }
//    
//    /// The location of the app's Application Support directory for the user.
//    private static let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
//                                                               in: .userDomainMask).first!
//    
//    /// The default Drawing Classifier model's file URL.
//    private static let defaultModelURL = SoundMulticategorization.urlOfModelInThisBundle
//    /// The permanent location of the updated Drawing Classifier model.
//    private static var updatedModelURL = appDirectory.appendingPathComponent("personalized.mlmodelc")
//    /// The temporary location of the updated Drawing Classifier model.
//    private static var tempUpdatedModelURL = appDirectory.appendingPathComponent("personalized_tmp.mlmodelc")
//    
//    /// Triggers code on the first prediction, to (potentially) load a previously saved updated model just-in-time.
//    private static var hasMadeFirstPrediction = false
//    
//    /// The Model Updater type doesn't use instances of itself.
//    private init() { }
//
////    // MARK: - Public Properties
////    static var arrayConstraint: MLMultiArrayConstraint {
////        liveModel.audioSamples
////    }
//    
//    // MARK: - Public Type Methods
//    static func predictLabelFor(_ value: MLFeatureValue)  { //-> String?
//        if !hasMadeFirstPrediction {
//            hasMadeFirstPrediction = true
//            
//            // Load the updated model the app saved on an earlier run, if available.
//            loadUpdatedModel()
//        }
//        
////        return liveModel.predictLabelFor(value)
//    }
//    
//    /// Updates the model to recognize images simlar to the given drawings contained within the `inputBatchProvider`.
//    /// - Parameters:
//    ///     - trainingData: A collection of sample images, each paired with the same label.
//    ///     - completionHandler: The completion handler provided from a view controller.
//    /// - Tag: CreateUpdateTask
//    static func updateWith(trainingData: MLBatchProvider,
//                           completionHandler: @escaping () -> Void) {
//        
//        /// The URL of the currently active Drawing Classifier.
//        let usingUpdatedModel = updatedClassifier != nil
//        let currentModelURL = usingUpdatedModel ? updatedModelURL : defaultModelURL
//        
//        /// The closure an MLUpdateTask calls when it finishes updating the model.
//        func updateModelCompletionHandler(updateContext: MLUpdateContext) {
//            // Save the updated model to the file system.
//            saveUpdatedModel(updateContext)
//            
//            // Begin using the saved updated model.
//            loadUpdatedModel()
//            
//            // Inform the calling View Controller when the update is complete
//            DispatchQueue.main.async { completionHandler() }
//        }
//        
//        SoundMulticategorization.updateModel(at: currentModelURL,
//                                               with: trainingData,
//                                               completionHandler: updateModelCompletionHandler)
//    }
//    
//    /// Deletes the updated model and reverts back to original Drawing Classifier.
//    static func resetDrawingClassifier() {
//        // Clear the updated Drawing Classifier.
//        updatedClassifier = nil
//        
//        // Remove the updated model from its designated path.
//        if FileManager.default.fileExists(atPath: updatedModelURL.path) {
//            try? FileManager.default.removeItem(at: updatedModelURL)
//        }
//    }
//    
//    // MARK: - Private Type Helper Methods
//    /// Saves the model in the given Update Context provided by an MLUpdateTask.
//    /// - Parameter updateContext: The context from the Update Task that contains the updated model.
//    /// - Tag: SaveUpdatedModel
//    private static func saveUpdatedModel(_ updateContext: MLUpdateContext) {
//        let updatedModel = updateContext.model
//        let fileManager = FileManager.default
//        do {
//            // Create a directory for the updated model.
//            try fileManager.createDirectory(at: tempUpdatedModelURL,
//                                            withIntermediateDirectories: true,
//                                            attributes: nil)
//            
//            // Save the updated model to temporary filename.
//            try updatedModel.write(to: tempUpdatedModelURL)
//            
//            // Replace any previously updated model with this one.
//            _ = try fileManager.replaceItemAt(updatedModelURL,
//                                              withItemAt: tempUpdatedModelURL)
//            
//            print("Updated model saved to:\n\t\(updatedModelURL)")
//        } catch let error {
//            print("Could not save updated model to the file system: \(error)")
//            return
//        }
//    }
//    
//    /// Loads the updated Drawing Classifier, if available.
//    /// - Tag: LoadUpdatedModel
//    private static func loadUpdatedModel() {
//        guard FileManager.default.fileExists(atPath: updatedModelURL.path) else {
//            // The updated model is not present at its designated path.
//            return
//        }
//        
//        // Create an instance of the updated model.
//        guard let model = try? SoundMulticategorization(contentsOf: updatedModelURL) else {
//            return
//        }
//        
//        // Use this updated model to make predictions in the future.
//        updatedClassifier = model
//    }
//}
//
//
//struct UserDrawing {
//    var path: URL?
//    
//    /// The underlying image of the drawing.
//    let image: CGImage
//    
//    /// Rectangle containing this drawing in the canvas view
//    let rect: CGRect
//    
//    /// Wraps the underlying image in a feature value.
//    /// - Tag: ImageFeatureValue
//    
////    var featureValue: MLFeatureValue {
////
////        // Get a white tinted version to use for the model
////        let preparedImage = whiteTintedImage
////
////        let imageFeatureValue = try? MLFeatureValue(multiArray: preparedImage)
////        return imageFeatureValue!
////    }
////
////    private var audioData: MLMultiArray {
////        return
////    }
//
///// - Tag: LabeledDrawingCollection
//    
//struct ExampleDrawingSet {
//    
//    /// The desired number of drawings to update the model
//    private let requiredDrawingCount = 3
//    
//    let userName:String!
//    
//    /// Collection of the training drawings
//    private var trainingAudioFiles = [UserDrawing]()
//
//    /// The emoji or sticker that the model should predict when passed similar images
//    let emoji: Character
//    
//    /// A Boolean that indicates whether the instance has all the required drawings.
//    var isReadyForTraining: Bool { trainingAudioFiles.count == requiredDrawingCount }
//    
//    init(for emoji: Character) {
//        self.emoji = emoji
//    }
//    
//   /// Creates a batch provider of training data given the contents of `trainingDrawings`.
//   /// - Tag: DrawingBatchProvider
//
//    var featureBatchProvider: MLBatchProvider {
//        var featureProviders = [MLFeatureProvider]()
//
//        let inputName = "audio"
//        let outputName = "label"
//                
//        for audioFile in trainingAudioFiles {
//            let inputValue = audioFile.featureValue
//            let outputValue = MLFeatureValue(string: userName)
//            
//            let dataPointFeatures: [String: MLFeatureValue] = [inputName: inputValue,
//                                                               outputName: outputValue]
//            
//            if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
//                featureProviders.append(provider)
//            }
//        }
//        
//       return MLArrayBatchProvider(array: featureProviders)
//    }
//
//           
//    /// Adds a drawing to the private array, but only if the type requires more.
//    mutating func addDrawing(_ drawing: UserDrawing) {
//        if trainingAudioFiles.count < requiredDrawingCount {
//            trainingAudioFiles.append(drawing)
//        }
//    }
//}
//}
