//
//  MCTTappingStepObject.swift
//  MotorControl
//

import Foundation
import Research
import JsonModel

#if os(iOS)
import UIKit
import ResearchUI
import MCTResources
#endif

/// Create a tapping step that will instantiate the tapping result and can load the storyboard view controller.
public class MCTTappingStepObject: MCTActiveStepObject {
    public override class func defaultType() -> RSDStepType {
        .tapping
    }
    
    /// Returns a new instance of a `MCTTappingResultObject`.
    public override func instantiateStepResult() -> ResultData {
        return MCTTappingResultObject(identifier: self.identifier)
    }
    
    #if os(iOS)
    
    /// By default, returns the task view controller from the storyboard.
    public override func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        let bundle = MCTResources.bundle
        let storyboard = UIStoryboard(name: "ActiveTaskSteps", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "Tapping") as? MCTTappingStepViewController
        vc?.stepViewModel = vc?.instantiateStepViewModel(for: self, with: parent)
        return vc
    }
    
    #endif
}
