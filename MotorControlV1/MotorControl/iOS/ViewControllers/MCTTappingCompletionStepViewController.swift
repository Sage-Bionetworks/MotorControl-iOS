//
//  MCTTappingCompletionViewController.swift
//  MotorControl
//

#if os(iOS)

import UIKit
import Research
import ResearchUI

open class MCTTappingCompletionStepViewController : RSDStepViewController {
    
    /// The constraint that makes both tapping count labels have equal height.
    @IBOutlet weak var labelHeightEqualityConstraint: NSLayoutConstraint!
    
    /// The constraint on the height of the right count label.
    @IBOutlet weak var rightHeightConstraint: NSLayoutConstraint!
    
    /// The constraint on the height of the left count label.
    @IBOutlet weak var leftHeightConstraint: NSLayoutConstraint!
    
    /// The label that describes what the right tap count means to the user.
    @IBOutlet weak var rightUnitLabel: UILabel!
    
    /// The label that displays the right tap count.
    @IBOutlet weak var rightCountLabel: UILabel!
    
    /// The label that describes what the left tap count means to the user.
    @IBOutlet weak var leftUnitLabel: UILabel!
    
    /// The label that displays the left tap count.
    @IBOutlet weak var leftCountLabel: UILabel!
    
    /// Override viewWillAppear to get the tapping results, hide the appropriate views,
    /// and update the labels text.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        rightCountLabel.font = self.designSystem.fontRules.font(for: .smallNumber, compatibleWith: traitCollection)
        leftCountLabel.font = self.designSystem.fontRules.font(for: .smallNumber, compatibleWith: traitCollection)
        rightUnitLabel.font = self.designSystem.fontRules.baseFont(for: .small)
        leftUnitLabel.font = self.designSystem.fontRules.baseFont(for: .small)
        
        let results = _getTappingResults()
        self._hideViews(shouldHideLeft: results.leftCount == nil, shouldHideRight: results.rightCount == nil)
        self.updateLabels(leftCount: results.leftCount, rightCount: results.rightCount)
    }
    
    open override func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        if placement == .body {
            rightCountLabel.textColor = self.designSystem.colorRules.textColor(on: background, for: .smallNumber)
            leftCountLabel.textColor = self.designSystem.colorRules.textColor(on: background, for: .smallNumber)
            rightUnitLabel.textColor = self.designSystem.colorRules.textColor(on: background, for: .small)
            leftUnitLabel.textColor = self.designSystem.colorRules.textColor(on: background, for: .small)
        }
    }
    
    /// Updates the text of both the labels displaying the tap count numbers, and the
    /// labels describing what these numbers mean (ie "LEFT HAND TAPS").
    open func updateLabels(leftCount: Int?, rightCount: Int?) {
        if leftCount != nil {
            self.leftUnitLabel.text = Localization.localizedString("TAPPING_COMPLETION_LEFT_UNIT_LABEL")
            self.leftCountLabel.text = String(leftCount!)
        }
        
        if rightCount != nil {
            self.rightUnitLabel.text = Localization.localizedString("TAPPING_COMPLETION_RIGHT_UNIT_LABEL")
            self.rightCountLabel.text = String(rightCount!)
        }
    }
    
    // Returns a tuple containing the number of taps from each hand. A hand that doesn't
    // perform the activity will have `nil` returned as its number of taps.
    private func _getTappingResults() -> (leftCount: Int?, rightCount: Int?) {
        let leftCount = _getTappingResult(with: .left)
        let rightCount = _getTappingResult(with: .right)
        return (leftCount: leftCount, rightCount: rightCount)
    }
    
    // Returns the number of taps for the result with the given identifier.
    // identifier is typically expected to be either "left" or "right"
    private func _getTappingResult(with identifier: MCTHandSelection) -> Int? {
        let taskResult = self.stepViewModel.taskResult
        guard let result = taskResult.findResult(with: identifier.stringValue) as? RSDTaskResult,
            let tappingResult = result.findResult(with: "tapping") as? MCTTappingResultObject
            else {
                return nil
        }
        
        return tappingResult.tapCount
    }
    
    // Hides the left and right results labels depinding on whether or not
    // they should be hidden.
    private func _hideViews(shouldHideLeft: Bool, shouldHideRight: Bool) {
        if shouldHideLeft {
            self.leftCountLabel.removeFromSuperview()
            self.leftUnitLabel.removeFromSuperview()
        }
        if shouldHideRight {
            self.rightCountLabel.removeFromSuperview()
            self.rightUnitLabel.removeFromSuperview()
        }
        self.view.setNeedsLayout()
    }
    
    open override func defaultBackgroundColorTile(for placement: RSDColorPlacement) -> RSDColorTile {
        if placement == .header {
            return self.designSystem.colorRules.palette.successGreen.normal
        }
        else {
            return self.designSystem.colorRules.backgroundLight
        }
    }
}

#endif
