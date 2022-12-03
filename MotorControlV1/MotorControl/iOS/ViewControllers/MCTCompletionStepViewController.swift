//
//  MCTCompletionStepViewController.swift
//  MotorControl
//

#if os(iOS)

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

#endif
