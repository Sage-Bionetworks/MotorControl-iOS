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
import SharedResources

struct InstructionNodeView: View {

    let contentInfo: ContentNode
    let alignment: Alignment
    
    public init(_ contentInfo: ContentNode, alignment: Alignment = .center) {
        self.contentInfo = contentInfo
        self.alignment = alignment
    }
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            let spacing: CGFloat = 20
            ScrollView {
                VStack(alignment: alignment.horizontal, spacing: spacing) {
                    if let imageInfo = contentInfo.imageInfo {
                        ContentImage(imageInfo)
                            .background(Color.teal.opacity(0.5))
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
                .padding([.horizontal], spacing)
                .frame(maxWidth: scrollViewGeometry.size.width)
            }
        }
    }
}


enum ImagePlacement : String, Codable, CaseIterable {
    case topBackground
}

extension ImageInfo {
    var placement: ImagePlacement {
        (self as? ImagePlacementInfo)?.placementHint.flatMap { .init(rawValue: $0) } ?? .topBackground
    }
}

struct InstructionNodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstructionNodeView(exampleStep, alignment: .leading)
                .ignoresSafeArea()
            InstructionNodeView(exampleStep, alignment: .center)
                .ignoresSafeArea()
        }
    }
}

fileprivate let exampleStep = InstructionStepObject(
    identifier: "overview",
    title: "Example Survey A",
    subtitle: "This is the subtitle",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "HoldPhone-Left", bundle: SharedResources.bundle, placementHint: "topBackground"))
