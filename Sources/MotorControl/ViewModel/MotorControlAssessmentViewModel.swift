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

let formattedTextPlaceHolder = "%@"

public final class MotorControlAssessmentViewModel : AssessmentViewModel {
    override public func nodeState(for node: Node) -> NodeState? {
        let whichHand = currentBranchState.node.hand()
        if let instruction = node as? InstructionStep {
            return MotorControlInstructionState(instruction,
                                                parentId: currentBranchState.id,
                                                whichHand: whichHand)
        }
        else if let handMotionSensorNode = node as? MotionSensorNodeObject {
            return MotorControlHandMotionSensorState(handMotionSensorNode,
                                           parentId: currentBranchState.id,
                                           whichHand: whichHand)
        }
        else {
            return super.nodeState(for: node)
        }
    }
}

/// State object for an instruction.
public final class MotorControlInstructionState : ContentNodeState {
    
    override public var progressHidden: Bool { true }

    public let flippedImage: Bool
    public let title: String?
    public let subtitle: String?
    public let detail: String?
    
    public init(_ instruction: InstructionStep, parentId: String?, whichHand: HandSelection? = nil) {
        if let whichHand = whichHand {
            self.flippedImage = (whichHand == .right)
            let replacementString = NSLocalizedString(whichHand.rawValue.uppercased(), bundle: SharedResources.bundle, comment: "Which hand to use")
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

/// State object for a Tremor node object
public final class MotorControlHandMotionSensorState : ContentNodeState {
    
    public let duration: TimeInterval
    public let spokenInstructions: [TimeInterval : String]?
    public let title: String?
    public let subtitle: String?
    public let detail: String?
    
    public init(_ motionSensorNode: MotionSensorNodeObject, parentId: String?, whichHand: HandSelection? = nil) {
        self.duration = motionSensorNode.duration
        self.spokenInstructions = motionSensorNode.spokenInstructions
        if let whichHand = whichHand {
            let replacementString = NSLocalizedString(whichHand.rawValue.uppercased(), bundle: SharedResources.bundle, comment: "Which hand to use")
            self.title = motionSensorNode.title?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
            self.subtitle = motionSensorNode.subtitle?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
            self.detail = motionSensorNode.detail?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
        }
        else {
            self.title = motionSensorNode.title
            self.subtitle = motionSensorNode.subtitle
            self.detail = motionSensorNode.detail
        }
        super.init(step: motionSensorNode, result: motionSensorNode.instantiateResult(), parentId: parentId)
    }
}
