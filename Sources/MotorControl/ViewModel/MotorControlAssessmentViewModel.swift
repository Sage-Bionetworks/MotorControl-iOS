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

public final class MotorControlAssessmentViewModel : AssessmentViewModel {
    override public func nodeState(for node: Node) -> NodeState? {
        let nodeState = super.nodeState(for: node)
        if let instructionState = nodeState as? InstructionState {
            if let whichHand = HandSelection(rawValue: currentBranchState.node.identifier) {
                swapPlaceholderStringsAndReverseImage(in: instructionState, with: whichHand)
            }
        }
        return nodeState
    }
    
    private func swapPlaceholderStringsAndReverseImage(in instructionState: InstructionState, with whichHand: HandSelection) {
        let handPlaceHolder = "%@"
        instructionState.title = instructionState.title?.replacingOccurrences(of: handPlaceHolder, with: whichHand.rawValue.uppercased())
        instructionState.subtitle = instructionState.subtitle?.replacingOccurrences(of: handPlaceHolder, with: whichHand.rawValue.uppercased())
        instructionState.detail = instructionState.detail?.replacingOccurrences(of: handPlaceHolder, with: whichHand.rawValue.uppercased())
        
        if whichHand.rawValue == HandSelection.right.rawValue, let imageInfo = instructionState.contentNode.imageInfo as? FetchableImage, let uiImage = UIImage(named: imageInfo.imageName, in: SharedResources.bundle, compatibleWith: nil) {
            instructionState.image = Image(uiImage: uiImage.withHorizontallyFlippedOrientation())
        }
    }
}
