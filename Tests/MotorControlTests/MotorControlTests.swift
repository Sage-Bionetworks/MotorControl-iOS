//

import XCTest
import JsonModel
import AssessmentModel
import AssessmentModelUI
@testable import MotorControl

final class MotorControlTests: XCTestCase {
    
    func testAssessmentDecoding() {
        do {
            try MotorControlIdentifier.allCases.forEach { identifier in
                let _ = try identifier.instantiateAssessmentState()
            }
        }
        catch {
            XCTFail("Failed to build assessment. \(error)")
        }
    }
}
