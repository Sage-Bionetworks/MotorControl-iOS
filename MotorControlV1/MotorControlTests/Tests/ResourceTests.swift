//
//  ResourceTests.swift
//  MotorControlTests
//

#if os(iOS)

import XCTest
@testable import MotorControlV1
import Research
import ResearchUI

class ResourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        resourceLoader = ResourceLoader()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecodeTasks() {
        // Check that the JSON is decoding properly.
        MCTTaskIdentifier.allCases.forEach { taskIdentifier in
            let factory = MCTFactory()
            do {
                let taskTransformer = taskIdentifier.resourceTransformer()
                let task = try factory.decodeTask(with: taskTransformer)
                
                guard let steps = (task.stepNavigator as? RSDConditionalStepNavigatorObject)?.steps else {
                    XCTFail("Failed to decode expected step navigator for \(task.identifier)")
                    return
                }
                
                steps.forEach {
                    switch $0.stepType {
                    case .countdown:
                        XCTAssertTrue($0 is MCTCountdownStepObject, task.identifier)
                    case .active:
                        XCTAssertTrue($0 is MCTActiveStepObject, task.identifier)
                    case .handInstruction:
                        XCTAssertTrue($0 is MCTHandInstructionStepObject, task.identifier)
                    case .handSelection:
                        XCTAssertTrue($0 is MCTHandSelectionStepObject, task.identifier)
                    case .tapping:
                        XCTAssertTrue($0 is MCTTappingStepObject, task.identifier)
                    case .instruction:
                        XCTAssertTrue($0 is RSDInstructionStepObject, task.identifier)
                    case .overview:
                        XCTAssertTrue($0 is RSDOverviewStepObject, task.identifier)
                    case .completion:
                        XCTAssertTrue($0 is RSDCompletionStepObject, task.identifier)
                    default:
                        break
                    }
                }
                
            } catch let err {
                XCTFail("Failed to decode \(taskIdentifier): \(err)")
            }
        }
    }
    
    func testDecodeDefaultTaskInfo() {
        // Check that the JSON is decoding properly.
        for taskIdentifier in MCTTaskIdentifier.allCases {
            let taskInfo = MCTTaskInfo(taskIdentifier)
            let task = taskInfo.task
            XCTAssertEqual(task.identifier, taskIdentifier.rawValue)
        }
    }
}

#endif
