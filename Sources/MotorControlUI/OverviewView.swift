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


public struct OverviewView: View {
    @ObservedObject var nodeState: ContentNodeState
    let alignment: Alignment
    
    public init(_ nodeState: ContentNodeState, alignment: Alignment = .center) {
        self.nodeState = nodeState
        self.alignment = alignment
    }
    
    public var body: some View {
        VStack {
            ZStack(alignment: .top) {
                OverviewNodeView(nodeState, alignment: alignment)
                    .ignoresSafeArea(edges: [.top])
                StepHeaderView(nodeState)
            }
            SurveyNavigationView()
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OverviewView(ContentNodeState(step: example2, parentId: nil))
                .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
                .environmentObject(AssessmentState(AssessmentObject(previewStep: example2)))
            OverviewView(ContentNodeState(step: example1, parentId: nil), alignment: .center)
                .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
                .environmentObject(AssessmentState(AssessmentObject(previewStep: example1)))
        }
    }
}

fileprivate let example1 = OverviewStepObject(
    identifier: "example",
    title: "Example Survey A",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "TapLeft1", bundle: SharedResources.bundle, placementHint: "topBackground"))

fileprivate let example2 = OverviewStepObject(
    identifier: "example",
    title: "Example Survey A",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "HoldPhone-Left", bundle: SharedResources.bundle, placementHint: "topBackground"))
