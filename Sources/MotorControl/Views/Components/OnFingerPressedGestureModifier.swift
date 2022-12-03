//
//  OnFingerPressedGestureModifier.swift
//

import SwiftUI
import MobilePassiveData

struct OnFingerPressedGestureModifier: ViewModifier {
    @State private var fingerDown = false
    @State private var startLocation: CGPoint = .zero
    @StateObject var clock = SimpleClock.init()
    let callback: (CGPoint, CGFloat) -> Void
    let coordinateSpace: CoordinateSpace

    func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace)
                .onChanged { value in
                    guard !fingerDown else { return }
                    self.fingerDown = true
                    clock.reset()
                    startLocation = value.startLocation
                }
                .onEnded { value in
                    self.fingerDown = false
                    self.callback(startLocation, clock.runningDuration())
                })
            .onDisappear {
                clock.stop()
            }
    }
}

extension View {
    func onFingerPressedGesture(callback: @escaping (CGPoint, CGFloat) -> Void) -> some View {
        modifier(OnFingerPressedGestureModifier(callback: callback, coordinateSpace: .named(TappingButtonIdentifier.none.rawValue)))
    }
}
