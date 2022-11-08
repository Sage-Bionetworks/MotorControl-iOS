//
//  MCTCountdownStepViewController.swift
//  MotorControl
//

#if os(iOS)

import UIKit
import Research
import ResearchUI

open class MCTCountdownStepViewController : RSDCountdownStepViewController, MCTHandStepController {
    
    /// Retuns the imageView, in this case the image from the navigationHeader.
    public var imageView: UIImageView? {
        return self.navigationHeader?.imageView ?? self.navigationBody?.imageView
    }
    
    /// Override viewWillAppear to also set the unitLabel text.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateImage()
        self.view.setNeedsLayout()
        self.view.setNeedsUpdateConstraints()
    }
}

#endif
