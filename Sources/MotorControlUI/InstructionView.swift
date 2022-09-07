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


struct InstructionView: View {
    let nodeState: InstructionState
    
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
    @SwiftUI.Environment(\.spacing) var spacing: CGFloat
    @ObservedObject var contentInfo: InstructionState
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .center, spacing: spacing) {
                        if let imageInfo = contentInfo.contentNode.imageInfo {
                            ContentImage(imageInfo)
                                .background(surveyTint)
                        }
                        if let title = contentInfo.title {
                            Text(title)
                                .font(.stepTitle)
                        }
                        if let subtitle = contentInfo.subtitle {
                            Text(subtitle)
                                .font(.stepSubtitle)
                                .multilineTextAlignment(.center)
                        }
                        if let detail = contentInfo.detail {
                            Text(detail)
                                .font(.stepDetail)
                                .multilineTextAlignment(.center)
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
