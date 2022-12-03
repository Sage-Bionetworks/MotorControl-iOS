//

import XCTest
import JsonModel
import AssessmentModel
import AssessmentModelUI
@testable import MotorControl

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
    
    @MainActor func testTappingStateCorrectTaps() async {
        let assessmentState: AssessmentState = .init(AssessmentObject())
        let tappingStepViewModel: TappingStepViewModel = .init(tappingExample, assessmentState: assessmentState, branchState: assessmentState)
        let taps = 30
        for ii in 0..<taps {
            let tappedButton = getAlternatingButtonIdentifier(ii, modulo: 2)
            let location = tappedButton == TappingButtonIdentifier.left ? CGPoint(x: 100, y: 500) : CGPoint(x: 200, y: 500)
            tappingStepViewModel.addTappingSample(currentButton: tappedButton,
                                                  location: location,
                                                  duration: 0.05)
        }
        XCTAssertEqual(tappingStepViewModel.tapCount, 30)
        XCTAssertEqual(tappingStepViewModel.tappingResult.samples.count, 30)
    }
    
    @MainActor func testTappingStateMixedTaps() async {
        let assessmentState: AssessmentState = .init(AssessmentObject())
        let tappingStepViewModel: TappingStepViewModel = .init(tappingExample, assessmentState: assessmentState, branchState: assessmentState)
        let taps = 30
        for ii in 0..<taps {
            let tappedButton = getAlternatingButtonIdentifier(ii, modulo: 3)
            let location = tappedButton == TappingButtonIdentifier.left ? CGPoint(x: 100, y: 500) : CGPoint(x: 200, y: 500)
            tappingStepViewModel.addTappingSample(currentButton: tappedButton,
                                                  location: location,
                                                  duration: 0.05)
        }
        XCTAssertEqual(tappingStepViewModel.tapCount, 20)
        XCTAssertEqual(tappingStepViewModel.tappingResult.samples.count, 30)
    }
    
    @MainActor func testTappingStateNoCorrectTaps() {
        let assessmentState: AssessmentState = .init(AssessmentObject())
        let tappingStepViewModel: TappingStepViewModel = .init(tappingExample, assessmentState: assessmentState, branchState: assessmentState)
        let taps = 30
        for _ in 0..<taps {
            tappingStepViewModel.addTappingSample(currentButton: TappingButtonIdentifier.none,
                                                  location: CGPoint(x: 300, y: 300),
                                                  duration: 0.05)
        }
        XCTAssertEqual(tappingStepViewModel.tapCount, 0)
        XCTAssertEqual(tappingStepViewModel.tappingResult.samples.count, 30)
    }
}

func getAlternatingButtonIdentifier(_ ii: Int, modulo: Int) -> TappingButtonIdentifier {
    .allCases[ii % modulo]
}

fileprivate let handInstructionExample = InstructionStepObject(
    identifier: "instruction",
    title: "Tap with your %@ hand",
    detail: "Alternate tapping the buttons that appear with your index and middle fingers on your %@ HAND. Keep tapping for 30 seconds as fast as you can.")

fileprivate let tappingExample = TappingNodeObject(identifier: "tappingExample")
