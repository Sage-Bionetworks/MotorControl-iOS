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
import MotorControl
import SharedMobileUI
import SharedResources

struct MotionSensorStepView: View {
    @EnvironmentObject var assessmentState: AssessmentState
    @EnvironmentObject var pagedNavigation: PagedNavigationViewModel
    @ObservedObject var state: MotionSensorStepState
    @State var countdown: Int = 30
    @State var progress: CGFloat = .zero
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var instructionCache: [String] = []
    @StateObject var clock = SimpleClock.init()
    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    
    @ViewBuilder
    func content() -> some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .trim(from: 0.0, to: min(progress, 1.0))
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .foregroundColor(.textForeground)
                        .rotationEffect(Angle(degrees: 270.0))
                        .frame(width: geometry.size.width / 2, height: geometry.size.width / 2, alignment: .center)
                        .background {
                            Circle()
                                .fill(Color.screenBackground)
                                .frame(width: geometry.size.width / 2 + 5, height: geometry.size.width / 2 + 5, alignment: .center)
                        }
                        .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    VStack {
                        Text("\(countdown)")
                            .font(.countdown)
                            .foregroundColor(.textForeground)
                        Text(countdown == 1 ? "second" : "seconds", bundle: SharedResources.bundle)
                            .font(.textField)
                            .foregroundColor(.textForeground)
                    }
                }
            }
        }
        .background {
            surveyTint
            if let imageInfo = state.contentNode.imageInfo {
                Spacer()
                ContentImage(imageInfo)
                    .opacity(0.4)
                    .scaleEffect(1.5)
                    .rotation3DEffect(.degrees(state.flippedImage ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            }
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .safeAreaInset(edge: .top, alignment: .center) {
            VStack {
                StepHeaderView(state)
                if let title = state.title {
                    Text(title)
                        .font(.stepTitle)
                        .padding(spacing)
                        .foregroundColor(.textForeground)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    var body: some View {
        content()
            .onAppear {
                // Reset the countdown animation and start the recorder.
                resetCountdown()
                if let instruction = state.motionConfig.spokenInstruction(at: 0) {
                    state.voicePrompter.speak(text: instruction, completion: .none)
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
                guard !state.recorder.isPaused, countdown > 0 else { return }
                countdown = max(countdown - 1, 0)
                // Once the countdown hits zero, stop the recorder and *then* navigate forward.
                // TODO: syoung 09/13/2022 Decide if this is causing weird stalling and refactor if needed.
                if countdown == 0, state.recorder.status <= .running {
                    speak(at: state.motionConfig.duration, completion: finishStep)
                    timer.upstream.connect().cancel()
                }
                else {
                    speak(at: clock.runningDuration())
                }
            }
    }
    
    func speak(at timeInterval: TimeInterval, completion: (() -> Void)? = nil) {
        guard let instruction = state.motionConfig.spokenInstruction(at: timeInterval),
              !instructionCache.contains(instruction)
        else {
            completion?()
            return
        }
        instructionCache.append(instruction)
        state.voicePrompter.speak(text: instruction) { _, _ in
            completion?()
        }
    }
    
    func finishStep() {
        Task {
            do {
                state.result = try await state.recorder.stop()
            }
            catch {
                state.result = ErrorResultObject(identifier: state.node.identifier, error: error)
            }
        }
        pagedNavigation.goForward()
    }

    func resetCountdown() {
        let startDuration = state.motionConfig.duration
        clock.reset()
        countdown = Int(startDuration)
        instructionCache.removeAll()
        withAnimation(.linear(duration: startDuration)) {
            progress = 1.0
        }
    }
    
    func pauseCountdown() {
        state.recorder.pause()
        withAnimation(.linear(duration: 0)) {
            progress = 0
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
