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
                        if let title = overview.title {
                            Text(title)
                                .font(.largeTitle)
                        }
                        if let subtitle = overview.subtitle {
                            Text(subtitle)
                                .font(.latoFont(fontSize))
                                .multilineTextAlignment(.center)
                        }
                        if let detail = overview.detail {
                            Text(detail)
                                .font(.latoFont(fontSize))
                                .multilineTextAlignment(.center)
                        }
                        if let icons = overview.icons {
                            Text("This is what you'll need")
                                .bold()
                                .font(.latoFont(fontSize))
                            HStack(alignment: .center, spacing: spacing) {
                                ForEach(0..<icons.count, id: \.self) { ii in
                                    let imageInfo = FetchableImage(imageName: icons[ii].icon, bundle: SharedResources.bundle)
                                    VStack(alignment: .center, spacing: spacing) {
                                        ContentImage(imageInfo)
                                        Text(icons[ii].title)
                                            .font(.latoFont(fontSize - 2))
                                            .multilineTextAlignment(.center)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
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

fileprivate let icon1: OverviewIcon = .init(icon: "ComfortablePlaceToSit", title: "COMFORTABLE PLACE TO SIT")
fileprivate let icon2: OverviewIcon = .init(icon: "FlatSurface", title: "FLAT SURFACE")
fileprivate let icon3: OverviewIcon = .init(icon: "SpaceToMoveYourArms", title: "SPACE TO MOVE YOUR ARMS")


fileprivate let exampleStep = OverviewStepObject(
    identifier: "overview",
    title: "Example Survey A",
    subtitle: "This is the subtitle",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "HoldPhone-Left", bundle: SharedResources.bundle, placementHint: "topBackground"),
    icons: [ icon1, icon2, icon3 ]
)
