// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

#if os(watchOS)
    import WatchKit
#endif

/// Decodes image data.
public protocol DataDecoding {
    /// Decodes image data.
    func decode(data: Data, response: URLResponse) -> Image?
}

private let queue = DispatchQueue(label: "\(domain).DataDecoder")

/// Decodes image data. Image scale is set to the scale of the main screen.
public struct DataDecoder: DataDecoding {
    /// Initializes the receiver.
    public init() {}

    /// Decodes image data using built-in `Image` initializers.
    public func decode(data: Data, response: URLResponse) -> Image? {
        // Image initializers are not thread safe:
        // - https://github.com/AFNetworking/AFNetworking/issues/2572
        // - https://github.com/Alamofire/AlamofireImage/issues/75
        return queue.sync {
            #if os(OSX)
                return NSImage(data: data)
            #else
                #if os(iOS) || os(tvOS)
                    let scale = UIScreen.main.scale
                #else
                    let scale = WKInterfaceDevice.current().screenScale
                #endif
                return UIImage(data: data, scale: scale)
            #endif
        }
    }
}