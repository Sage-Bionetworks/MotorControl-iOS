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

public typealias RemainingDurationProvider<Value: VectorArithmetic> = (Value) -> TimeInterval
public typealias AnimationWithDurationProvider = (TimeInterval) -> Animation

public struct PausableAnimationModifier<Value: VectorArithmetic>: AnimatableModifier {
    @Binding var binding: Value
    @Binding var paused: Bool

    private let targetValue: Value
    private let remainingDuration: RemainingDurationProvider<Value>
    private let animation: AnimationWithDurationProvider
    
    public var animatableData: Value

    public init(binding: Binding<Value>,
                targetValue: Value,
                remainingDuration: @escaping RemainingDurationProvider<Value>,
                animation: @escaping AnimationWithDurationProvider,
                paused: Binding<Bool>) {
        _binding = binding
        self.targetValue = targetValue
        self.remainingDuration = remainingDuration
        self.animation = animation
        _paused = paused
        animatableData = binding.wrappedValue
    }

    public func body(content: Content) -> some View {
        content
            .onChange(of: paused) { isPaused in
                if isPaused {
                    withAnimation(.instant) {
                        binding = animatableData
                    }
                }
                else {
                    withAnimation(animation(remainingDuration(animatableData))) {
                        binding = targetValue
                    }
                }
            }
    }
}

public extension Animation {
    static let instant = Animation.linear(duration: .leastNonzeroMagnitude)
}
