//
//  TappingStepView.swift
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

import SwiftUI
import AssessmentModel
import AssessmentModelUI
import JsonModel
import MotionSensor
import MobilePassiveData
import MotorControl
import SharedMobileUI
import SharedResources

struct TappingStepView: View {
    @EnvironmentObject var assessmentState: AssessmentState
    @EnvironmentObject var pagedNavigation: PagedNavigationViewModel
    @ObservedObject var state: TappingStepViewModel
    @State var countdown : Double = 30
    @State var progress : CGFloat = .zero
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isPaused : Bool = false
    @State var initialTap = false
    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat

    @ViewBuilder
    fileprivate func insideCountdownDial(_ count: Int) -> some View {
        VStack {
            Text("\(count)")
                .font(.countdownNumbers)
                .foregroundColor(.textForeground)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("seconds", bundle: SharedResources.bundle)
                .font(.countdownDialText)
                .foregroundColor(.textForeground)
        }
    }
    
    @ViewBuilder
    fileprivate func countdownDial() -> some View {
        ZStack {
            insideCountdownDial(Int(countdown))
            insideCountdownDial(30)
                .opacity(0)
        }
        .fixedSize(horizontal: true, vertical: true)
        .padding(48)
        .background {
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(.textForeground)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(2.5)
                .pausableAnimation(progress: $progress,
                                   paused: $isPaused,
                                   remainingDuration: $countdown)
                .background {
                    Circle()
                        .fill(Color.sageWhite)
                }
        }
    }
    
    @ViewBuilder
    fileprivate func singleTappingButton(target: TappingButtonIdentifier) -> some View {
        Text("Tap", bundle: SharedResources.bundle)
            .frame(width: 100, height: 100)
            .foregroundColor(Color.textForeground)
            .background(surveyTint.saturation(2))
            .clipShape(Circle())
            .onFingerPressedGesture { startLocation, tapDuration in
                guard state.recorder.clock.runningDuration() < state.motionConfig.duration else { return }
                state.tappedScreen(uptime: SystemClock.uptime(),
                                   timestamp: state.recorder.clock.runningDuration(),
                                   currentButton: target, location: startLocation,
                                   duration: tapDuration)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { touch in
                        guard !initialTap, state.tapCount == 0 else { return }
                        initialTap = true
                        state.recorder.clock.reset()
                        withAnimation(.linear(duration: state.motionConfig.duration)) {
                            progress = 1.0
                        }
                        Task {
                            do {
                                try await state.recorder.start()
                            }
                            catch {
                                state.result = ErrorResultObject(identifier: state.node.identifier, error: error)
                            }
                        }
                    }
            )
    }
    
    @ViewBuilder
    fileprivate func tappingButtons() -> some View {
        HStack {
            Spacer()
            singleTappingButton(target: .left)
            Spacer()
            singleTappingButton(target: .right)
            Spacer()
        }
    }
    
    @ViewBuilder
    fileprivate func insideView() -> some View {
        VStack {
            StepHeaderView(state)
            Spacer()
            countdownDial()
            Spacer()
            Text("\(state.tapCount)", bundle: SharedResources.bundle)
                .foregroundColor(.textForeground)
                .font(.countdownNumbers)
            tappingButtons()
        }
    }
    
    @ViewBuilder
    func backgroundView() -> some View {
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
    
    @ViewBuilder
    func content() -> some View {
        GeometryReader { geometry in
            insideView()
                .background {
                    backgroundView()
                }
                .coordinateSpace(name: TappingButtonIdentifier.none.rawValue)
                .onFingerPressedGesture { location, tapDuration in
                    guard initialTap else { return }
                    state.tappedScreen(uptime: SystemClock.uptime(),
                                       timestamp: state.recorder.clock.runningDuration(),
                                       currentButton: .none,
                                       location: location,
                                       duration: tapDuration)
                }
        }
    }
    
    var body: some View {
        content()
            .onAppear {
                // Reset the countdown animation.
                resetCountdown()
                state.audioFileSoundPlayer.vibrateDevice()
                state.speak(at: 0)
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
                guard state.recorder.isPaused != newValue else { return }
                if newValue {
                    // Pause the recorder and countdown animation
                    state.recorder.pause()
                    pauseCountdown()
                }
                else {
                    // Resume the recoder and reset the countdown animation
                    state.recorder.resume()
                    resumeCountdown()
                }
            }
            .onReceive(timer) { _ in
                guard !state.recorder.isPaused, countdown > 0, initialTap else { return }
                countdown = max(countdown - 1, 0)
                // Once the countdown hits zero, stop the countdown and *then* navigate forward.
                if countdown == 0 {
                    state.audioFileSoundPlayer.vibrateDevice()
                    state.speak(at: state.motionConfig.duration) {
                        Task {
                            do {
                                state.result = try await state.recorder.stop()
                            }
                            catch {
                                state.result = ErrorResultObject(identifier: state.node.identifier, error: error)
                            }
                            pagedNavigation.goForward()
                        }
                    }
                    timer.upstream.connect().cancel()
                }
                else {
                    guard state.recorder.clock.runningDuration() == state.motionConfig.duration else { return }
                    state.speak(at: state.recorder.clock.runningDuration())
                }
            }
    }

    private func resetCountdown() {
        state.recorder.clock.reset()
        countdown = state.motionConfig.duration
        state.resetInstructionCache()
    }

    private func pauseCountdown() {
        state.recorder.clock.pause()
        state.recorder.pause()
        toggleAnimation()
    }

    private func resumeCountdown() {
        state.recorder.clock.resume()
        toggleAnimation()
    }
    
    private func toggleAnimation() {
        if initialTap {
            isPaused = !isPaused
        }
    }
}

struct PreviewTappingStepView : View {
    @StateObject var assessmentState: AssessmentState = .init(AssessmentObject(previewStep: tappingExample))
    
    var body: some View {
        TappingStepView(state: .init(tappingExample, assessmentState: assessmentState, branchState: assessmentState))
            .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
            .environmentObject(assessmentState)
    }
}

struct TappingStepView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewTappingStepView()
        }
    }
}

fileprivate let tappingExample = TappingNodeObject(identifier: "tappingExample", imageInfo: FetchableImage(imageName: "tap_left_1", bundle: SharedResources.bundle))


extension View {
    func onFingerPressedGesture(callback: @escaping (CGPoint, Double) -> Void) -> some View {
        modifier(OnFingerPressedGestureModifier(callback: callback, coordinateSpace: .named(TappingButtonIdentifier.none.rawValue)))
    }
}
