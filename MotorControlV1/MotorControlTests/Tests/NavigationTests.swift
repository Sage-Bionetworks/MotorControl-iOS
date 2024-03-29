//
//  NavigationTests.swift
//  MotorControlTests
//

#if canImport(Research_UnitTest)

@testable import MotorControlV1
import XCTest
import Research_UnitTest
import JsonModel
import Research

class TestHandStepController: NSObject, MCTHandStepController {

    var stepViewModel: RSDStepViewPathComponent!
    
    init(step: RSDStep, parent: RSDPathComponent) {
        stepViewModel = RSDStepViewModel(step: step, parent: parent)
    }
    
    var isFirstAppearance: Bool = true
    
    var imageView: UIImageView?
    
    var stepTitleLabel: UILabel?
    
    var stepTextLabel: UILabel?
    
    var stepDetailLabel: UILabel?
    
    var uiStep: RSDUIStep?

    func didFinishLoading() {
        //
    }
    
    func goForward() {
        self.stepViewModel.perform(actionType: .navigation(.goForward))
    }
    
    func goBack() {
        self.stepViewModel.perform(actionType: .navigation(.goBackward))
    }
}

class NavigationTests: XCTestCase {
    
    var taskController : TestTaskController!
    var steps : [RSDStep]!
    var handSelection : [String]!
    var previousFrequency : RSDFrequencyType!
    
    override func setUp() {
        
        previousFrequency = RSDStudyConfiguration.shared.fullInstructionsFrequency
        RSDStudyConfiguration.shared.fullInstructionsFrequency = .monthly
        
        self.steps = []
        let firstSteps : [RSDStep] = TestStep.steps(from: ["overview", "instruction"])
        self.steps.append(contentsOf: firstSteps)
        let leftSectionSteps : [RSDStep] = TestStep.steps(from: ["leftInstruction", "leftActive"])
        let leftSection : RSDSectionStepObject = RSDSectionStepObject(identifier: "left", steps: leftSectionSteps)
        self.steps.append(leftSection)
        let rightSectionSteps : [RSDStep] = TestStep.steps(from: ["rightInstruction", "rightActive"])
        let rightSection : RSDSectionStepObject = RSDSectionStepObject(identifier: "right", steps: rightSectionSteps)
        self.steps.append(rightSection)
        let finalSteps : [RSDStep] = TestStep.steps(from: ["completion"])
        self.steps.append(contentsOf: finalSteps)
        self.taskController = TestTaskController()
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["overview", "instruction", "left", "right", "completion"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        self.taskController = TestTaskController()
        self.taskController.task = task
        super.setUp()
    }
    
    override func tearDown() {
        self.taskController = nil
        self.steps = nil
        RSDStudyConfiguration.shared.fullInstructionsFrequency = previousFrequency
        super.tearDown()
    }
    
    private func _insertHandSelectionResult(for taskController: TestTaskController) {
        let collectionResult = CollectionResultObject(identifier: "handSelection")
        
        let answerResult = AnswerResultObject(identifier: "handSelection", answerType: AnswerTypeString())
        if self.handSelection.count == 2 {
            answerResult.jsonValue = .string("both")
        } else {
            answerResult.jsonValue = .string(self.handSelection.first!)
        }
        
        collectionResult.appendInputResults(with: answerResult)
        let answerType = AnswerTypeArray(baseType: .string)
        let handOrderResult = AnswerResultObject(identifier: MCTHandSelectionDataSource.handOrderKey, answerType: answerType)
        handOrderResult.jsonValue = .array(self.handSelection)
        collectionResult.appendInputResults(with: handOrderResult)
        self.taskController.taskViewModel.taskResult.appendStepHistory(with: collectionResult)
    }
    
    private func _setupInstructionStepTest() {
        self.steps = []
        let firstSteps : [RSDStep] = TestStep.steps(from: ["first"])
        self.steps.append(contentsOf: firstSteps)
        let firstRunOnly = RSDUIStepObject(identifier: "instructionFirstRunOnly", type: .instruction)
        firstRunOnly.fullInstructionsOnly = true
        self.steps.append(firstRunOnly)
        self.steps.append(RSDUIStepObject(identifier: "instructionNotFirstRunOnly", type: .instruction))
        let finalSteps : [RSDStep] = TestStep.steps(from: ["completion"])
        self.steps.append(contentsOf: finalSteps)
        self.taskController = TestTaskController()
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["overview", "instructionFirstRunOnly", "instructionNotFirstRunOnly", "completion"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        self.taskController = TestTaskController()
        self.taskController.task = task
        super.setUp()
    }
    
    private func _whichHand(step: RSDStep) -> String? {
        return TestHandStepController(step: step, parent: self.taskController.taskViewModel.currentTaskPath).whichHand()?.rawValue
    }
    
    public func testSkippableSection_Left() {
        self.handSelection = ["left"]
        _insertHandSelectionResult(for: self.taskController)
        let _ = self.taskController.test_stepTo("instruction")
        // Go forward to the leftInstruction step
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward into the leftActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward to the completion step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
    
    public func testSkippableSection_Right() {
        self.handSelection = ["right"]
        _insertHandSelectionResult(for: self.taskController)
        let _ = self.taskController.test_stepTo("instruction")
        // Go forward to the rightInstruction step
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward into the rightActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward to the completion step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }

    public func testSkippableSection_LeftThenRight() {
        self.handSelection = ["left", "right"]
        _insertHandSelectionResult(for: self.taskController)
        let _ = self.taskController.test_stepTo("instruction")
        // Go forward to the leftInstruction step
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward into the leftActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward to the rightInstruction step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward into the rightActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward to the completion step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
    
    public func testSkippableSection_RightThenLeft() {
        self.handSelection = ["right", "left"]
        _insertHandSelectionResult(for: self.taskController)
        let _ = self.taskController.test_stepTo("instruction")
        // Go forward to the rightInstruction step
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward into the rightActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward to the leftInstruction step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward into the leftActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward to the completion step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
    
    public func testInstructionStep_firstRun() {
        _setupInstructionStepTest()
        self.taskController.taskViewModel.shouldShowAbbreviatedInstructions = false
        let _ = self.taskController.test_stepTo("first")
        // Go forward, shouldn't skip the instructionFirstRunOnly
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "instructionFirstRunOnly")
        // Go forward, shouldn't skip the instructionNotFirstRunOnly step either
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "instructionNotFirstRunOnly")
        // Go forward should proceed from instructionNotFirstRunOnly to completion
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
    
    public func testInstructionStep_notFirstRun() {
        _setupInstructionStepTest()
        self.taskController.taskViewModel.shouldShowAbbreviatedInstructions = true
        let _ = self.taskController.test_stepTo("first")
        // Go forward, should skip the instructionFirstRunOnly
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "instructionNotFirstRunOnly")
        // Go forward should proceed from instructionNotFirstRunOnly to completion
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
}

#endif
