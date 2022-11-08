//
//  StoppableAnimationModifier.swift
//

import SwiftUI

///Modified from: https://swiftuirecipes.com/blog/pause-and-resume-animation-in-swiftui

public typealias AnimationWithDurationProvider = (TimeInterval) -> Animation

struct PausableAnimationModifier: AnimatableModifier {
    @Binding var progress: CGFloat
    @Binding var paused: Bool
    @Binding var remainingDuration: CGFloat
    private let animationCanStart: Bool
    private let totalProgress: CGFloat
    private let animation: AnimationWithDurationProvider
    public var animatableData: CGFloat

    public init(progress: Binding<CGFloat>,
                paused: Binding<Bool>,
                remainingDuration: Binding<CGFloat>,
                animationCanStart: Bool,
                totalProgress: CGFloat,
                animation: @escaping AnimationWithDurationProvider
                ) {
        _progress = progress
        _paused = paused
        _remainingDuration = remainingDuration
        
        self.animationCanStart = animationCanStart
        self.totalProgress = totalProgress
        self.animation = animation
        animatableData = progress.wrappedValue
    }

    public func body(content: Content) -> some View {
        content
            .onChange(of: paused) { isPaused in
                guard animationCanStart else { return }
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
                                  animationCanStart: Bool,
                                  totalProgress: CGFloat = 1.0,
                                  animation: @escaping AnimationWithDurationProvider = { .linear(duration: $0) }) -> some View {
    self.modifier(PausableAnimationModifier(progress: progress,
                                            paused: paused,
                                            remainingDuration: remainingDuration,
                                            animationCanStart: animationCanStart,
                                            totalProgress: totalProgress,
                                            animation: animation))
  }
}
