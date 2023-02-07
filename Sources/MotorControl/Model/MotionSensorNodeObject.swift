//
//  MotionSensorNodeObject.swift
//

import Foundation
import JsonModel
import ResultModel
import AssessmentModel
import MotionSensor
import MobilePassiveData

extension SerializableNodeType {
    static let tapping: SerializableNodeType = "tapping"
    static let motion: SerializableNodeType = "motion"
    static let backgroundCountdown: SerializableNodeType = "backgroundCountdown"
}

class BackgroundCountdownStepObject : AbstractCountdownStepObject, Encodable {
    public override class func defaultType() -> SerializableNodeType {
        .backgroundCountdown
    }
}
 
class TappingNodeObject : MotionSensorNodeObject {
    override class func defaultType() -> SerializableNodeType {
        .tapping
    }
    
    override func instantiateResult() -> ResultData {
        TappingResultObject(identifier: self.identifier)
    }
}

class MotionSensorNodeObject : AbstractStepObject {
    private enum CodingKeys : String, CodingKey {
        case duration, spokenInstructions, requiresBackgroundAudio
    }
    
    override class func defaultType() -> SerializableNodeType {
        .motion
    }
    
    let duration: TimeInterval
    let spokenInstructions: [Int : String]?
    let requiresBackgroundAudio: Bool
    
    enum SpokenInstructionKeys : String, CodingKey {
        case start, halfway, countdown, end
    }
    
    override func spokenInstruction(at timeInterval: TimeInterval) -> String? {
        var key = Int(timeInterval)
        if timeInterval >= duration && duration > 0 {
            key = Int(duration)
        }
        return self.spokenInstructions?[key]
    }
    
    init() {
        self.duration = 30
        self.spokenInstructions = nil
        self.requiresBackgroundAudio = false
        super.init(identifier: "example")
    }
    
    init(identifier: String, title: String? = nil, subtitle: String? = nil, detail: String? = nil, imageInfo: ImageInfo? = nil, requiresBackgroundAudio: Bool = false) {
        self.duration = 30
        self.spokenInstructions = nil
        self.requiresBackgroundAudio = requiresBackgroundAudio
        super.init(identifier: identifier, title: title, subtitle: subtitle, detail: detail, imageInfo: imageInfo)
    }
    
    init(identifier: String, copyFrom object: MotionSensorNodeObject) {
        self.duration = object.duration
        self.spokenInstructions = object.spokenInstructions
        self.requiresBackgroundAudio = object.requiresBackgroundAudio
        super.init(identifier: identifier, copyFrom: object)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.requiresBackgroundAudio = try container.decodeIfPresent(Bool.self, forKey: .requiresBackgroundAudio) ?? false
        let stepDuration = try container.decode(TimeInterval.self, forKey: .duration)
        self.duration = stepDuration
        if let dictionary = try container.decodeIfPresent([String : String].self, forKey: .spokenInstructions) {
            
            // Map the json deserialized dictionary into the `spokenInstructions` dictionary.
            var countdownStart: Int?
            var instructions = dictionary.mapKeys({ (key) -> Int in
                if let specialKey = SpokenInstructionKeys(stringValue: key) {
                    switch(specialKey) {
                    case .start:
                        return 0
                    case .halfway:
                        return Int(stepDuration / 2)
                    case .end:
                        return Int(stepDuration)
                    case .countdown:
                        guard let countdown = (dictionary[key] as NSString?)?.integerValue, countdown > 0
                            else {
                                return -1
                        }
                        countdownStart = countdown
                        return Int(stepDuration) - countdown
                    }
                }
                return (key as NSString).integerValue
            })
            
            // special-case handling of the countdown
            if let countdown = countdownStart {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .spellOut
                for ii in 1...countdown {
                    let timeInterval = Int(stepDuration) - ii
                    instructions[timeInterval] = numberFormatter.string(from: NSNumber(value: ii))
                }
            }
                        
            self.spokenInstructions = instructions
        }
        else {
            self.spokenInstructions = nil
        }
        try super.init(from: decoder)
    }
}

extension Dictionary {
    
    /// Returns a `Dictionary` containing the results of transforming the keys
    /// over `self` where the returned values are the mapped keys.
    /// - parameter transform: The function used to transform the input keys into the output key
    /// - returns: A dictionary of key/value pairs.
    func mapKeys<T: Hashable>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            let transformedKey = try transform(key)
            result[transformedKey] = value
        }
        return result
    }
}

extension MotionSensorNodeObject : MotionRecorderConfiguration {
    var recorderTypes: Set<MotionRecorderType>? {
        [.accelerometer, .gyro, .gravity, .userAcceleration, .attitude, .rotationRate]
    }
    
    var frequency: Double? {
        100
    }
    
    var usesCSVEncoding: Bool? {
        false
    }
    
    var shouldDeletePrevious: Bool {
        true
    }
    
    var stopStepIdentifier: String? {
        nil
    }
    
    var startStepIdentifier: String? {
        nil
    }
    
    func validate() throws {
        // do nothing
    }
}
