//
//  InstructionView.swift
//  iosViewBuilder
//
//  Created by Aaron Rabara on 8/19/22.
//

import SwiftUI
import AssessmentModel
import AssessmentModelUI
import JsonModel
import SharedMobileUI
import MotorControl
import SharedResources


struct InstructionView: View {
    @ObservedObject var nodeState: InstructionState
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                InstructionNodeView(contentInfo: nodeState)
                StepHeaderView(nodeState)
            }
            SurveyNavigationView()
        }
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstructionView(nodeState: InstructionState(example1, parentId: nil))
                .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
                .environmentObject(AssessmentState(AssessmentObject(previewStep: example1)))
        }
    }
}

fileprivate let example1 = InstructionStepObject(
    identifier: "example",
    title: "Example Survey A",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "tap_left_1", bundle: SharedResources.bundle, placementHint: "topBackground"))


struct InstructionNodeView: View {
    
    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color

    let contentInfo: InstructionState
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            let spacing: CGFloat = 20
            let fontSize: CGFloat = 18
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .center, spacing: spacing) {
                        if let image = contentInfo.image {
                            image.background(surveyTint)
                        }
                        if let title = contentInfo.title {
                            Text(title)
                                .font(.largeTitle)
                        }
                        if let subtitle = contentInfo.subtitle {
                            Text(subtitle)
                                .font(.latoFont(fontSize))
                        }
                        if let detail = contentInfo.detail {
                            Text(detail)
                                .font(.latoFont(fontSize))
                        }
                    }
                    .padding([.horizontal], spacing)
                    .frame(maxWidth: scrollViewGeometry.size.width)
                }
            }
        }
        .ignoresSafeArea(edges: [.top])
    }
}

//
//protocol InstructionViewState {
//    var image: Image? { get }
//    var title: String? { get }
//    var subtitle: String? { get }
//    var detail: String? { get }
//}
//
//extension InstructionState : InstructionViewState {
//
//}

//extension TwoHandInstructionState : InstructionViewState {
//
//}
