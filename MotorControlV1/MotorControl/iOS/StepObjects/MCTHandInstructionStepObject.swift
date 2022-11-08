//
//  MCTHandInstructionStepObject.swift
//  MotorControl
//

import Foundation
import Research


/// The hand instruction step is a custom step that allows adding functionality to the base step to allow
/// using the same step object for both the right and left hand.
public class MCTHandInstructionStepObject : RSDUIStepObject {
    public override class func defaultType() -> RSDStepType {
        .handInstruction
    }
}
