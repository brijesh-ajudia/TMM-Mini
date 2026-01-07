//
//  UIImage+Extension.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 07/01/26.
//

import Foundation
import UIKit
import Photos

extension UIImage {
    
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 300.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)
        
        return animation
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if (a ?? 0) < (b ?? 0) {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    static func downSample(imageAt imageURL: URL, to pointSize: CGSize) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * UIScreen.main.scale
        
        let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: true,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
        if let downsampledImage =     CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) {
            return UIImage(cgImage: downsampledImage)
        }
        return UIImage()
    }
    
    static func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                    completion()
                }
                
            } else {
                completion()
                print("Failure: %@", error!.localizedDescription);
            }
        }
        task.resume()
    }
    func saveToDocuments(filename:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        if let data = self.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
            } catch {
                print("error saving file to documents:", error)
            }
        }
    }
    
    func imageResize(sizeChange:CGSize)-> UIImage{
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
    func resizeImageLimite(targetSize: CGSize) -> UIImage {
        let image = self
        let size = image.size
        
        if(targetSize.width > size.width && targetSize.height > size.height){
            return self
        }
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImage.Orientation.up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if ( self.imageOrientation == UIImage.Orientation.down || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.left || self.imageOrientation == UIImage.Orientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.right || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2.0));
        }
        
        if ( self.imageOrientation == UIImage.Orientation.upMirrored || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if ( self.imageOrientation == UIImage.Orientation.leftMirrored || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;
        
        ctx.concatenate(transform)
        
        if ( self.imageOrientation == UIImage.Orientation.left ||
            self.imageOrientation == UIImage.Orientation.leftMirrored ||
            self.imageOrientation == UIImage.Orientation.right ||
            self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
    }
    
    func fixOrientationNew() -> UIImage? {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
}

extension UIImageView {
    func mergedPlayImageWith(frontImage:UIImage?, backgroundImage: UIImage?, isGrid: Bool = false) -> UIImage {

        if (backgroundImage == nil) {
            return frontImage!
        }

        let size = self.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        backgroundImage?.draw(in: self.bounds)
        if isGrid == true {
            let width = (UIScreen.main.bounds.width - CGFloat(8 + (3 * 8)))/CGFloat(3)
            let point = (width / 2) - 12
            frontImage?.draw(in: CGRect(x: point, y: point, width: 24, height: 24))
        }
        else {
            frontImage?.draw(in: CGRect(x: 38, y: 38, width: 24, height: 24))
        }

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func mergedPlayImageWithDownloads(frontImage:UIImage?, backgroundImage: UIImage?) -> UIImage {

        if (backgroundImage == nil) {
            return frontImage!
        }

        let size = self.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        backgroundImage?.draw(in: self.bounds)
        frontImage?.draw(in: CGRect(x: 38, y: 38, width: 24, height: 24))

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func mergedThemeImageWith(frontImage:UIImage?, backgroundImage: UIImage?) -> UIImage {

        if (backgroundImage == nil) {
            return frontImage!
        }

        let size = self.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        backgroundImage?.draw(in: self.bounds)
        frontImage?.draw(in: self.bounds)

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize, indexPath: IndexPath? = nil, callback:((_ indexPath: IndexPath?,_ phImage: UIImage)-> Void)?) {
        //        let options = PHImageRequestOptions()
        //        options.version = .original
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = false
        option.isSynchronous = true
        option.resizeMode = .fast
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: option) { (image, _) in
            guard let image = image else { return }
            switch contentMode {
            case .aspectFill:
                self.contentMode = .scaleAspectFill
                break
            case .aspectFit:
                self.contentMode = .scaleAspectFit
                break
            default:
                break
            }
            callback?(indexPath, image)
        }
        //        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: option) { image, _ in
        //            guard let image = image else { return }
        //            switch contentMode {
        //            case .aspectFill:
        //                self.contentMode = .scaleAspectFill
        //            case .aspectFit:
        //                self.contentMode = .scaleAspectFit
        //            }
        //            self.image = image
        //        }
    }
}
extension PHAsset {
    func getImage(callback:((_ phData: Data)-> Void)?) {
        //        let options = PHImageRequestOptions()
        //        options.version = .original
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = false
        option.isSynchronous = true
        option.resizeMode = .fast
        
        PHCachingImageManager.default().requestImageData(for: self, options: nil) { (data, type, orientation, options) in
            guard let data = data else { return }
            callback?(data)
        }
    }
    
    var fileSize: Double {
        get {
            let resource = PHAssetResource.assetResources(for: self)
            let imageSizeByte = resource.first?.value(forKey: "fileSize") as! Double
            let imageSizeMB = imageSizeByte / (1000*1000)
            return imageSizeMB
        }
    }
}

extension String {
    func getImage()-> UIImage {
        let fileManager = FileManager.default
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(self)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            print("No Image available")
            return UIImage.init(named: "ic_placeholder")!
        }
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

class ImageFormatHandler {
    
    /// Detects image format from URL
    /// - Parameter imageURL: URL of the image file
    /// - Returns: ImageFormat enum indicating the detected format
    func detectImageFormat(from imageURL: URL) -> ImageFormat {
        // Method 1: Using UTType (iOS 14+)
        if #available(iOS 14.0, *) {
            if let utType = try? imageURL.resourceValues(forKeys: [.contentTypeKey]).contentType {
                let `extension` = utType.preferredFilenameExtension?.lowercased() ?? ""
                return ImageFormat(rawValue: `extension`) ?? .unknown
            }
        }
        
        // Method 2: Using ImageIO (More reliable for image files)
        if let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) {
            if let utType = CGImageSourceGetType(imageSource) as String? {
                switch utType.lowercased() {
                case _ where utType.contains("jpeg"), _ where utType.contains("jpg"):
                    return .jpeg
                case _ where utType.contains("png"):
                    return .png
                case _ where utType.contains("heic"):
                    return .heic
                case _ where utType.contains("heif"):
                    return .heif
                case _ where utType.contains("dng"):
                    return .dng
                case _ where utType.contains("raw"):
                    return .raw
                default:
                    return .unknown
                }
            }
        }
        
        // Method 3: Fallback to path extension
        let `extension` = imageURL.pathExtension.lowercased()
        return ImageFormat(rawValue: `extension`) ?? .unknown
    }
    
    /// Processes image and converts if necessary
    /// - Parameters:
    ///   - imageURL: URL of the input image
    ///   - completion: Callback with processed image URL and any error
    func processImage(at imageURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        let format = detectImageFormat(from: imageURL)
        
        if !format.needsConversion {
            // No conversion needed
            completion(imageURL, nil)
            return
        }
        
        // Create output URL in temp directory
        let fileName = imageURL.deletingPathExtension().lastPathComponent
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension("jpg")
        
        // Convert image
        do {
            try convertToJPEG(from: imageURL, to: outputURL)
            completion(outputURL, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    /// Converts image to JPEG format
    /// - Parameters:
    ///   - inputURL: Source image URL
    ///   - outputURL: Destination URL for JPEG
    ///   - quality: JPEG compression quality (0.0 to 1.0)
    private func convertToJPEG(from inputURL: URL, to outputURL: URL, quality: CGFloat = 0.8) throws {
        guard let imageSource = CGImageSourceCreateWithURL(inputURL as CFURL, nil) else {
            throw NSError(domain: "ImageFormatHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create image source"])
        }
        
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw NSError(domain: "ImageFormatHandler", code: -2, userInfo: [NSLocalizedDescriptionKey: "Could not create CGImage"])
        }
        
        let image = UIImage(cgImage: cgImage)
        guard let jpegData = image.jpegData(compressionQuality: quality) else {
            throw NSError(domain: "ImageFormatHandler", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not create JPEG data"])
        }
        
        try jpegData.write(to: outputURL)
    }
}

class ImageSizeHandler {
    
    /// Get exact image details from PHAsset
    /// - Parameter asset: PHAsset of the image
    /// - Returns: Tuple containing size in MB, width, and height
    func processAndGetURL(image: UIImage, asset: PHAsset, fileName: String) -> URL? {
        let imageDetails = asset
        print("Original image size: \(asset.fileSize) MB")
        print("Original dimensions: \(asset.pixelWidth) x \(asset.pixelHeight)")
        
        // If size is already <= 2MB, save original
        if imageDetails.fileSize <= 2.0 {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                return saveImageData(imageData, fileName: fileName)
            }
        }
        
        // If size > 2MB, resize and compress
        let maxDimension: CGFloat = 1024
        let originalSize = CGSize(width: imageDetails.pixelWidth, height: imageDetails.pixelHeight)
        let newSize = Utils.sharedInstance.resizedSize(for: originalSize, maxDimension: maxDimension)
        
        guard let resizedImage = Utils.sharedInstance.resizeImage(image, to: newSize) else {
            return nil
        }
        
        // Try different compression qualities until file size is under 2MB
        var compression: CGFloat = 1.0
        var imageData = resizedImage.jpegData(compressionQuality: compression)
        var currentSize = Double(imageData?.count ?? 0) / (1024 * 1024)
        
        while currentSize > 2.0 && compression > 0.1 {
            compression -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compression)
            currentSize = Double(imageData?.count ?? 0) / (1024 * 1024)
        }
        
        return saveImageData(imageData, fileName: fileName)
    }
    
    /// Save image data to temporary file
    private func saveImageData(_ imageData: Data?, fileName: String) -> URL? {
        guard let data = imageData else { return nil }
        
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent("\(fileName)_\(Date().timeIntervalSince1970).jpg")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}


enum ImageFormat: String {
    case jpeg = "jpeg"
    case jpg = "jpg"
    case png = "png"
    case heic = "heic"
    case heif = "heif"
    case dng = "dng"
    case raw = "raw"
    case unknown = "unknown"
    
    var needsConversion: Bool {
        switch self {
        case .jpeg, .jpg, .png:
            return false
        case .heic, .heif, .dng, .raw:
            return true
        case .unknown:
            return true
        }
    }
}
