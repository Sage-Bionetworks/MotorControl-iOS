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

import XCTest
import JsonModel
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

final class MotorControlViewModelTests: XCTestCase {
    
    func testInstructionStateHand() throws {
        let left = HandSelection.left.rawValue.uppercased()
        let right = HandSelection.right.rawValue.uppercased()
        
        let instructionStateLeft = MotorControlInstructionState(handInstructionExample, parentId: nil, whichHand: HandSelection.left)
        guard let title = instructionStateLeft.title, let detail = instructionStateLeft.detail else { throw TestError.nilValue }
        XCTAssert(title.contains(left))
        XCTAssert(detail.contains(left))
        XCTAssertFalse(title.contains(right))
        XCTAssertFalse(detail.contains(right))
        
        let instructionStateRight = MotorControlInstructionState(handInstructionExample, parentId: nil, whichHand: HandSelection.right)
        guard let title = instructionStateRight.title, let detail = instructionStateRight.detail else { throw TestError.nilValue }
        XCTAssert(title.contains(right))
        XCTAssert(detail.contains(right))
        XCTAssertFalse(title.contains(left))
        XCTAssertFalse(detail.contains(left))
        
        XCTAssertFalse(instructionStateLeft.flippedImage)
        XCTAssert(instructionStateRight.flippedImage)
    }
    
    func testTappingState() throws {
        let assessmentState: AssessmentState = .init(AssessmentObject())
        let tappingStepViewModel: TappingStepViewModel = .init(tappingExample, assessmentState: assessmentState, branchState: assessmentState)
        var taps = 50
        for ii in 0..<taps {
            let tappedButton = getTappingButtonIdentifier(ii)
            let location = tappedButton == TappingButtonIdentifier.left ? CGPoint(x: 100, y: 500) : CGPoint(x: 200, y: 500)
            tappingStepViewModel.tappedScreen(uptime: TimeInterval(ii),
                                              timestamp: TimeInterval(ii),
                                              currentButton: tappedButton,
                                              location: location,
                                              duration: 0.05)
        }
        
        var goodTaps = taps - Int(taps / 3)
        XCTAssertEqual(tappingStepViewModel.tapCount, goodTaps)
        XCTAssertEqual(tappingStepViewModel.samples.count, taps)

        tappingStepViewModel.tappedScreen(uptime: TimeInterval(1),
                                          timestamp: TimeInterval(1),
                                          currentButton: getTappingButtonIdentifier(taps),
                                          location: CGPoint(x: 100, y: 500),
                                          duration: 0.05)
        taps += 1
        goodTaps = taps - Int(taps / 3)
        XCTAssertEqual(tappingStepViewModel.tapCount, goodTaps)
        XCTAssertEqual(tappingStepViewModel.samples.count, taps)
        
        for ii in 0..<taps {
            tappingStepViewModel.tappedScreen(uptime: TimeInterval(ii),
                                              timestamp: TimeInterval(ii),
                                              currentButton: TappingButtonIdentifier.none,
                                              location: CGPoint(x: 100, y: 500),
                                              duration: 0.05)
        }
        XCTAssertEqual(tappingStepViewModel.tapCount, goodTaps)
        XCTAssertEqual(tappingStepViewModel.samples.count, taps * 2)
    }
}

func getTappingButtonIdentifier(_ ii: Int) -> TappingButtonIdentifier {
    switch ii % 3 {
    case 0:
        return TappingButtonIdentifier.left
    case 1:
        return TappingButtonIdentifier.right
    default:
        return TappingButtonIdentifier.none
    }
}

fileprivate let handInstructionExample = InstructionStepObject(
    identifier: "instruction",
    title: "Tap with your %@ hand",
    detail: "Alternate tapping the buttons that appear with your index and middle fingers on your %@ HAND. Keep tapping for 30 seconds as fast as you can.")

fileprivate let tappingExample = TappingNodeObject(identifier: "tappingExample")

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
