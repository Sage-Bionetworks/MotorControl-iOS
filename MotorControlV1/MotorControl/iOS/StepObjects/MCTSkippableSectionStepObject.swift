//
//  MCTSkippableSectionStepObject.swift
//  MotorControl
//

import Foundation
import JsonModel
import Research

/// Extend RSDSectionStepObject to implement navigation rules for each hand. These sections are
/// intended to be used when a study has results from the left and right side of the body, and
/// needs to randomize which order tests are done in.
extension RSDSectionStepObject: RSDNavigationSkipRule, RSDNavigationRule {
    
    /// Returns `true` if this step should be skipped and `false` otherwise.
    public func shouldSkipStep(with result: RSDTaskResult?, isPeeking: Bool) -> Bool {
        guard let myHand = MCTHandSelection(rawValue: self.identifier),
              let handSelectionResult = result?.findResult(with: MCTHandSelectionDataSource.selectionKey) as? CollectionResult,
              let handOrder = handSelectionResult.findAnswer(with: MCTHandSelectionDataSource.handOrderKey)?.value as? [String]
            else {
                return false
        }
        
        if handOrder.first! == self.identifier {
            let previousResultForThisStep = result?.findResult(with: self.identifier)
            // If there is a previous result for this step, we should skip this step.
            return previousResultForThisStep != nil
        } else if handOrder.last! == self.identifier, let otherHand = myHand.otherHand {
            let previousResultForOther = result?.findResult(with: otherHand.stringValue)
            // If there is not a previous result for the other step, we sholud skip this step.
            return previousResultForOther == nil
        }
        
        // self.identifier isn't in the handOrder array so this section isn't for a specific hand.
        return true
        
    }
    
    /// Returns the identifier of the step to go to after this step is completed, or skipped.
    public func nextStepIdentifier(with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        guard let handSelectionResult = result?.findResult(with: MCTHandSelectionDataSource.selectionKey) as? CollectionResult,
            let handOrder : [String] = handSelectionResult.findAnswer(with: MCTHandSelectionDataSource.handOrderKey )?.value as? [String]
            else {
                return nil
        }
        
        if handOrder.first! == self.identifier,
            handOrder.last! != self.identifier {
            // if this step should go first, and there is a step after it return the step after it,
            // and the step after it hasn't run yet, we return the next steps identifier
            let previousResultForOtherStep = result?.findResult(with: handOrder.last!)
            if previousResultForOtherStep == nil {
                return handOrder.last!
            }
        }
        
        // in all other cases, the next step is just the defualt next step.
        return nil
    }
    
    /// Returns `true` if first is the opposite hand of second, `false` otherwise. If
    /// either first or second is .both returns `false`.
    private func _isOppositeHand(_ first: MCTHandSelection, _ second: MCTHandSelection) -> Bool {
        return first != .both && second != .both && first != second
    }
}
