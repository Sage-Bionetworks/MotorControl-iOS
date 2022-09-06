//
//  MotorControlAssessmentView.swift
//
//  Copyright © 2022 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import SwiftUI
import AssessmentModel
import AssessmentModelUI
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

    @SwiftUI.Environment(\.surveyTintColor) var surveyTint: Color
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    let bottomID = "bottom"
    let overview: OverviewStepObject
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .center, spacing: spacing) {
                        if let imageInfo = overview.imageInfo {
                            ContentImage(imageInfo)
                                .background(surveyTint)
                        }
                        if let title = overview.title {
                            Text(title)
                                .font(.stepTitle)
                                .foregroundColor(.textForeground)
                        }
                        if let subtitle = overview.subtitle {
                            Text(subtitle)
                                .font(.stepSubtitle)
                                .foregroundColor(.textForeground)
                                .multilineTextAlignment(.center)
                        }
                        if let detail = overview.detail {
                            Text(detail)
                                .font(.stepDetail)
                                .foregroundColor(.textForeground)
                                .multilineTextAlignment(.center)
                        }
                        if let icons = overview.icons {
                            Text("This is what you'll need")
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

extension OverviewIcon : Identifiable {
    public var id: String {
        icon
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

