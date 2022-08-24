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
    @Namespace var subtitle
    
    public init(_ contentInfo: ContentNode, alignment: Alignment = .center) {
        self.contentInfo = contentInfo
        self.alignment = alignment
    }
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            let spacing: CGFloat = 20
            let fontSize: CGFloat = 18
            let backgroundColor: Color = Color.teal.opacity(0.5)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: alignment.horizontal, spacing: spacing) {
                        if let imageInfo = contentInfo.imageInfo {
                            ContentImage(imageInfo)
                                .background(backgroundColor)
                        }
                        Text(contentInfo.title ?? "")
                            .font(.largeTitle)
                            .foregroundColor(.textForeground)
                        if let subtitle = contentInfo.subtitle {
                            Text(subtitle)
                                .foregroundColor(.textForeground)
                                .font(.latoFont(fontSize))
                                .id(subtitle)
                                .onAppear{
                                    proxy.scrollTo(subtitle)
                                }
                        }
                        if let detail = contentInfo.detail {
                            Text(detail)
                                .foregroundColor(.textForeground)
                                .font(.latoFont(fontSize))
                        }
                    }
                    .padding([.horizontal], spacing)
                    .frame(maxWidth: scrollViewGeometry.size.width)
                }
            }
        }
    }
}


struct InstructionNodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstructionNodeView(exampleStep, alignment: .center)
                .ignoresSafeArea()
                .previewInterfaceOrientation(.portrait)
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
