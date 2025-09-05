import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = DeveloperToolsSupport.ColorResource(name: "AccentColor", bundle: resourceBundle)

    /// The "TreeShopBlack" asset catalog color resource.
    static let treeShopBlack = DeveloperToolsSupport.ColorResource(name: "TreeShopBlack", bundle: resourceBundle)

    /// The "TreeShopBlue" asset catalog color resource.
    static let treeShopBlue = DeveloperToolsSupport.ColorResource(name: "TreeShopBlue", bundle: resourceBundle)

    /// The "TreeShopGreen" asset catalog color resource.
    static let treeShopGreen = DeveloperToolsSupport.ColorResource(name: "TreeShopGreen", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

}

