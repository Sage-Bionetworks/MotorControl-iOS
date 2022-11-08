//
//  MCTActiveStepObject.swift
//  MotorControl
//

import Foundation
import Research

#if os(iOS)
import UIKit
import ResearchUI
#endif

/// Create a subclass of the active step that always requires background audio and should end on interrupt.
public class MCTActiveStepObject : RSDActiveUIStepObject {
    
    /// Returns `true`.
    public override var shouldEndOnInterrupt: Bool {
        get { return true }
        set {} // ignored
    }
    
    /// Returns `true`.
    public override var requiresBackgroundAudio: Bool {
        get { return true }
        set {} // ignored
    }
    
    #if os(iOS)
    
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        return MCTActiveStepViewController(step: self, parent: parent)
    }
    
    #endif
}

public final class MCTCountdownStepObject : MCTActiveStepObject {
    
    public override class func defaultType() -> RSDStepType { .countdown }
    
    #if os(iOS)
    
    public override func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        return MCTCountdownStepViewController(step: self, parent: parent)
    }
    
    #endif
}
