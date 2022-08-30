//
//  MotorControl.swift
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

public final class MotorControlAssessmentViewModel : AssessmentViewModel {
//    override public func nodeState(for node: Node) -> NodeState? {
//        if let step = node as? HandInstructionObject,
//           let whichHand = HandSelection(rawValue: currentBranchState.node.identifier) {
//            return TwoHandInstructionState(step, whichHand: whichHand, parentId: currentBranchState.id)
//        }
//        else {
//            return super.nodeState(for: node)
//        }
//    }
    override public func nodeState(for node: Node) -> NodeState? {
        let nodeState = super.nodeState(for: node)
        if let instructionState = nodeState as? InstructionState {
            if let whichHand = HandSelection(rawValue: currentBranchState.node.identifier) {
                
            }
            else if let imageInfo = instructionState.contentNode.imageInfo as? FetchableImage {
                instructionState.image = Image(imageInfo.imageName, bundle: SharedResources.bundle)
            }
        }
            //TODO: Aaron Rabara 8/25/22 add logic here to switch hand text
        
        return nodeState
    }
}

//public final class TwoHandInstructionState : ContentNodeState {
//    @Published public var image: Image?
//    @Published public var title: String?
//    @Published public var subtitle: String?
//    @Published public var detail: String?
//    let whichHand : HandSelection
//
//    public init(_ instruction: ContentStep, whichHand: HandSelection, parentId: String? = nil) {
//        self.title = instruction.title
//        self.subtitle = instruction.subtitle
//        self.detail = instruction.detail
//        self.whichHand = whichHand
//        if let imageInfo = instruction.imageInfo as? FetchableImage {
//            self.image = Image(imageInfo.imageName, bundle: imageInfo.bundle)
//        }
//        super.init(step: instruction, result: instruction.instantiateResult(), parentId: parentId)
//    }
//}
