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
    @State var countdown: Int = 30
    @State var progress: CGFloat = .zero
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject var clock = SimpleClock.init()
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
            insideCountdownDial(countdown)
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
                .background {
                    Circle()
                        .fill(Color.sageWhite)
                }
        }
    }

    @ViewBuilder
    fileprivate func insideView() -> some View {
        VStack {
            StepHeaderView(state)
            Spacer()
            countdownDial()
            
            Spacer()
        }
    }

    @ViewBuilder
    fileprivate func backgroundView() -> some View {
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
    fileprivate func content() -> some View {
        insideView()
            .background {
                backgroundView()
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
                // Go ahead and cancel the timer
                timer.upstream.connect().cancel()
            }
            .onChange(of: assessmentState.showingPauseActions) { newValue in
                if newValue {
                    // Pause the countdown animation
                    pauseCountdown()
                }
                else {
                    // Reset the countdown animation
                    resetCountdown()
                }
            }
            .onReceive(timer) { time in
                countdown = max(countdown - 1, 0)
                // Once the countdown hits zero navigate forward.
                if countdown == 0 {
                    state.audioFileSoundPlayer.vibrateDevice()
                    state.speak(at: state.motionConfig.duration) {
                        pagedNavigation.goForward()
                    }
                    timer.upstream.connect().cancel()
                }
                else {
                    state.speak(at: clock.runningDuration())
                }
            }
    }

    func resetCountdown() {
        let startDuration = state.motionConfig.duration
        clock.reset()
        countdown = Int(startDuration)
        state.resetInstructionCache()
        withAnimation(.linear(duration: startDuration)) {
            progress = 1.0
        }
    }

    func pauseCountdown() {
        withAnimation(.linear(duration: 0)) {
            progress = 0
        }
    }
}

struct PreviewTappingStepView : View {
    @StateObject var assessmentState: AssessmentState = .init(AssessmentObject(previewStep: example1))

    var body: some View {
        TappingStepView(state: .init(example1, assessmentState: assessmentState, branchState: assessmentState))
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

fileprivate let example1 = TremorNodeObject(identifier: "example", imageInfo: FetchableImage(imageName: "hold_phone_left", bundle: SharedResources.bundle))
