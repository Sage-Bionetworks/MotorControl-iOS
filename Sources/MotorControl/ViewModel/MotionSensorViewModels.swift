//
//  MotionSensorViewModels.swift
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
import AssessmentModelUI
import AssessmentModel
import MobilePassiveData
import MotionSensor
import JsonModel

/// State object for motion sensor steps
class MotionSensorStepViewModel : AbstractMotionControlState {
    var motionConfig: MotionSensorNodeObject { node as! MotionSensorNodeObject }
    let audioFileSoundPlayer: AudioFileSoundPlayer = .init()
    let voicePrompter: TextToSpeechSynthesizer = .init()
    let spokenInstructions: [Int : String]
    var instructionCache: Set<Int> = []
    let recorder: MotionRecorder
    @Published var countdown: CGFloat
    @Published var progress: CGFloat = .zero
    
    init(_ motionConfig: MotionSensorNodeObject, assessmentState: AssessmentState, branchState: BranchState) {
        if assessmentState.outputDirectory == nil {
            assessmentState.outputDirectory = createOutputDirectory()
        }
        self.recorder = .init(configuration: motionConfig,
                              outputDirectory: assessmentState.outputDirectory!,
                              initialStepPath: "\(assessmentState.node.identifier)/\(branchState.node.identifier)",
                              sectionIdentifier: branchState.node.identifier)
        let whichHand = branchState.node.hand()
        let replacementString = whichHand?.handReplacementString() ?? "NULL"
        self.spokenInstructions = motionConfig.spokenInstructions?.mapValues { text in
            text.replacingOccurrences(of: formattedTextPlaceHolder, with: replacementString)
        } ?? [:]
        self.countdown = motionConfig.duration
        super.init(motionConfig, parentId: branchState.id, whichHand: whichHand)
    }
    
    func speak(at timeInterval: TimeInterval, completion: (() -> Void)? = nil) {
        let key = Int(min(timeInterval, motionConfig.duration))
        guard !instructionCache.contains(key), let instruction = spokenInstructions[key]
        else {
            completion?()
            return
        }
        instructionCache.insert(key)
        voicePrompter.speak(text: instruction) { _, _ in
            completion?()
        }
    }
    
    func resetInstructionCache() {
        instructionCache.removeAll()
    }
}

/// View model for a tremor step
final class TremorStepViewModel : MotionSensorStepViewModel {
}

/// View model for a tapping step
final class TappingStepViewModel : MotionSensorStepViewModel {

    weak var branchState: BranchState!
    var tappingResult : TappingResultObject {
        get { self.result as! TappingResultObject }
        set { self.result = newValue }
    }
    var previousButton: TappingButtonIdentifier? = nil
    @Published var tapCount: Int = 0 {
        didSet {
            tappingResult.tapCount = tapCount
        }
    }
    @Published var isPaused : Bool = false {
        didSet {
            guard recorder.status >= .starting else { return }
            if isPaused {
                recorder.pause()
            }
            else {
                recorder.resume()
            }
        }
    }
    var initialTapOccurred: Bool { recorder.status > .idle }
    
    override init(_ motionConfig: MotionSensorNodeObject, assessmentState: AssessmentState, branchState: BranchState) {
        super.init(motionConfig, assessmentState: assessmentState, branchState: branchState)
        self.branchState = branchState
        self.tappingResult.hand = whichHand
    }

    @MainActor
    func tappedScreen(currentButton: TappingButtonIdentifier,
                             location: CGPoint,
                             duration: TimeInterval) {
        guard recorder.clock.runningDuration() < motionConfig.duration, initialTapOccurred
        else {
            return
        }
        addTappingSample(currentButton: currentButton, location: location, duration: duration)
    }
    
    @MainActor
    func addTappingSample(currentButton: TappingButtonIdentifier,
                          location: CGPoint,
                          duration: TimeInterval) {
        let sample: TappingSample = .init(uptime: SystemClock.uptime() - duration,
                                          timestamp: max(recorder.clock.runningDuration() - duration, .zero),
                                          stepPath: recorder.currentStepPath,
                                          buttonIdentifier: currentButton,
                                          location: location,
                                          duration: duration)
        // Update the tap count if the button is *not* the "none" case and either the previous button is nil
        // or the previous button matches this button.
        tappingResult.samples.append(sample)
        
        guard currentButton != .none, previousButton != currentButton
        else {
            return
        }
        tapCount += 1
        previousButton = currentButton
    }
    
    func handleTimer(completion: @escaping () -> Void) {
        guard !isPaused, countdown > 0, initialTapOccurred else { return }
        countdown = max(countdown - 1, 0)
        // Once the countdown hits zero, stop the countdown and *then* navigate forward.
        if countdown == 0 {
            speak(at: motionConfig.duration) {
                Task {
                    await self.stop()
                    completion()
                }
            }
        }
    }
    
    func handleInitialTapOccurred() async throws {
        guard !initialTapOccurred else { return }
        do {
            try await recorder.start()
        }
        catch {
            result = ErrorResultObject(identifier: node.identifier, error: error)
            throw error
        }
    }
    
    func stop() async {
        do {
            let result = try await recorder.stop()
            branchState.branchNodeResult.asyncResults = [result]
        }
        catch {
            print("Failed to stop the motion recorder. \(error)")
        }
    }
}

fileprivate func createOutputDirectory() -> URL {
    URL(fileURLWithPath: UUID().uuidString, isDirectory: true, relativeTo: FileManager.default.temporaryDirectory)
}
