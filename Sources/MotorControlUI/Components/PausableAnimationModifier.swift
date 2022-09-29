//
//  StoppableAnimationModifier.swift
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

///Modified from: https://swiftuirecipes.com/blog/pause-and-resume-animation-in-swiftui

public typealias AnimationWithDurationProvider = (TimeInterval) -> Animation

public struct PausableAnimationModifier: AnimatableModifier {
    @Binding var progress: CGFloat
    @Binding var paused: Bool
    @Binding var remainingDuration: CGFloat
    private let totalProgress: CGFloat
    private let animation: AnimationWithDurationProvider
    public var animatableData: CGFloat

    public init(progress: Binding<CGFloat>,
                paused: Binding<Bool>,
                remainingDuration: Binding<CGFloat>,
                totalProgress: CGFloat,
                animation: @escaping AnimationWithDurationProvider
                ) {
        _progress = progress
        _paused = paused
        _remainingDuration = remainingDuration
        
        self.totalProgress = totalProgress
        self.animation = animation
        animatableData = progress.wrappedValue
    }

    public func body(content: Content) -> some View {
        content
            .onChange(of: paused) { isPaused in
                if isPaused {
                    withAnimation(.instant) {
                        progress = animatableData
                    }
                }
                else {
                    withAnimation(animation(remainingDuration)) {
                        progress = totalProgress
                    }
                }
            }
    }
}

public extension Animation {
    static let instant = Animation.linear(duration: .leastNonzeroMagnitude)
}

extension View {
    public func pausableAnimation(progress: Binding<CGFloat>,
                                  paused: Binding<Bool>,
                                  remainingDuration: Binding<CGFloat>,
                                  totalProgress: CGFloat = 1.0,
                                  animation: @escaping AnimationWithDurationProvider = { .linear(duration: $0) }) -> some View {
    self.modifier(PausableAnimationModifier(progress: progress,
                                            paused: paused,
                                            remainingDuration: remainingDuration,
                                            totalProgress: totalProgress,
                                            animation: animation))
  }
}
