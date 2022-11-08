//
//  MCTActiveStepViewController.swift
//  MotorControl
//

#if os(iOS)

import UIKit
import Research
import ResearchUI

extension MCTActiveStepObject : RSDStepViewControllerVendor {
}

open class MCTActiveStepViewController : RSDActiveStepViewController, MCTHandStepController {
    
    /// Retuns the imageView, in this case the image from the navigationHeader.
    public var imageView: UIImageView? {
        return self.navigationHeader?.imageView ?? self.navigationBody?.imageView
    }

    /// Override viewWillAppear to also set the unitLabel text.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Attempted to split the DataComponentsFormatter into a number and a unit label, however
        // DateComponentsFormatter doesn't actually translate into other languages.
        self.updateImage()
        self.updateLabelText()
        self.view.setNeedsLayout()
        self.view.setNeedsUpdateConstraints()
    }
    
    /// Override to return the instruction with the formatted text replaced.
    override open func spokenInstruction(at duration: TimeInterval) -> String? {
        guard let textFormat = super.spokenInstruction(at: duration) else { return nil }
        guard let direction = self.whichHand()?.rawValue.uppercased() else { return textFormat }
        // TODO: rkolmos 04/09/2018 localize and standardize with java implementation
        return String.localizedStringWithFormat(textFormat, direction)
    }
}

#endif
