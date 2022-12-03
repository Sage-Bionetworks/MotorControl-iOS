//
//  MotorControlAssessmentView.swift
//

import SwiftUI
import AssessmentModel
import AssessmentModelUI
import SharedMobileUI
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

struct OverviewNodeView: View {
    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    
    let bottomID = "bottom"
    let overview: OverviewStepObject
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .center) {
                        if let imageInfo = overview.imageInfo {
                            ContentImage(imageInfo)
                                .background(surveyTint)
                        }
                        TextContent(title: overview.title,
                                    subtitle: overview.subtitle,
                                    detail: overview.detail)
                        iconsView()
                            .padding()
                    }
                    .id(bottomID)
                    .onAppear {
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
                    .frame(maxWidth: scrollViewGeometry.size.width)
                }
            }
        }
        .ignoresSafeArea(edges: [.top])
    }
    
    @ViewBuilder
    private func iconsView() -> some View {
        if let icons = overview.icons {
            Text("This is what you'll need", bundle: SharedResources.bundle)
                .font(.stepIconHeader)
                .foregroundColor(.textForeground)
            HStack(alignment: .top, spacing: spacing) {
                ForEach(icons) { iconInfo in
                    VStack(alignment: .center, spacing: spacing) {
                        Image(iconInfo.icon, bundle: SharedResources.bundle)
                        Text(iconInfo.title)
                            .font(.stepIconText)
                            .foregroundColor(.textForeground)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

extension OverviewIcon : Identifiable {
    public var id: String {
        icon
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

fileprivate let icon1: OverviewIcon = .init(icon: "comfortable_place_to_sit", title: "COMFORTABLE PLACE TO SIT")
fileprivate let icon2: OverviewIcon = .init(icon: "flat_surface", title: "FLAT SURFACE")
fileprivate let icon3: OverviewIcon = .init(icon: "space_to_move_your_arms", title: "SPACE TO MOVE YOUR ARMS")

fileprivate let exampleStep = OverviewStepObject(
    identifier: "overview",
    title: "Example Survey A",
    subtitle: "This is the subtitle",
    detail: "You will be shown a series of example questions. This survey has no additional instructions.",
    imageInfo: FetchableImage(imageName: "hold_phone_left", bundle: SharedResources.bundle, placementHint: "topBackground"),
    icons: [ icon1, icon2, icon3 ]
)
