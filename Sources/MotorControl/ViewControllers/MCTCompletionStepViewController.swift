//
//  MCTCompletionStepViewController.swift
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

public class MCTCompletionStepViewController : RSDStepViewController {

    /// Override viewWillAppear to update the text label.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTextLabel()
    }

    /// Updates the text label to display the count of the number of times this task
    /// has been completed.
    public func updateTextLabel() {
        // Check that there is a key into the strings table or else exist early
        guard let textKey = (self.step as? RSDUIStep)?.subtitle else { return }
        let defaultText = Localization.localizedString(textKey)
        guard textKey != defaultText else { return }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        if RSDStudyConfiguration.shared.isParticipantDevice,
            let task = self.stepViewModel.rootPathComponent.task as? MCTTaskObject,
            let ordinal = formatter.string(from: NSNumber(value: task.runCount)) {
            let textFormat = "\(textKey)_%@"
            self.stepTextLabel?.text = String.localizedStringWithFormat(Localization.localizedString(textFormat), ordinal)
        }
        else {
            self.stepTextLabel?.text = defaultText
        }
    }
    
    public override func defaultBackgroundColorTile(for placement: RSDColorPlacement) -> RSDColorTile {
        if placement == .header {
            return self.designSystem.colorRules.palette.successGreen.normal
        }
        else {
            return self.designSystem.colorRules.backgroundLight
        }
    }
}
