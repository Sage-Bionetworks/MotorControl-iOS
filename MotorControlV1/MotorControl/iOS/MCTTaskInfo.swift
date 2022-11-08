//
//  MCTTaskInfo.swift
//  MotorControl
//

import Foundation
import JsonModel
import Research

#if canImport(ResearchUI)
import ResearchUI
import MCTResources
#endif

/// A list of all the tasks included in this module.
public enum MCTTaskIdentifier : String, Codable, StringEnumSet, DocumentableStringEnum {
    
    /// The walk and balance test.
    case walkAndBalance = "WalkAndBalance"
    
    /// The tremor test.
    case tremor = "Tremor"
    
    /// The kinetic tremor, or finger to nose, test.
    case kineticTremor = "Kinetic Tremor"
    
    /// The tapping test.
    case tapping = "Tapping"
    
    /// The 30 second walk test that is the first half of walk and balance test. This can used for gait
    /// analysis without the balance component, and would allow for cross-comparability of the data with
    /// other studies using Walk and Balance.
    case walk30Seconds = "Walk30Seconds"
    
    /// The default resource transformer for this task.
    public func resourceTransformer() -> RSDResourceTransformer {
        return MCTTaskTransformer(self)
    }
    
    public var identifier: RSDIdentifier {
        return RSDIdentifier(rawValue: self.rawValue)
    }
}

/// A task info object for the tasks included in this submodule.
public struct MCTTaskInfo : RSDTaskInfo, RSDEmbeddedIconData {

    /// The task identifier for this task.
    public let taskIdentifier: MCTTaskIdentifier
    
    /// The task built for this info.
    public let task: MCTTaskObject
    
    private init(taskIdentifier: MCTTaskIdentifier, task: MCTTaskObject) {
        self.taskIdentifier = taskIdentifier
        self.task = task
    }
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - taskIdentifier: The identifier for the activity to run.
    ///     - overviewText: The text to display as the overview text for the task.
    public init(_ taskIdentifier: MCTTaskIdentifier, overviewText: String? = nil) {
        self.taskIdentifier = taskIdentifier
        
        // Pull the title, subtitle, and detail from the first step in the task resource.
        let factory = MCTFactory()
        
        do {
            let transformer = taskIdentifier.resourceTransformer()
            let (data, _) = try transformer.resourceData(ofType: .json)
            let decoder = factory.createJSONDecoder(resourceInfo: transformer)
            self.task = try decoder.decode(MCTTaskObject.self, from: data)
        } catch let err {
            fatalError("Failed to decode the task. \(err)")
        }
        
        if let step = (task.stepNavigator as? RSDConditionalStepNavigator)?.steps.first as? RSDUIStep {
            if let mutableStep = step as? RSDUIStepObject, let text = overviewText {
                mutableStep.subtitle = text
            }
            self.title = step.title
            self.subtitle = step.subtitle
            self.detail = step.detail
        }

        #if canImport(ResearchUI)
        // Get the task icon for this taskIdentifier
        do {
            self.icon = try RSDResourceImageDataObject(imageName: "\(taskIdentifier.stringValue)TaskIcon", bundle: MCTResources.bundle)
        } catch let err {
            print("Failed to load the task icon. \(err)")
        }
        #endif
    }
    
    /// The identifier is the task identifier for this task.
    public var identifier: String {
        return self.task.identifier
    }
    
    /// The title for the task.
    public var title: String?
    
    /// The subtitle for the task.
    public var subtitle: String?
    
    /// The detail for the task.
    public var detail: String?
    
    /// The image icon for the task.
    public var icon: RSDResourceImageDataObject?
    
    /// Estimated minutes to perform the task.
    public var estimatedMinutes: Int {
        return 3
    }
    
    /// A schema associated with this task info.
    public var schemaInfo: RSDSchemaInfo?
    
    /// Returns `task`.
    public var resourceTransformer: RSDTaskTransformer? {
        return self.task
    }
    
    public func copy(with identifier: String) -> MCTTaskInfo {
        let task = self.task.copy(with: identifier)
        var copy = MCTTaskInfo(taskIdentifier: taskIdentifier, task: task)
        copy.title = self.title
        copy.subtitle = self.subtitle
        copy.detail = self.detail
        copy.icon = self.icon
        copy.schemaInfo = self.schemaInfo
        return copy
    }
}

#if canImport(ResearchUI)
extension MCTTaskInfo : RSDTaskDesign {
    
    public var designSystem: RSDDesignSystem {
        return MCTFactory.designSystem
    }
}
#endif

/// A task transformer for the resources included in this module.
public struct MCTTaskTransformer : RSDResourceTransformer, Decodable {
    private enum CodingKeys : String, CodingKey {
        case resourceName, packageName
    }
    
    public init(_ taskIdentifier: MCTTaskIdentifier) {
        switch taskIdentifier {
        case .walkAndBalance:
            self.resourceName = "Walk_And_Balance"
        case .tremor:
            self.resourceName = "Tremor"
        case .kineticTremor:
            self.resourceName = "Kinetic_Tremor"
        case .tapping:
            self.resourceName = "Finger_Tapping"
        case .walk30Seconds:
            self.resourceName = "Walk_30seconds"
        }
    }
    
    /// Name of the resource for this transformer.
    public let resourceName: String
    
    /// Name of the Android package.
    public var packageName: String?
    
    /// Get the task resource from this bundle.
    public var bundleIdentifier: String? {
        return factoryBundle?.bundleIdentifier
    }
    
    /// The factory bundle points to this framework. (nil-resettable)
    public var factoryBundle: ResourceBundle? {
        get {
            #if canImport(ResearchUI)
                return _bundle ?? MCTResources.bundle
            #else
                return _bundle
            #endif
        }
        set {
            _bundle = newValue
        }
    }
    private var _bundle: ResourceBundle? = nil
    
    // MARK: Not used.
    
    public var classType: String? {
        return nil
    }
}

/// `RSDTaskGroupObject` is a concrete implementation of the `RSDTaskGroup` protocol.
public struct MCTTaskGroup : RSDTaskGroup, RSDEmbeddedIconData, Decodable {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case identifier, title, detail, icon
    }
    
    /// A short string that uniquely identifies the task group.
    public let identifier: String
    
    /// The primary text to display for the task group in a localized string.
    public let title: String?
    
    /// Additional detail text to display for the task group in a localized string.
    public let detail: String?
    
    /// The optional `RSDResourceImageDataObject` with the pointer to the image.
    public let icon: RSDResourceImageDataObject?

    /// The task group object is 
    public let tasks: [RSDTaskInfo] = MCTTaskIdentifier.allCases.map { MCTTaskInfo($0) }
}
