//
//  MotorControlAssessmentStates.swift
//

import SwiftUI
import AssessmentModelUI
import AssessmentModel

let formattedTextPlaceHolder = "%@"

final class MotorControlAssessmentViewModel : AssessmentViewModel {
    override func nodeState(for node: Node) -> NodeState? {
        let whichHand = currentBranchState.node.hand()
        if let instruction = node as? AbstractInstructionStepObject {
            return MotorControlInstructionState(instruction,
                                                parentId: currentBranchState.id,
                                                whichHand: whichHand)
        }
        else if let step = node as? TappingNodeObject {
            return TappingStepViewModel(step,
                                        assessmentState: state,
                                        branchState: currentBranchState)
        }
        else if let step = node as? MotionSensorNodeObject {
            return TremorStepViewModel(step,
                                       assessmentState: state,
                                       branchState: currentBranchState)
        }
        else {
            return super.nodeState(for: node)
        }
    }
}

/// State object for an abstract motion control step
class AbstractMotionControlState : ContentNodeState {
    
    override var progressHidden: Bool { true }

    let flippedImage: Bool
    let title: String?
    let subtitle: String?
    let detail: String?
    let whichHand: HandSelection?
    
    init(_ motionControlStep: AbstractStepObject, parentId: String?, whichHand: HandSelection? = nil) {
        self.whichHand = whichHand
        if let whichHand = whichHand {
            self.flippedImage = (whichHand == .right)
            let replacementString = whichHand.handReplacementString().uppercased()
            self.title = motionControlStep.title?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
            self.subtitle = motionControlStep.subtitle?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
            self.detail = motionControlStep.detail?.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
        }
        else {
            self.flippedImage = false
            self.title = motionControlStep.title
            self.subtitle = motionControlStep.subtitle
            self.detail = motionControlStep.detail
        }
        super.init(step: motionControlStep, result: motionControlStep.instantiateResult(), parentId: parentId)
    }
}

/// State object for an instruction.
final class MotorControlInstructionState : AbstractMotionControlState {
}
