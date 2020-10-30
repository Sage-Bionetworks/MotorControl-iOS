//
//  MCTFactory.swift
//  MotorControl
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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

import Foundation
import JsonModel

extension RSDStepType {
    public static let handSelection: RSDStepType = "handSelection"
    public static let handInstruction: RSDStepType = "handInstruction"
    public static let tapping: RSDStepType = "tapping"
}

fileprivate var _didLoad: Bool = false

open class MCTFactory : RSDFactory {
    
    /// The default color palette for this module is Royal 300, Butterscotch 300, Turquoise 300
    /// The design system is set as version 1.
    public static let designSystem: RSDDesignSystem = {
        let primary = RSDColorMatrix.shared.colorKey(for: .palette(.royal), shade: .medium)
        let secondary = RSDColorMatrix.shared.colorKey(for: .palette(.butterscotch), shade: .medium)
        let accent = RSDColorMatrix.shared.colorKey(for: .palette(.turquoise), shade: .medium)
        let palette = RSDColorPalette(version: 1, primary: primary, secondary: secondary, accent: accent)
        return RSDDesignSystem(palette: palette)
    }()
    
    /// Override initialization to add the strings file to the localization bundles.
    public required init() {
        super.init()
        
        if !_didLoad {
            _didLoad = true
            
            // Add the localization bundle if this is a first init()
            let localizationBundle = LocalizationBundle(Bundle(for: MCTFactory.self))
            Localization.insert(bundle: localizationBundle, at: 1)
            
            // Register authorization handlers
            RSDAuthorizationHandler.registerAdaptorIfNeeded(RSDMotionAuthorization.shared)
            
            // Set up the resource loader if its nil.
            if resourceLoader == nil {
                resourceLoader = ResourceLoader()
            }
        }
        
        self.stepSerializer.add(MCTHandSelectionStepObject.serializationExample())
        self.stepSerializer.add(MCTHandInstructionStepObject.serializationExample())
        self.stepSerializer.add(MCTActiveStepObject.serializationExample())
        self.stepSerializer.add(MCTCountdownStepObject.serializationExample())
        self.stepSerializer.add(MCTTappingStepObject.serializationExample())
        
        self.taskSerializer.add(MCTTaskObject.serializationExample())
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
        MCTTaskObject(identifier: MCTTaskObject.defaultType().rawValue, steps: [])
    }
}
