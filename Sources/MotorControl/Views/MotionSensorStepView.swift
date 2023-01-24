//
//  MotionSensorStepView.swift
//

import SwiftUI
import AssessmentModel
import AssessmentModelUI
import JsonModel
import MotionSensor
import MobilePassiveData
import SharedMobileUI
import SharedResources

struct MotionSensorStepView: View {
    @EnvironmentObject var assessmentState: AssessmentState
    @EnvironmentObject var pagedNavigation: PagedNavigationViewModel
    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var progress: CGFloat = 0
    let audioFileSoundPlayer: AudioFileSoundPlayer = .init()
    
    @ObservedObject var state: MotionSensorStepViewModel
    
    var body: some View {
        content()
            .onAppear {
                // For a tremor step, the countdown should start automatically
                // when the view appears.
                state.resetCountdown()
                restartDial()
                audioFileSoundPlayer.vibrateDevice()
                state.speak(at: 0)
                state.startRecorder()
            }
            .onDisappear {
                // If the recorder isn't stopping and the view disappears, it's b/c the recorder is cancelled.
                // Go ahead and cancel the timer and the recorder.
                if state.recorder.status <= .running {
                    timer.upstream.connect().cancel()
                    state.recorder.cancel()
                }
            }
            .onChange(of: assessmentState.showingPauseActions) { newValue in
                guard state.isPaused != newValue else { return }
                state.isPaused = newValue
                if !newValue {
                    // Resume the recoder and reset the countdown animation
                    state.resetCountdown()
                    restartDial()
                }
            }
            .onReceive(timer) { _ in
                guard let response = state.updateCountdown() else { return }
                if response.isFinished {
                    // Clean up when finished and then go forward
                    audioFileSoundPlayer.vibrateDevice()
                    timer.upstream.connect().cancel()
                    Task {
                        await state.stop()
                        pagedNavigation.goForward()
                    }
                }
                else {
                    // Otherwise, just speak the instruction at the current time mark
                    state.speak(at: response.currentTime)
                }
            }
    }
    
    @ViewBuilder
    func content() -> some View {
        insideView()
            .background (
                backgroundView()
            )
    }
    
    @ViewBuilder
    private func insideView() -> some View {
        VStack {
            StepHeaderView(state)
            if let title = state.title {
                Text(title)
                    .font(.activeViewTitle)
                    .padding(spacing)
                    .foregroundColor(.textForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            CountdownDial(progress: $progress,
                          remainingDuration: $state.countdown,
                          paused: $state.isPaused,
                          count: $state.secondCount,
                          animationCanStart: true,
                          maxCount: Int(state.motionConfig.duration),
                          label: Text("seconds", bundle: SharedResources.bundle))
            Spacer()
        }
    }
    
    @ViewBuilder
    private func backgroundView() -> some View {
        ZStack {
            surveyTint
            if let image = state.contentNode.imageInfo?.imageName {
                Image(image, bundle: SharedResources.bundle)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.4)
                    .rotation3DEffect(.degrees(state.flippedImage ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func restartDial() {
        progress = 0
        withAnimation(.linear(duration: state.countdown)) {
            progress = 1.0
        }
    }
}

struct PreviewMotionSensorStepView : View {
    @StateObject var assessmentState: AssessmentState = .init(AssessmentObject(previewStep: example1))
    
    var body: some View {
        MotionSensorStepView(state: .init(example1, assessmentState: assessmentState, branchState: assessmentState))
            .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
            .environmentObject(assessmentState)
    }
}

struct MotionSensorStepView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewMotionSensorStepView()
        }
    }
}

fileprivate let example1 = TremorNodeObject(identifier: "example", title: "Here's some text that tells you to do something", imageInfo: FetchableImage(imageName: "hold_phone_left", bundle: SharedResources.bundle))
