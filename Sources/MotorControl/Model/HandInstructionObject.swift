//
//  HandInstructionObject.swift
//  
//

import Foundation
import AssessmentModel
import JsonModel

extension SerializableNodeType {
    static let handInstruction: SerializableNodeType = "handInstruction"
}


final class HandInstructionObject : AbstractInstructionStepObject {
    override class func defaultType() -> SerializableNodeType {
        .handInstruction
    }

    convenience init() {
        self.init(identifier: "example")
    }
}

