//
//  TwoHandAssessmentObject.swift
//  
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

import Foundation
import AssessmentModel
import JsonModel
import SharedResources

fileprivate let handSelectionIdentifier = "handSelection"

extension SerializableNodeType {
    static let twoHandAssessment: SerializableNodeType = "twoHandAssessment"
}

final class TwoHandAssessmentObject : AbstractAssessmentObject {
    override class func defaultType() -> SerializableNodeType {
        .twoHandAssessment
    }

    convenience init() {
        self.init(identifier: "example", children: [])
    }
    
    override func instantiateNavigator(state: NavigationState) throws -> Navigator {
        try TwoHandNavigator(identifier: identifier, nodes: children)
    }
}

final class TwoHandNavigator : Navigator {
    
    let identifier: String
    public let nodes: [Node]

    public init(identifier: String, nodes: [Node]) throws {
        guard Set(nodes.map { $0.identifier }).count == nodes.count else {
            throw TwoHandAssessmentError.identifiersNotUnique
        }
        guard let firstHandIndex = nodes.firstIndex(where: { HandSelection(rawValue: $0.identifier) != nil  })
        else {
            throw TwoHandAssessmentError.noHandFound
        }
        
        self.identifier = identifier
        let handOrder : [HandSelection] = arc4random_uniform(2) == 0 ? [.left, .right] : [.right, .left]
        var temporaryNodes = nodes
        if temporaryNodes[firstHandIndex].identifier == handOrder[1].rawValue {
            temporaryNodes.swapAt(firstHandIndex, firstHandIndex + 1)
        }
        self.nodes = temporaryNodes
    }
    
    func node(identifier: String) -> Node? {
        return nodes.first(where: {
            $0.identifier == identifier
        })
    }
    
    func firstNode() -> Node? {
        return nodes.first
    }
    
    func nodeAfter(currentNode: Node?, branchResult: BranchNodeResult) -> NavigationPoint {
        return .init(node: nextNode(identifier: currentNode?.identifier, handSelection: currentHandSelection(for: branchResult)), direction: .forward)
    }
    
    func nodeBefore(currentNode: Node?, branchResult: BranchNodeResult) -> NavigationPoint {
        return .init(node: previousNode(currentNode: currentNode), direction: .backward)
    }
    
    func hasNodeAfter(currentNode: Node, branchResult: BranchNodeResult) -> Bool {
        return nextNode(identifier: currentNode.identifier) != nil
    }
    
    func allowBackNavigation(currentNode: Node, branchResult: BranchNodeResult) -> Bool {
        return previousNode(currentNode: currentNode) != nil
    }
    
    func canPauseAssessment(currentNode: Node, branchResult: BranchNodeResult) -> Bool {
        return true
    }
    
    func progress(currentNode: Node, branchResult: BranchNodeResult) -> AssessmentModel.Progress? {
        return nil
    }
    
    func isCompleted(currentNode: Node, branchResult: BranchNodeResult) -> Bool {
        return isCompleted(currentNode: currentNode)
    }
    
    private func currentHandSelection(for branchResult: BranchNodeResult) -> HandSelection? {
        guard let answer = branchResult.findAnswer(with: handSelectionIdentifier),
              let jsonValue = answer.jsonValue,
              case .string(let rawValue) = jsonValue
        else {
            return nil
        }
        return .init(rawValue: rawValue)
    }
    
    private func isCompleted(currentNode: Node) -> Bool {
        return currentNode.identifier == nodes.last?.identifier && currentNode is CompletionStep
    }
    
    private func nextNode(identifier: String?, handSelection: HandSelection? = nil) -> Node? {
        guard let identifier = identifier
        else {
            return firstNode()
        }
        guard let index = nodes.firstIndex(where: {
            $0.identifier == identifier
        }), index + 1 < nodes.count
        else {
            return nil
        }
        let nextNode = nodes[index + 1]
        guard let selection = handSelection, let hand = nextNode.hand(), selection != hand
        else {
            return nextNode
        }
        guard index + 2 < nodes.count
        else {
            return nil
        }
        return nodes[index + 2]
    }
    
    private func previousNode(currentNode: Node?) -> Node? {
        guard let index = nodes.firstIndex(where: {
            $0.identifier == currentNode?.identifier
        }), index > 0, !isCompleted(currentNode: currentNode!), !(currentNode is BranchNode)
        else {
            return nil
        }
        return nodes[index - 1]
    }
}

enum TwoHandAssessmentError: Error {
    case identifiersNotUnique
    case noHandFound
}

public enum HandSelection: String, Codable, CaseIterable {
    case left, right
    
    func handReplacementString() -> String {
        SharedResources.bundle.localizedString(forKey: self.rawValue, value: self.rawValue, table: nil)
    }
}

extension Node {
    func hand() -> HandSelection? {
        .init(rawValue: identifier)
    }
}
