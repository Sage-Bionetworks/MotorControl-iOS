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


struct OverviewView: View {
    @ObservedObject var nodeState: StepState
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                OverviewNodeView(overview: nodeState.step as! OverviewStepObject)
                StepHeaderView(nodeState)
            }
            SurveyNavigationView()
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OverviewView(nodeState: ContentNodeState(step: exampleStep, parentId: nil))
                .environmentObject(PagedNavigationViewModel(pageCount: 5, currentIndex: 0))
                .environmentObject(AssessmentState(AssessmentObject(previewStep: exampleStep)))
        }
    }
}

struct OverviewNodeView: View {

    let overview: OverviewStepObject
    let bottomID = "bottom"
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            let spacing: CGFloat = 20
            let fontSize: CGFloat = 18
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .center, spacing: spacing) {
                        if let imageInfo = overview.imageInfo {
                            ContentImage(imageInfo)
                                .background(Color.teal.opacity(0.5))
                        }
                        Text(overview.title ?? "")
                            .font(.largeTitle)
                            .foregroundColor(.textForeground)
                        if let subtitle = overview.subtitle {
                            Text(subtitle)
                                .foregroundColor(.textForeground)
                                .font(.latoFont(fontSize))
                        }
                        if let detail = overview.detail {
                            Text(detail)
                                .foregroundColor(.textForeground)
                                .font(.latoFont(fontSize))
                        }
                        
                        
                        
                    }
                    .id(bottomID)
                    .onAppear{
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
                    .padding([.horizontal], spacing)
                    .frame(maxWidth: scrollViewGeometry.size.width)
                }
            }
        }
        .ignoresSafeArea(edges: [.top])
    }
}


fileprivate let exampleStep = OverviewStepObject(
    identifier: "overview",
    title: "Example Survey A",
    subtitle: "This is the subtitle",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "HoldPhone-Left", bundle: SharedResources.bundle, placementHint: "topBackground"),
    icons: [ .init(icon: "ComfortablePlaceToSit", title: "COMFORTABLE PLACE TO SIT")
      ]
)
