//
//  MCTTaskObject.swift
//  MotorControl
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

import Foundation
import JsonModel
import Research
import ResearchMotion
import ResearchUI

extension RSDTaskType {
    static let motorControlTask: RSDTaskType = "motorControlTask"
}

/// For the MotorControl tasks, the motion sensors are always required. Because of this, inherit from
/// `RSDMotionTaskObject` to use the custom audio session controller on that task.
public final class MCTTaskObject: RSDMotionTaskObject, RSDTaskDesign {
    public override class func defaultType() -> RSDTaskType {
        .motorControlTask
    }

    internal var runCount: Int = 1
    
    /// Override the task setup to allow setting the run count.
    override public func setupTask(with data: RSDTaskData?, for path: RSDTaskPathComponent) {
        guard let dictionary = data?.json as? [String : JsonSerializable] else { return }
        self.runCount = ((dictionary[RSDIdentifier.taskRunCount.stringValue] as? Int) ?? 0) + 1
    }

    /// Override the taskData builder to add the run count.
    override public func taskData(for taskResult: RSDTaskResult) -> RSDTaskData? {
        let builder = RSDDefaultScoreBuilder()
        var json: [String : JsonSerializable] =
            (builder.getScoringData(from: taskResult) as? [String : JsonSerializable])
                ?? [:]
        json[RSDIdentifier.taskRunCount.stringValue] = runCount
        return TaskData(identifier: self.identifier, timestampDate: taskResult.endDate, json: json)
    }
    
    struct TaskData : RSDTaskData {
        let identifier: String
        let timestampDate: Date?
        let json: JsonSerializable
    }
    
    public var designSystem: RSDDesignSystem {
        return MCTFactory.designSystem
    }
}
