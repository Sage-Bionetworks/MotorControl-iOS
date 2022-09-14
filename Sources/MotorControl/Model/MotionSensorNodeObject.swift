//
//  MotionSensorNodeObject.swift
//
//  Copyright © 2022 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import JsonModel
import AssessmentModel
import MotionSensor
import MobilePassiveData

extension SerializableNodeType {
    static let tapping: SerializableNodeType = "tapping"
    static let tremor: SerializableNodeType = "tremor"
}
 
public class TappingNodeObject : MotionSensorNodeObject {
    public override class func defaultType() -> SerializableNodeType {
        .tapping
    }
}

public class TremorNodeObject : MotionSensorNodeObject {
    public override class func defaultType() -> SerializableNodeType {
        .tremor
    }
}

public class MotionSensorNodeObject : AbstractStepObject {
    private enum CodingKeys : String, CodingKey {
        case duration, spokenInstructions
    }
    
    public let duration: TimeInterval
    public let spokenInstructions: [TimeInterval : String]?
    
    enum SpokenInstructionKeys : String, CodingKey {
        case start, halfway, countdown, end
    }
    
    public override func spokenInstruction(at timeInterval: TimeInterval) -> String? {
        var key = timeInterval
        if timeInterval >= duration && duration > 0 {
            key = Double.infinity
        }
        return self.spokenInstructions?[key]
    }
    
    public init() {
        self.duration = 30
        self.spokenInstructions = nil
        super.init(identifier: "example")
    }
    
    public init(identifier: String, copyFrom object: MotionSensorNodeObject) {
        self.duration = object.duration
        self.spokenInstructions = object.spokenInstructions
        super.init(identifier: identifier, copyFrom: object)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stepDuration = try container.decode(TimeInterval.self, forKey: .duration)
        self.duration = stepDuration
        if let dictionary = try container.decodeIfPresent([String : String].self, forKey: .spokenInstructions) {
            
            // Map the json deserialized dictionary into the `spokenInstructions` dictionary.
            var countdownStart: Int?
            var instructions = dictionary.mapKeys({ (key) -> TimeInterval in
                if let specialKey = SpokenInstructionKeys(stringValue: key) {
                    switch(specialKey) {
                    case .start:
                        return 0
                    case .halfway:
                        return stepDuration / 2
                    case .end:
                        return Double.infinity
                    case .countdown:
                        guard let countdown = (dictionary[key] as NSString?)?.integerValue, countdown > 0
                            else {
                                return -1.0
                        }
                        countdownStart = countdown
                        return stepDuration - TimeInterval(countdown)
                    }
                }
                return (key as NSString).doubleValue as TimeInterval
            })
            
            // special-case handling of the countdown
            if let countdown = countdownStart {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .spellOut
                for ii in 1...countdown {
                    let timeInterval = stepDuration - TimeInterval(ii)
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
    public var recorderTypes: Set<MotionRecorderType>? {
        [.accelerometer, .gyro, .gravity, .userAcceleration, .attitude, .rotationRate]
    }
    
    public var frequency: Double? {
        100
    }
    
    public var usesCSVEncoding: Bool? {
        false
    }
    
    public var shouldDeletePrevious: Bool {
        true
    }
    
    public var stopStepIdentifier: String? {
        nil
    }
    
    public var requiresBackgroundAudio: Bool {
        true
    }
    
    public var startStepIdentifier: String? {
        nil
    }
    
    public func validate() throws {
        // do nothing
    }
}
