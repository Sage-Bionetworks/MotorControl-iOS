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

struct OverviewNodeView: View {

    let contentNodeState: ContentNodeState
    let alignment: Alignment
    @Namespace var subtitle
    
    public init(_ contentNodeState: ContentNodeState, alignment: Alignment = .center) {
        self.contentNodeState = contentNodeState
        self.alignment = alignment
    }
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            let spacing: CGFloat = 20
            let fontSize: CGFloat = 18
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: alignment.horizontal, spacing: spacing) {
                        if let imageInfo = contentNodeState.contentNode.imageInfo {
                            ContentImage(imageInfo)
                                .background(Color.teal.opacity(0.5))
                        }
                        Text(contentNodeState.contentNode.title ?? "")
                            .font(.largeTitle)
                            .foregroundColor(.textForeground)
                        if let subtitle = contentNodeState.contentNode.subtitle {
                            Text(subtitle)
                                .foregroundColor(.textForeground)
                                .font(.latoFont(fontSize))
                                .id(subtitle)
                                .onAppear{
                                    proxy.scrollTo(subtitle)
                                }
                        }
                        if let detail = contentNodeState.contentNode.detail {
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


struct OverviewNodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OverviewNodeView(exampleNodeState, alignment: .center)
                .ignoresSafeArea()
                .previewInterfaceOrientation(.portrait)
            OverviewNodeView(exampleNodeState, alignment: .center)
                .ignoresSafeArea()
        }
    }
}


fileprivate let exampleStep = OverviewStepObject(
    identifier: "overview",
    title: "Example Survey A",
    subtitle: "This is the subtitle",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "HoldPhone-Left", bundle: SharedResources.bundle, placementHint: "topBackground"))

fileprivate let exampleNodeState = ContentNodeState(step: exampleStep)
