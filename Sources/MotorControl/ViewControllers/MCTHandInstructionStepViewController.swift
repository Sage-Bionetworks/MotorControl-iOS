//
//  MCTHandInstructionStepViewController.swift
//  MotorControl
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

import UIKit
import Research
import ResearchUI

public protocol MCTHandStepController : RSDStepController {
    
    /// isFirstAppearance should be `true` if this is the first time the view has appeared, and
    /// `false` otherwise
    var isFirstAppearance: Bool { get }
    
    /// Should return the image view from this view.
    var imageView: UIImageView? { get }
    
    /// The label for displaying step title text.
    var stepTitleLabel: UILabel? { get }
    
    /// The label for displaying step text.
    var stepTextLabel: UILabel? { get }
    
    /// The label for displaying step detail text.
    var stepDetailLabel: UILabel? { get }
    
    /// Convenience property for casting the step to a `RSDUIStep`.
    var uiStep: RSDUIStep? { get }
}

extension MCTHandStepController {
    
    /// Returns the randomized order that the hands steps will execute in from the task result.
    public func handOrder() -> [MCTHandSelection]? {
        var taskPath: RSDPathComponent? = self.stepViewModel.parent
        repeat {
            if let handSelectionResult = taskPath?.taskResult.findResult(with: MCTHandSelectionDataSource.selectionKey) as? CollectionResult,
               let handOrder : [String] = handSelectionResult.findAnswer(with: MCTHandSelectionDataSource.handOrderKey)?.value as? [String] {
                return handOrder.compactMap{ MCTHandSelection(rawValue: $0) }
            }
        
            taskPath = taskPath?.parent
        } while (taskPath != nil)
        
        return nil
    }
    
    /// Returns whichever hand is next to perform this task.
    public func nextHand() -> MCTHandSelection? {
        if let handOrder = handOrder() {
            var taskPath: RSDPathComponent? = self.stepViewModel.parent
            repeat {
                if taskPath?.taskResult.findResult(with: handOrder.first!.stringValue) != nil {
                    return handOrder.last
                }
                
                taskPath = taskPath?.parent
            } while (taskPath != nil)
            return handOrder.first
        }
        
        return nil
    }
    
    /// Returns which hand is being used for this step.
    public func whichHand() -> MCTHandSelection? {
        if let handIdentifier = self.stepViewModel?.parentTaskPath?.identifier,
            let hand = MCTHandSelection(rawValue: handIdentifier) {
            return hand
        }
        return nextHand()
    }
    
    /// Flips the image if this view is for the right hand. Only flips the first time the view appears.
    public func updateImage() {
        guard let direction = self.whichHand(),
              self.isFirstAppearance,
              direction == .right else { return }
        self.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    /// Sets the title and text labels' text to a version of their text localized with
    /// a string from the body direction that goes first. Expected is either ("LEFT" or "RIGHT").
    public func updateLabelText() {
        guard let direction = self.whichHand()?.rawValue.uppercased() else { return }
        // TODO: rkolmos 04/09/2018 localize and standardize with java implementation
        if let titleFormat = self.uiStep?.title {
            self.stepTitleLabel?.text = String.localizedStringWithFormat(titleFormat, direction)
        }
        if let textFormat = self.uiStep?.subtitle {
            self.stepTextLabel?.text = String.localizedStringWithFormat(textFormat, direction)
        }
    }
}

extension MCTHandInstructionStepObject : RSDStepViewControllerVendor {
    
    /// By default, return the task view controller from the storyboard.
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        let vc = MCTHandInstructionStepViewController(step: self, parent: parent)
        return vc
    }
}

open class MCTHandInstructionStepViewController : RSDInstructionStepViewController, MCTHandStepController {
    
    /// Override viewWillAppear to update the label text, and image placement constraints.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateLabelText()
        self.updateImage()
    }
}
