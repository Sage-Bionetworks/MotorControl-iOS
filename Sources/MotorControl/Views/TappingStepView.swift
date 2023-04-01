//
//  TappingStepView.swift
//

import SwiftUI
import AssessmentModel
import AssessmentModelUI
import JsonModel
import MotionSensor
import MobilePassiveData
import SharedMobileUI
import SharedResources

struct TappingStepView: View {
    @EnvironmentObject var assessmentState: AssessmentState
    @EnvironmentObject var pagedNavigation: PagedNavigationViewModel
    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var progress: CGFloat = .zero
    
    @ObservedObject var state: TappingStepViewModel
    
    var body: some View {
        content()
            .onAppear {
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
                state.isPaused = newValue
            }
            .onReceive(timer) { _ in
                guard let response = state.updateCountdown(), response.isFinished else { return }
                // Clean up when finished and then go forward
                timer.upstream.connect().cancel()
                Task {
                    await state.stop()
                    pagedNavigation.goForward()
                }
            }
    }
    
    @ViewBuilder
    private func content() -> some View {
        GeometryReader { geometry in
            insideView()
                .background (
                    backgroundView()
                )
                .coordinateSpace(name: TappingButtonIdentifier.none.rawValue)
                .onFingerPressedGesture { location, tapDuration in
                    state.tappedScreen(currentButton: .none,
                                       location: location,
                                       duration: tapDuration)
                }
        }
    }
    
    @ViewBuilder
    private func singleTappingButton(target: TappingButtonIdentifier) -> some View {
        Text("Tap", bundle: SharedResources.bundle)
            .accessibilityLabel("\(target.rawValue.uppercased())_TAP")
            .frame(width: 100, height: 100)
            .foregroundColor(Color.textForeground)
            .background(surveyTint.saturation(2))
            .clipShape(Circle())
            .onFingerPressedGesture { startLocation, tapDuration in
                state.tappedScreen(currentButton: target,
                                   location: startLocation,
                                   duration: tapDuration)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !state.initialTapOccurred else { return }
                        state.startRecorder()
                        withAnimation(.linear(duration: state.motionConfig.duration)) {
                            progress = 1.0
                        }
                    }
            )
    }
    
    @ViewBuilder
    private func tappingButtons() -> some View {
        HStack {
            Spacer()
            singleTappingButton(target: .left)
            Spacer()
            singleTappingButton(target: .right)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func insideView() -> some View {
        VStack {
            StepHeaderView(state)
            Spacer()
            CountdownDial(progress: $progress,
                          remainingDuration: $state.countdown,
                          paused: $state.isPaused,
                          count: $state.tapCount,
                          animationCanStart: state.initialTapOccurred,
                          maxCount: 999,
                          label: Text("Tap count", bundle: SharedResources.bundle))
            Spacer()
            tappingButtons()
                .padding(.bottom, 48)
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
