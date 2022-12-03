//
//  MCTFactory.swift
//  MotorControl
//

import Foundation
import JsonModel
import Research
import MobilePassiveData
import MotionSensor

#if canImport(ResearchUI)
import ResearchUI
import MCTResources
#endif

extension RSDStepType {
    public static let handSelection: RSDStepType = "handSelection"
    public static let handInstruction: RSDStepType = "handInstruction"
    public static let tapping: RSDStepType = "tapping"
}

fileprivate var _didLoad: Bool = false

open class MCTFactory : RSDFactory {
    
    #if canImport(ResearchUI)
    /// The default color palette for this module is Royal 300, Butterscotch 300, Turquoise 300
    /// The design system is set as version 1.
    public static let designSystem: RSDDesignSystem = {
        let primary = RSDColorMatrix.shared.colorKey(for: .palette(.royal), shade: .medium)
        let secondary = RSDColorMatrix.shared.colorKey(for: .palette(.butterscotch), shade: .medium)
        let accent = RSDColorMatrix.shared.colorKey(for: .palette(.turquoise), shade: .medium)
        let palette = RSDColorPalette(version: 1, primary: primary, secondary: secondary, accent: accent)
        return RSDDesignSystem(palette: palette)
    }()
    #endif
    
    /// Override initialization to add the strings file to the localization bundles.
    public required init() {
        super.init()
        
        if !_didLoad {
            _didLoad = true
            
            #if canImport(ResearchUI)
            
            // Add the localization bundle if this is a first init()
            let localizationBundle = LocalizationBundle(MCTResources.bundle)
            Localization.insert(bundle: localizationBundle, at: 1)
            
            // Register authorization handlers
            PermissionAuthorizationHandler.registerAdaptorIfNeeded(MotionAuthorization.shared)
            
            // Set up the resource loader if its nil.
            if resourceLoader == nil {
                resourceLoader = ResourceLoader()
            }
            
            #endif
        }
        
        self.stepSerializer.add(MCTHandSelectionStepObject.serializationExample())
        self.stepSerializer.add(MCTHandInstructionStepObject.serializationExample())
        self.stepSerializer.add(MCTActiveStepObject.serializationExample())
        self.stepSerializer.add(MCTCountdownStepObject.serializationExample())
        self.stepSerializer.add(MCTTappingStepObject.serializationExample())
        
        self.taskSerializer.add(MCTTaskObject.serializationExample())
        
        self.resultSerializer.add(MCTTappingResultObject())
    }
    
    /// Override the task decoder to vend an `MCTTaskObject`.
    override open func decodeTask(with data: Data, from decoder: FactoryDecoder) throws -> RSDTask {
        let task = try decoder.decode(MCTTaskObject.self, from: data)
        try task.validate()
        return task
    }
}

extension RSDUIStepObject {
    fileprivate static func serializationExample() -> Self {
        self.init(identifier: self.defaultType().rawValue)
    }
}

extension MCTTaskObject {
    fileprivate static func serializationExample() -> MCTTaskObject {
        MCTTaskObject()
    }
}
