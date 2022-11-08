//
//  TextContent.swift
//

import SwiftUI

struct TextContent : View {
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    
    let title: String?
    let subtitle: String?
    let detail: String?
    
    var body: some View {
        VStack(spacing: 16) {
            StyledText(title, .stepTitle)
            StyledText(subtitle, .stepSubtitle)
            StyledText(detail, .stepDetail)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func StyledText(_ str: String?, _ font: Font) -> some View {
        if let str = str {
            Text(str)
                .font(font)
                .foregroundColor(.textForeground)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        else {
            EmptyView()
        }
    }
}
