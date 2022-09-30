//
//  MotorControl.swift
//  
//  Copyright © 2022 Sage Bionetworks. All rights reserved.
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
import AssessmentModel
import AssessmentModelUI
import JsonModel
import MobilePassiveData
import SharedResources

public enum MotorControlIdentifier : String, Codable, StringEnumSet, DocumentableStringEnum {
    
    /// The tremor test.
    case tremor = "Tremor"
    
    /// The kinetic tremor, or finger to nose, test.
    case kineticTremor = "Kinetic_Tremor"
    
    /// The tapping test.
    case tapping = "Finger_Tapping"

    public func instantiateAssessmentState() throws -> AssessmentState {
        let filename = self.rawValue
        guard let url = SharedResources.bundle.url(forResource: filename, withExtension: "json")
        else {
            throw ValidationError.unexpectedNullObject("Could not find JSON file \(filename).")
        }
        let data = try Data(contentsOf: url)
        let factory = MotorControlFactory()
        let decoder = factory.createJSONDecoder()
        let wrapper = try decoder.decode(AssessmentWrapper.self, from: data)
        return .init(wrapper.assessment)
    }
}

class MotorControlFactory : AssessmentFactory {
    
    required init() {
        super.init()
        
        assessmentSerializer.add(TwoHandAssessmentObject())
        
        nodeSerializer.add(HandInstructionObject())
        nodeSerializer.add(TappingNodeObject())
        nodeSerializer.add(TremorNodeObject())
        
        resultSerializer.add(TappingResultObject())
    }
    
    override func resourceBundle(for bundleInfo: DecodableBundleInfo, from decoder: Decoder) -> ResourceBundle? {
        SharedResources.bundle
    }
    
    override func createJSONDecoder(resourceInfo: ResourceInfo? = nil) -> JSONDecoder {
        super.createJSONDecoder(resourceInfo: SharedResources.shared)
    }
}

struct MotorControlResourceInfo : ResourceInfo {
    var factoryBundle: ResourceBundle? { SharedResources.bundle }
    var packageName: String? { nil }
    var bundleIdentifier: String? { nil }
}

struct AssessmentWrapper : Decodable {
    let assessment : Assessment
    init(from decoder: Decoder) throws {
        self.assessment = try decoder.serializationFactory.decodePolymorphicObject(Assessment.self, from: decoder)
    }
}
