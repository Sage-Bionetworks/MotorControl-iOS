//
//  MotorControlAssessmentView.swift
//

import SwiftUI
import AssessmentModel
import AssessmentModelUI
import JsonModel
import SharedResources
import SharedMobileUI
import MobilePassiveData

extension MotorControlAssessmentView : AssessmentDisplayView {
    public static func instantiateAssessmentState(_ identifier: String, config: Data?, restoredResult: Data?, interruptionHandling: InterruptionHandling?) throws -> AssessmentState {
        guard let taskId = MotorControlIdentifier(rawValue: identifier)
        else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "This view does not support \(identifier)"))
        }
        return try taskId.instantiateAssessmentState()
    }
}

/// Displays an assessment built using the views and model objects defined within this library.
public struct MotorControlAssessmentView : View {
    @StateObject var viewModel: MotorControlAssessmentViewModel = .init()
    @ObservedObject var assessmentState: AssessmentState
    
    public init(_ assessmentState: AssessmentState) {
        self.assessmentState = assessmentState
    }
    
    public var body: some View {
        AssessmentWrapperView<StepView>(assessmentState, viewModel: viewModel)
    }
    
    struct StepView : View, StepFactoryView {
        @EnvironmentObject var pagedNavigation: PagedNavigationViewModel
        @ObservedObject var state: StepState
        
        init(_ state: StepState) {
            self.state = state
        }
        
        var body: some View {
            stepView()
                .onAppear {
                    // Always hide the progress view
                    pagedNavigation.progressHidden = true
                }
        }
        
        @ViewBuilder
        private func stepView() -> some View {
            if let questionState = state as? QuestionState,
               questionState.step is ChoiceQuestionStep {
                ChoiceQuestionStepView(questionState)
            }
            else if let step = state.step as? CompletionStep {
                CompletionStepView(step)
                    .speakInstructions(step: step)
            }
            else if state.step is CountdownStep {
                CountdownStepView(state)
                    .surveyTintColor(.textForeground)
                    .backgroundLockOverride(isOn: state.step is BackgroundCountdownStepObject)
                    .speakInstructions(step: state.step)
            }
            else if state.step is OverviewStep {
                OverviewView(nodeState: state)
            }
            else if let nodeState = state as? MotorControlInstructionState {
                InstructionView(nodeState: nodeState)
                    .speakInstructions(step: state.step)
            }
            else if let nodeState = state as? TappingStepViewModel {
                TappingStepView(state: nodeState)
                    .appBackgroundListener(isOn: true)
            }
            else if let nodeState = state as? MotionSensorStepViewModel {
                MotionSensorStepView(state: nodeState)
                    .appBackgroundListener(isOn: !nodeState.motionConfig.allowScreenLock)
            }
            else {
                VStack {
                    Spacer()
                    Text(state.id)
                    Spacer()
                    SurveyNavigationView()
                }
            }
        }
    }
}

extension View {
    
    @ViewBuilder
    func appBackgroundListener(isOn: Bool) -> some View {
        if isOn {
            modifier(AppBackgroundListener())
        }
        else {
            self
        }
    }
    
    @ViewBuilder
    func backgroundLockOverride(isOn: Bool) -> some View {
        if isOn {
            modifier(BackgroundLockOverride())
        }
        else {
            self
        }
    }
    
    func speakInstructions(step: Step) -> some View {
        modifier(SpokenInstructionSynthesizer(step: step))
    }
}

struct SpokenInstructionSynthesizer : ViewModifier {
    let step: Step
    func body(content: Content) -> some View {
        content
            .onAppear {
                if let instruction = step.spokenInstruction(at: 0) {
                    TextToSpeechSynthesizer.shared.speak(text: instruction, completion: nil)
                }
            }
            .onDisappear {
                if let instruction = step.spokenInstruction(at: .infinity) {
                    TextToSpeechSynthesizer.shared.speak(text: instruction, completion: nil)
                }
            }
    }
}

struct BackgroundLockOverride : ViewModifier {
    let audioSessionIdentifier = "org.sagebase.BackgroundLockOverride.\(UUID())"
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                AudioSessionController.shared.startBackgroundAudioIfNeeded(on: audioSessionIdentifier)
            }
            .onDisappear {
                AudioSessionController.shared.stopAudioSession(on: audioSessionIdentifier)
            }
    }
}

struct AppBackgroundListener : ViewModifier {
    @EnvironmentObject var assessmentState: AssessmentState
    @State var didResignActive = false

    func body(content: Content) -> some View {
        content
        #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                assessmentState.status = .continueLater
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        #endif
    }
}

struct MotorControlAssessmentPreview : View {
    let assessmentState: AssessmentState
    
    init(_ identifier: MotorControlIdentifier) {
        assessmentState = try! identifier.instantiateAssessmentState()
    }
    
    var body: some View {
        MotorControlAssessmentView(assessmentState)
    }
}

struct MotorControlAssessmentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MotorControlAssessmentPreview(.tremor)
            MotorControlAssessmentPreview(.kineticTremor)
                .preferredColorScheme(.dark)
        }
    }
}

extension AssessmentObject {
    convenience init(previewStep: Step) {
        self.init(identifier: previewStep.identifier, children: [previewStep])
    }
}


enum ImagePlacement : String, Codable, CaseIterable {
    case topBackground
}

extension ImageInfo {
    var placement: ImagePlacement {
        (self as? ImagePlacementInfo)?.placementHint.flatMap { .init(rawValue: $0) } ?? .topBackground
    }
}
