//
//  WalkAssessmentObject.swift
//
//

import Foundation
import AssessmentModel
import SharedResources

extension SerializableNodeType {
    static let walkAssessment: SerializableNodeType = "walkAssessment"
}

final class WalkingAssessmentObject : AbstractAssessmentObject {
    override class func defaultType() -> SerializableNodeType {
        .walkAssessment
    }

    convenience init() {
        self.init(identifier: "example", children: [])
    }
    
    /// Maybe need to change nodenavigator in assessment model to handle full instructions
}
