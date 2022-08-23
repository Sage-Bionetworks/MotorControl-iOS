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


public struct InstructionView: View {
    @ObservedObject var nodeState: ContentNodeState
    let alignment: Alignment
    
    public init(_ nodeState: ContentNodeState, alignment: Alignment = .center) {
        self.nodeState = nodeState
        self.alignment = alignment
    }
    
    public var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                InstructionNodeView(nodeState.contentNode, alignment: alignment)
                StepHeaderView(nodeState)
            }
            SurveyNavigationView()
        }
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstructionView(InstructionState(example2, parentId: nil))
                .padding()
                .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
                .environmentObject(AssessmentState(AssessmentObject(previewStep: example2)))
            InstructionView(InstructionState(example1, parentId: nil), alignment: .center)
                .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
                .environmentObject(AssessmentState(AssessmentObject(previewStep: example1)))
        }
    }
}

fileprivate let example1 = InstructionStepObject(
    identifier: "example",
    title: "Example Survey A",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: SageResourceImage(.default))

fileprivate let example2 = InstructionStepObject(
    identifier: "example",
    title: "Example Survey A",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "survey.1", bundle: Bundle.module, placementHint: "iconAfter"))
