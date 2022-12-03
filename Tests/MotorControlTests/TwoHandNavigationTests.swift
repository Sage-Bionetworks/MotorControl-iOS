//

import XCTest
import JsonModel
import ResultModel
import AssessmentModel
import AssessmentModelUI
@testable import MotorControl

final class MotorControlNavigationTests: XCTestCase {
    
    func testTwoHandNavigatorNodeIdentifier() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let handSelectionNode = state.navigator.node(identifier: "handSelection")
        let completionNode = state.navigator.node(identifier: "completion")
        XCTAssertNotNil(handSelectionNode)
        XCTAssertNotNil(completionNode)
        
        let nonexistentNode = state.navigator.node(identifier: "randomNode")
        XCTAssertNil(nonexistentNode)
    }
    
    func testTwoHandTremorForwardNavigation() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let _ = try navigateForward(state, to: "completion")
        XCTAssertNotNil(state.currentNode)
    }
    
    func testTwoHandTremorHasNodeAfter() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let firstNode = state.navigator.firstNode()
        XCTAssertNotNil(firstNode)
        if let firstNode = firstNode {
            XCTAssertTrue(state.navigator.hasNodeAfter(currentNode: firstNode, branchResult: state.assessmentResult))
        }
        
        let holdPhoneInstructions = try navigateForward(state, to: "holdPhoneInstructions")
        XCTAssertTrue(state.navigator.hasNodeAfter(currentNode: holdPhoneInstructions, branchResult: state.assessmentResult))
        
        let lastNode = try navigateForward(state, to: "completion")
        XCTAssertFalse(state.navigator.hasNodeAfter(currentNode: lastNode, branchResult: state.assessmentResult))
    }
    
    func testTwoHandTremorNodeBefore() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())

        let firstNode = state.navigator.firstNode()
        XCTAssertNotNil(firstNode)
        
        let sitDownNode = try navigateForward(state, to: "sitDownInstruction")
        let nodeBefore = state.navigator.nodeBefore(currentNode: sitDownNode, branchResult: state.assessmentResult).node
        XCTAssertEqual(nodeBefore?.identifier, "holdPhoneInstructions")
    }
    
    func testTwoHandTremorNodeBefore_first() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let firstNode = try navigateForward(state, to: "introduction")
        let nodeBefore = state.navigator.nodeBefore(currentNode: firstNode, branchResult: state.assessmentResult).node
        XCTAssertNil(nodeBefore)
    }
    
    func testTwoHandTremorNodeBefore_right() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let rightNode = try navigateForward(state, to: "right")
        let nodeBefore = state.navigator.nodeBefore(currentNode: rightNode, branchResult: state.assessmentResult).node
        XCTAssertNil(nodeBefore)
    }
    
    func testTwoHandTremorNodeBefore_left() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let leftNode = try navigateForward(state, to: "left")
        let nodeBefore = state.navigator.nodeBefore(currentNode: leftNode, branchResult: state.assessmentResult).node
        XCTAssertNil(nodeBefore)
    }
    
    func testTwoHandTremorNodeBefore_completion() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let completionNode = try navigateForward(state, to: "completion")
        let nodeBefore = state.navigator.nodeBefore(currentNode: completionNode, branchResult: state.assessmentResult).node
        XCTAssertNil(nodeBefore)
    }
    
    func testTwoHandTremorHandSelection_left() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let _ = try navigateForward(state, to: "completion", handSelection: "left")
        let resultIdentifiers = state.assessmentResult.stepHistory.map {
            $0.identifier
        }
        XCTAssertFalse(resultIdentifiers.contains("right"))
    }
    
    func testTwoHandTremorHandSelection_right() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let _ = try navigateForward(state, to: "completion", handSelection: "right")
        let resultIdentifiers = state.assessmentResult.stepHistory.map {
            $0.identifier
        }
        XCTAssertFalse(resultIdentifiers.contains("left"))
    }
    
    func testTwoHandTremorHandSelection_both() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
        
        let _ = try navigateForward(state, to: "completion", handSelection: "both")
        let resultIdentifiers = state.assessmentResult.stepHistory.map {
            $0.identifier
        }
        XCTAssertTrue(resultIdentifiers.contains("right"))
        XCTAssertTrue(resultIdentifiers.contains("left"))
    }
    
    func testTwoHandTremorHandSelectionRandomization() throws {
        var resultIdentifierList: Set<[String]> = []
        for _ in 0...10 {
            let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
            let _ = try navigateForward(state, to: "completion", handSelection: "both")
            let resultIdentifiers = state.assessmentResult.stepHistory.map {
                $0.identifier
            }
            resultIdentifierList.insert(resultIdentifiers)
        }
        XCTAssertTrue(resultIdentifierList.count == 2)
    }
    
    func testTwoHandTremorIsCompleted() throws {
        let state = TestNavigationState(try MotorControlIdentifier.tremor.instantiateAssessmentState())
                                        
        guard let sitDownNode = state.navigator.node(identifier: "sitDownInstruction")
        else {
            throw TestError.nilValue
        }
        XCTAssertFalse(state.navigator.isCompleted(currentNode: sitDownNode, branchResult: state.assessmentResult))
        
        let _ = try navigateForward(state, to: "completion")
        guard let completionNode = state.currentNode
        else {
            throw TestError.nilValue
        }
        XCTAssertTrue(state.navigator.isCompleted(currentNode: completionNode, branchResult: state.assessmentResult))
    }
    
    func navigateForward(_ state: TestNavigationState, to identifier: String, handSelection: String? = "both") throws -> Node {
        var loopCount = 0
        var point: NavigationPoint = .init(node: nil, direction: .forward)
        repeat {
            point = state.navigator.nodeAfter(currentNode: state.currentNode, branchResult: state.assessmentResult)
            state.currentNode = point.node
            if point.node != nil {
                let result = point.node!.instantiateResult()
                if result.identifier == "handSelection" {
                    (result as! AnswerResult).jsonValue = handSelection.map {
                        .string($0)
                    }
                }
                state.assessmentResult.appendStepHistory(with: result, direction: point.direction)
            }
            loopCount += 1
        } while state.currentNode != nil && state.currentNode!.identifier != identifier && loopCount < 100

        XCTAssertEqual(identifier, state.currentNode?.identifier)
        XCTAssertLessThan(loopCount, 100, "Infinite loop of wacky madness")

        guard let node = point.node
        else {
            throw TestError.nilValue
        }
        return node
    }
}

class TestNavigationState : NavigationState {
    let assessmentState: AssessmentState

    public private(set) var navigator: Navigator! = nil

    var currentNode: Node?
    
    var assessment: Assessment { assessmentState.assessment }
    var assessmentResult: AssessmentResult { assessmentState.assessmentResult }

    init(_ assessmentState: AssessmentState) {
        self.assessmentState = assessmentState
        self.navigator = try! assessmentState.assessment.instantiateNavigator(state: self)
    }
}

enum TestError: Error {
    case nilValue
}
