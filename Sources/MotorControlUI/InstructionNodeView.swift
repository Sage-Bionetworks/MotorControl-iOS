//
//  InstructionNodeView.swift
//  iosViewBuilder
//
//  Created by Aaron Rabara on 8/22/22.
//

import SwiftUI
import AssessmentModel
import AssessmentModelUI
import SharedMobileUI

struct InstructionNodeView: View {

    let contentInfo: ContentNode
    let alignment: Alignment
    
    public init(_ contentInfo: ContentNode, alignment: Alignment = .center) {
        self.contentInfo = contentInfo
        self.alignment = alignment
    }
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            let bottomOffset = -scrollViewGeometry.size.height/12
            let spacing: CGFloat = 20
            ScrollView {
                VStack(alignment: alignment.horizontal, spacing: spacing) {
                    if let imageInfo = contentInfo.imageInfo, imageInfo.placement == .iconBefore {
                        ContentImage(imageInfo)
                        
                    }
                    Text(contentInfo.title ?? "")
                        .font(.largeTitle)
                        .foregroundColor(.textForeground)
                    if let subtitle = contentInfo.subtitle {
                        Text(subtitle)
                            .foregroundColor(.textForeground)

                    }
                    if let detail = contentInfo.detail {
                        Text(detail)
                            .foregroundColor(.textForeground)
                    }
                }
                .padding(spacing)
                .frame(maxWidth: scrollViewGeometry.size.width)
                .offset(y: bottomOffset)
            }
        }
    }
}

enum ImagePlacement : String, Codable, CaseIterable {
    case iconBefore, iconAfter
}

extension ImageInfo {
    var placement: ImagePlacement {
        (self as? ImagePlacementInfo)?.placementHint.flatMap { .init(rawValue: $0) } ?? .iconBefore
    }
}

struct InstructionNodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstructionNodeView(exampleStep, alignment: .leading)
                .padding(0.0)
            InstructionNodeView(exampleStep, alignment: .center)
        }
    }
}

fileprivate let exampleStep = OverviewStepObject(
    identifier: "overview",
    title: "Example Survey A",
    subtitle: "This is the subtitle",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: SageResourceImage(.default))
