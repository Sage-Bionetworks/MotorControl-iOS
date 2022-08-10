import Foundation
import JsonModel

public final class SharedResources : ResourceInfo {
    public static let bundle = Bundle.module
    public static let shared: SharedResources = .init()
    
    public var factoryBundle: ResourceBundle? { Bundle.module }
    public var packageName: String? { nil }
    public var bundleIdentifier: String? { nil }
}
