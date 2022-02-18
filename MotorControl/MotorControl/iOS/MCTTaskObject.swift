//
//  MCTTaskObject.swift
//  MotorControl
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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
import Research
import MobilePassiveData

#if canImport(ResearchUI)
import ResearchUI
#endif

extension RSDTaskType {
    static let motorControlTask: RSDTaskType = "motorControlTask"
}

/// For the MotorControl tasks, the motion sensors are always required. Because of this, inherit from
/// `RSDMotionTaskObject` to use the custom audio session controller on that task.
public final class MCTTaskObject : AbstractTaskObject, RSDActiveTask {
    public override class func defaultType() -> RSDTaskType {
        .motorControlTask
    }
    
    public var jsonSchema: URL {
        URL(string: "\(MCTFactory.shared.modelName(for: self.className)).json", relativeTo: kSageJsonSchemaBaseURL)!
    }
    
    public var documentDescription: String? {
        "The configurable information for running a MotorControl assessment."
    }
    
    // MARK: Transformable initializer
    
    private enum CodingKeys : String, OrderedEnumCodingKey {
        case serializableType="type", identifier, schemaIdentifier, versionString, title, subtitle
    }
    
    private enum PrivateCodingKeys : String, CodingKey {
        case steps
    }
    
    public required init() {
        super.init(identifier: MCTTaskIdentifier.tapping.stringValue, steps: [])
    }

    public required init(from decoder: Decoder) throws {
        let privateContainer = try decoder.container(keyedBy: PrivateCodingKeys.self)
        if privateContainer.contains(.steps) {
            try super.init(from: decoder)
            let container = try decoder.container(keyedBy: ActiveTaskCodingKeys.self)
            self.shouldEndOnInterrupt = try container.decodeIfPresent(Bool.self, forKey: .shouldEndOnInterrupt) ?? true
            self.audioSessionSettings = try container.decodeIfPresent(AudioSessionSettings.self, forKey: .audioSessionSettings)
        }
        else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let identifier = try container.decode(String.self, forKey: .identifier)
            guard let taskIdentifier = MCTTaskIdentifier(rawValue: identifier)
            else {
                throw DecodingError.valueNotFound(MCTTaskIdentifier.self,
                                                    .init(codingPath: decoder.codingPath, debugDescription:
                                                            "The provided identifier '\(identifier)' does not match any supported by this framework."))
            }
            let factory = MCTFactory()
            let transformer = taskIdentifier.resourceTransformer()
            let (data, _) = try transformer.resourceData(ofType: .json)
            let decoder = factory.createJSONDecoder(resourceInfo: transformer)
            let copyTask = try decoder.decode(AssessmentTaskObject.self, from: data)
            
            let schemaIdentifier = try container.decodeIfPresent(String.self, forKey: .schemaIdentifier)
            let versionString = try container.decodeIfPresent(String.self, forKey: .versionString)
            
            super.init(identifier: identifier,
                       steps: copyTask.steps,
                       usesTrackedData: true,
                       asyncActions: copyTask.asyncActions,
                       progressMarkers: copyTask.progressMarkers,
                       resultIdentifier: schemaIdentifier ?? copyTask.schemaIdentifier,
                       versionString: versionString ?? copyTask.versionString,
                       estimatedMinutes: copyTask.estimatedMinutes,
                       actions: copyTask.actions,
                       shouldHideActions: copyTask.shouldHideActions)
            
            self.shouldEndOnInterrupt = copyTask.shouldEndOnInterrupt
            self.audioSessionSettings = copyTask.audioSessionSettings
            
            if let overviewStep = self.steps.first as? RSDUIStepObject {
                overviewStep.title = try container.decodeIfPresent(String.self, forKey: .title) ?? overviewStep.title
                overviewStep.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? overviewStep.subtitle
            }
        }
    }
    
    fileprivate init(identifier: String, copyTask: MCTTaskObject) {
        super.init(identifier: identifier,
                   steps: copyTask.steps.deepCopy(),
                   usesTrackedData: true,
                   asyncActions: copyTask.asyncActions,
                   progressMarkers: copyTask.progressMarkers,
                   resultIdentifier: copyTask.schemaIdentifier,
                   versionString: copyTask.versionString,
                   estimatedMinutes: copyTask.estimatedMinutes,
                   actions: copyTask.actions,
                   shouldHideActions: copyTask.shouldHideActions)
        self.shouldEndOnInterrupt = copyTask.shouldEndOnInterrupt
        self.audioSessionSettings = copyTask.audioSessionSettings
    }
    
    public override func copy(with identifier: String) -> Self {
        type(of: self).init(identifier: identifier, copyTask: self)
    }
    
    // MARK: Documentation
    
    public override class func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public override class func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .identifier || key == .serializableType
    }
    
    public override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not handled by \(self).")
        }
        switch key {
        case .serializableType:
            return .init(constValue: RSDTaskType.motorControlTask)
        case .identifier:
            return .init(propertyType: .reference(MCTTaskIdentifier.documentableType()), propertyDescription:
                            "The identifier is used to determine which assessment to run.")
        case .schemaIdentifier:
            return .init(propertyType: .primitive(.string), propertyDescription:
                            "An identifier that can be used to archive the result.")
        case .versionString:
            return .init(propertyType: .primitive(.string), propertyDescription:
                            "Optional version of the assessment (if versioning is supported).")
        case .title:
            return .init(propertyType: .primitive(.string), propertyDescription:
                            "Title to show to the participant when displaying the assessment overview.")
        case .subtitle:
            return .init(propertyType: .primitive(.string), propertyDescription:
                            "Subtitle to show to the participant when displaying the assessment overview.")
        }
    }
    
    public override class func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[
            "identifier" : "tapping",
            "type" : "motorControlTask"
        ]]
    }
    
    // MARK: RSDActiveTask
    
    private enum ActiveTaskCodingKeys : String, CodingKey {
        case shouldEndOnInterrupt, audioSessionSettings
    }
    
    public private(set) var shouldEndOnInterrupt: Bool = false
    public private(set) var audioSessionSettings: AudioSessionSettings?
    
    // MARK: Scoring and data tracking

    internal var runCount: Int = 1
    
    /// Override the task setup to allow setting the run count.
    override public func setupTask(with data: RSDTaskData?, for path: RSDTaskPathComponent) {
        guard let dictionary = data?.json as? [String : JsonSerializable] else { return }
        self.runCount = ((dictionary[RSDIdentifier.taskRunCount.stringValue] as? Int) ?? 0) + 1
    }

    /// Override the taskData builder to add the run count.
    override public func taskData(for taskResult: RSDTaskResult) -> RSDTaskData? {
        let builder = RSDDefaultScoreBuilder()
        var json: [String : JsonSerializable] =
            (builder.getScoringData(from: taskResult) as? [String : JsonSerializable])
                ?? [:]
        json[RSDIdentifier.taskRunCount.stringValue] = runCount
        return TaskData(identifier: self.identifier, timestampDate: taskResult.endDate, json: json)
    }
    
    struct TaskData : RSDTaskData {
        let identifier: String
        let timestampDate: Date?
        let json: JsonSerializable
    }
}

#if canImport(ResearchUI)
extension MCTTaskObject : RSDTaskDesign {
    
    public var designSystem: RSDDesignSystem {
        return MCTFactory.designSystem
    }
}
#endif

extension MCTTaskObject : SerializableTask {
}

extension MCTTaskObject : DocumentableRootObject {
}
