//
//  MotorControlAssessmentView.swift
//

import SwiftUI
import SharedMobileUI

let bodyFontSize: CGFloat = 20
let titleFontSize: CGFloat = 34
let stepIconFontSize: CGFloat = 18
let countdownSize: CGFloat = 64

extension Font {
    static let stepTitle: Font = .latoFont(titleFontSize, relativeTo: .title)
    static let stepSubtitle: Font = .latoFont(bodyFontSize, relativeTo: .body)
    static let stepDetail: Font = .latoFont(bodyFontSize, relativeTo: .body)
    static let stepIconHeader: Font = .latoFont(bodyFontSize, weight: .bold)
    static let stepIconText: Font = .latoFont(stepIconFontSize)
    static let activeViewTitle: Font = .latoFont(fixedSize: titleFontSize)
    static let countdownNumbers: Font = .latoFont(fixedSize: countdownSize)
    static let countdownDialText: Font = .latoFont(fixedSize: bodyFontSize)
}

struct SpacingEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGFloat = 20
}

extension EnvironmentValues {
    var spacing: CGFloat {
        get { self[SpacingEnvironmentKey.self] }
        set { self[SpacingEnvironmentKey.self] = newValue }
    }
}

extension View {
    func spacing(_ newValue: CGFloat) -> some View {
        environment(\.spacing, newValue)
    }
}
