//
//  MotionSensorStepView.swift
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
import SharedMobileUI
import SharedResources

struct MotionSensorStepView: View {
    @EnvironmentObject var assessmentState: AssessmentState
    @EnvironmentObject var pagedNavigation: PagedNavigationViewModel
    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @ObservedObject var state: TremorStepViewModel
    
    var body: some View {
        content()
            .onAppear {
                // Reset the countdown animation and start the recorder.
                resetCountdown()
                state.audioFileSoundPlayer.vibrateDevice()
                state.speak(at: 0)
                Task {
                    do {
                        try await state.recorder.start()
                    }
                    catch {
                        state.result = ErrorResultObject(identifier: state.node.identifier, error: error)
                    }
                }
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
                    resetCountdown()
                }
            }
            .onReceive(timer) { time in
                guard !state.recorder.isPaused, state.countdown > 0 else { return }
                state.countdown = max(state.countdown - 1, 0)
                // Once the countdown hits zero, stop the recorder and *then* navigate forward.
                if state.countdown == 0, state.recorder.status <= .running {
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
                    state.speak(at: state.recorder.clock.runningDuration())
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
    private func insideCountdownDial(_ count: Int) -> some View {
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
    private func countdownDial() -> some View {
        ZStack {
            insideCountdownDial(Int(state.countdown))
            insideCountdownDial(30)
                .opacity(0)
        }
        .fixedSize(horizontal: true, vertical: true)
        .padding(48)
        .background (
            Circle()
                .trim(from: 0.0, to: min(state.progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(.textForeground)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(2.5)
                .background (
                    Circle()
                        .fill(Color.sageWhite)
                )
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
            countdownDial()
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
    
    func resetCountdown() {
        state.recorder.clock.reset()
        state.countdown = state.motionConfig.duration
        state.resetInstructionCache()
        withAnimation(.linear(duration: state.motionConfig.duration)) {
            state.progress = 1.0
        }
    }
    
    func pauseCountdown() {
        state.recorder.pause()
        withAnimation(.linear(duration: 0)) {
            state.progress = 0
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
