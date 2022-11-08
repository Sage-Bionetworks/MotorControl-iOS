//
//  MCTHandSelectionStepOjbect.swift
//  MotorControl
//

import Foundation
import JsonModel
import Research

/// A Subclass of RSDFormUIStepObject which uses MCTHandSelectionDataSource.
public class MCTHandSelectionStepObject : RSDUIStepObject, ChoiceQuestion, Question, Encodable {
    public override class func defaultType() -> RSDStepType {
        .handSelection
    }

    public var baseType: JsonType { .string }
    public var inputUIHint: RSDFormUIHint { .list }
    public var isOptional: Bool { false }
    public var isSingleAnswer: Bool { true }
    
    lazy public var jsonChoices: [JsonChoice] = {
        MCTHandSelection.allCases.map {
            JsonChoiceObject(matchingValue: .string($0.rawValue),
                             text: Localization.localizedString("HAND_SELECTION_CHOICE_\($0.rawValue.uppercased())"))
        }
    }()

    override public func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)

        // Set up the title if not defined.
        if self.title == nil && self.subtitle == nil {
            self.title = Localization.localizedString("HAND_SELECTION_TITLE")
        }
    }
    
    public override func instantiateStepResult() -> ResultData {
        CollectionResultObject(identifier: self.identifier)
    }
    
    public func instantiateAnswerResult() -> AnswerResult {
        AnswerResultObject(identifier: MCTHandSelectionDataSource.selectionKey, answerType: self.answerType)
    }
    
    override public func instantiateDataSource(with parent: RSDPathComponent?, for supportedHints: Set<RSDFormUIHint>) -> RSDTableDataSource? {
        return MCTHandSelectionDataSource(step: self, parent: parent)
    }
}

/// An enum that represents the choices the user has for which hands they can use.
public enum MCTHandSelection : String, Codable, CaseIterable {
    case left, right, both
    
    public var otherHand: MCTHandSelection? {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        default:
            return nil
        }
    }
}

/// The object that serves as the data soruce for an MCTHandSelectionStep
public class MCTHandSelectionDataSource : RSDStepViewModel, RSDTableDataSource {
    
    /// Key for the randomized hand order in the task result.
    public static let handOrderKey = "handOrder"
    
    /// Key for which hands the user said they could use in the task result.
    public static let selectionKey = "handSelection"
    
    public weak var delegate: RSDTableDataSourceDelegate?
    
    public let sections: [RSDTableSection]
    public let itemGroup: QuestionTableItemGroup
    
    private let handSelectionResult: AnswerResult
    private let handOrderResult: AnswerResult
    
    public init(step: MCTHandSelectionStepObject, parent: RSDPathComponent?) {
        
        let previousValue: JsonElement? = {
            guard let taskVM = parent as? RSDTaskViewModel else { return nil }
            if let previousResult = taskVM.previousResult(for: step) as? CollectionResult,
                let answerResult = previousResult.findAnswer(with: MCTHandSelectionDataSource.selectionKey) {
                return answerResult.jsonValue
            }
            guard let dataManager = taskVM.dataManager,
                (dataManager.shouldUsePreviousAnswers?(for: taskVM.identifier) ?? false),
                let dictionary = taskVM.previousTaskData?.json as? [String : JsonSerializable],
                let value = dictionary[MCTHandSelectionDataSource.selectionKey] as? JsonValue
                else {
                    return nil
            }
            return JsonElement(value)
        }()

        let idx = 0
        let itemGroup = QuestionTableItemGroup(beginningRowIndex: idx,
                                               question: step,
                                               supportedHints: nil,
                                               initialValue: previousValue)
        var sections = [RSDTableSection(identifier: step.identifier, sectionIndex: idx, tableItems: itemGroup.items)]
        step.buildFooterTableItems().map {
            sections.append(RSDTableSection(identifier: "footer", sectionIndex: idx + 1, tableItems: $0))
        }
        
        self.sections = sections
        self.itemGroup = itemGroup
        
        self.handSelectionResult = itemGroup.answerResult
        self.handOrderResult = AnswerResultObject(identifier: MCTHandSelectionDataSource.handOrderKey,
                                                  answerType: AnswerTypeArray(baseType: .string))
        
        let collectionResult = CollectionResultObject(identifier: step.identifier)
        collectionResult.appendInputResults(with: self.handSelectionResult)
        collectionResult.appendInputResults(with: self.handOrderResult)
        parent?.taskResult.appendStepHistory(with: collectionResult)
        
        super.init(step: step, parent: parent)
    }
    
    /// Specifies whether the next button should be enabled based on the validity of the answers for
    /// all form items.
    override public var isForwardEnabled: Bool {
        return super.isForwardEnabled && allAnswersValid()
    }

    public func allAnswersValid() -> Bool {
        itemGroup.isAnswerValid
    }

    public func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup? {
        indexPath.section == itemGroup.sectionIndex ? itemGroup : nil
    }
    
    public func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws {
        guard indexPath.section == itemGroup.sectionIndex else { return }
        try itemGroup.saveAnswer(answer, at: indexPath.item)
        delegate?.tableDataSource(self, didChangeAnswersIn: indexPath.section)
    }
    
    public func selectAnswer(item: RSDTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        guard indexPath.section == itemGroup.sectionIndex else {
            return (false, false)
        }
        let ret = try itemGroup.toggleSelection(at: indexPath.item)
        _updateHandOrder()
        delegate?.tableDataSource(self, didChangeAnswersIn: indexPath.section)
        return ret
    }
       
    /// Writes a randomized hand order result to the task result.
    private func _updateHandOrder() {
        guard let hand = handSelectionResult.value as? String,
            let handSelection = MCTHandSelection(rawValue: hand)
            else { return }
        
        if handSelection == .both {
            let handOrder: [MCTHandSelection] = arc4random_uniform(2) == 0 ? [.left, .right] : [.right, .left]
            handOrderResult.jsonValue = .array(handOrder.map { $0.stringValue })
        }
        else {
            handOrderResult.jsonValue = .array([handSelection.rawValue])
        }
    }
}

