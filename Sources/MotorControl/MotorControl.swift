//
//  MotorControl.swift
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

final class MotorControlFactory : AssessmentFactory {
    
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
