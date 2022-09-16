//
//  MotorControlAssessmentViewModel.swift
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

import SwiftUI
import AssessmentModelUI
import AssessmentModel
import SharedResources
import MobilePassiveData
import MotionSensor

let formattedTextPlaceHolder = "%@"

public final class MotorControlAssessmentViewModel : AssessmentViewModel {
    override public func nodeState(for node: Node) -> NodeState? {
        let whichHand = currentBranchState.node.hand()
        if let instruction = node as? AbstractInstructionStepObject {
            return MotorControlInstructionState(instruction,
                                                parentId: currentBranchState.id,
                                                whichHand: whichHand)
        }
        else if let step = node as? MotionSensorNodeObject {
            return MotionSensorStepState(step, assessmentState: state, branchState: currentBranchState)
        }
        else {
            return super.nodeState(for: node)
        }
    }
}

/// State object for an abstract motion control step
public class AbstractMotionControlState : ContentNodeState {
    
    override public var progressHidden: Bool { true }

    public let flippedImage: Bool
    public let title: String?
    public let subtitle: String?
    public let detail: String?
    
    public init(_ instruction: AbstractStepObject, parentId: String?, whichHand: HandSelection? = nil) {
        if let whichHand = whichHand {
            self.flippedImage = (whichHand == .right)
            let replacementString = whichHand.handReplacementString().uppercased()
            self.title = instruction.title?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
            self.subtitle = instruction.subtitle?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
            self.detail = instruction.detail?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
        }
        else {
            self.flippedImage = false
            self.title = instruction.title
            self.subtitle = instruction.subtitle
            self.detail = instruction.detail
        }
        super.init(step: instruction, result: instruction.instantiateResult(), parentId: parentId)
    }
}

/// State object for an instruction.
public final class MotorControlInstructionState : AbstractMotionControlState {
}

/// State object for motion sensor steps
public final class MotionSensorStepState : AbstractMotionControlState {
    public var motionConfig: MotionSensorNodeObject { node as! MotionSensorNodeObject }
    public let voicePrompter: TextToSpeechSynthesizer = .init()
    public let spokenInstructions: [Int : String]
    
    @Published public var recorder: MotionRecorder
    
    public init(_ motionConfig: MotionSensorNodeObject, assessmentState: AssessmentState, branchState: BranchState) {
        if assessmentState.outputDirectory == nil {
            assessmentState.outputDirectory = createOutputDirectory()
        }
        self.recorder = .init(configuration: motionConfig,
                              outputDirectory: assessmentState.outputDirectory!,
                              initialStepPath: "\(assessmentState.node.identifier)/\(branchState.node.identifier)",
                              sectionIdentifier: branchState.node.identifier)
        let whichHand = branchState.node.hand()
        let replacementString = whichHand?.handReplacementString() ?? "NULL"
        self.spokenInstructions = motionConfig.spokenInstructions?.mapValues { text in
            text.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
        } ?? [:]
        super.init(motionConfig, parentId: branchState.id, whichHand: whichHand)
    }
    
    ///TODO: Move speaking functionality to this view model
}

fileprivate func createOutputDirectory() -> URL {
    URL(fileURLWithPath: UUID().uuidString, isDirectory: true, relativeTo: FileManager.default.temporaryDirectory)
}
