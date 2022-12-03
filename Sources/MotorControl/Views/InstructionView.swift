//
//  MotorControlAssessmentView.swift
//

import SwiftUI
import AssessmentModel
import AssessmentModelUI
import SharedMobileUI
import SharedResources

struct InstructionView: View {
    let nodeState: MotorControlInstructionState
    
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

struct InstructionNodeView: View {
    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    
    @ObservedObject var contentInfo: MotorControlInstructionState
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .center, spacing: spacing) {
                        if let imageInfo = contentInfo.contentNode.imageInfo {
                            ContentImage(imageInfo)
                                .background(surveyTint)
                                .rotation3DEffect(.degrees(contentInfo.flippedImage ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                        }
                        TextContent(title: contentInfo.title,
                                    subtitle: contentInfo.subtitle,
                                    detail: contentInfo.detail)
                    }
                    .frame(maxWidth: scrollViewGeometry.size.width)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstructionView(nodeState: MotorControlInstructionState(example1, parentId: nil))
                .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
                .environmentObject(AssessmentState(AssessmentObject(previewStep: example1)))
            InstructionView(nodeState: MotorControlInstructionState(example1, parentId: nil, whichHand: .right))
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
