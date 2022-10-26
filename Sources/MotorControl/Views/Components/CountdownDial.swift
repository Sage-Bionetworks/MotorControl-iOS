//
//  CountdownDial.swift
//  iosViewBuilder
//
//  Created by Shannon Young on 10/5/22.
//

import SwiftUI
import SharedMobileUI

struct CountdownDial: View {
    @Binding var progress: CGFloat
    @Binding var remainingDuration: CGFloat
    @Binding var paused: Bool
    @Binding var count: Int
    let maxCount: Int
    let label: Text
    
    var body: some View {
        ZStack(alignment: .center) {
            insideCountdownDial(count)
            insideCountdownDial(maxCount)
                .opacity(0)
        }
        .fixedSize(horizontal: true, vertical: true)
        .padding(48)
        .frame(minWidth: 260)
        .background (
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(.textForeground)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(2.5)
                .pausableAnimation(progress: $progress,
                                   paused: $paused,
                                   tapCount: $count,
                                   remainingDuration: $remainingDuration)
                .background (
                    Circle()
                        .fill(Color.sageWhite)
                )
        )
    }
    
    @ViewBuilder
    private func insideCountdownDial(_ count: Int) -> some View {
        VStack(spacing: 0) {
            Text("\(count)")
                .font(.countdownNumbers)
                .foregroundColor(.textForeground)
                .frame(maxWidth: .infinity, alignment: .center)
            label
                .font(.countdownDialText)
                .foregroundColor(.textForeground)
        }
    }
}


//
//struct CountdownDialView_Previews: PreviewProvider {
//    static var previews: some View {
//        CountdownDialView()
//    }
//}
