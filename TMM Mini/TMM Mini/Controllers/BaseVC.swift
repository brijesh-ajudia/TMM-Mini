//
//  BaseVC.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 07/01/26.
//

import UIKit
import Photos
import AVFoundation
import VisionKit
import TOCropViewController

protocol BaseVCDelegate: AnyObject {
    func didCropImage(_ image: UIImage)
}

enum UploadFor {
    case Profile
}

enum ImageSource {
    case photoLibrary
    case camera
}

enum PermissionAlertFor {
    case Photos
    case Camera
}

class BaseVC: UIViewController {
    
    var allTextField: [UITextField] = []
    var beginTextField:((_ textField: UITextField) -> Bool)?
    var tapGesture: UITapGestureRecognizer?
    
    
    var imagePicker: UIImagePickerController!
    var isImageUpload: Bool = false
    
    var imageFor: UploadFor = .Profile
    
    weak var delegate: BaseVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.addGestureIfTextfieldExists()
    }
    
    //MARK: - AddGestureIfTextfieldExists
    func addGestureIfTextfieldExists() {
        self.allTextField = getAllTextFields(fromView : self.view)
        if self.allTextField.count > 0 {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureClickEvent(_:)))
            if let tapGesture = tapGesture {
                tapGesture.cancelsTouchesInView = false
                tapGesture.delegate = self
                self.view.addGestureRecognizer(tapGesture)
            }
            self.setKeyboardIfTextFieldExists()
                
        }
    }
    
    @objc func tapGestureClickEvent(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func getAllTextFields(fromView view: UIView)-> [UITextField] {
        return view.subviews.compactMap { (view) -> [UITextField]? in
            if view is UITextField {
                return [(view as! UITextField)]
            } else {
                return getAllTextFields(fromView: view)
            }
        }.flatMap({$0})
    }
    
    //MARK: - Set Keyboard Type
    func setKeyboardIfTextFieldExists() {
        for i in 0 ..< self.allTextField.count {
            let textfield = self.allTextField[i]
            textfield.delegate = self
            textfield.tag = i
            textfield.returnKeyType = i == self.allTextField.count - 1 ? .done : .next
            switch (textfield.textContentType) {
            case UITextContentType.emailAddress:
                textfield.keyboardType = .emailAddress
            case UITextContentType.password:
                textfield.keyboardType = .default
                textfield.isSecureTextEntry = true
            case UITextContentType.telephoneNumber:
                textfield.keyboardType = .numberPad
            default:
                textfield.keyboardType = .default
            }
        }
    }
    
    // MARK: - Check Camera / Photos Access Status
    func checkStatus() -> Bool {
        let accessStatus = PHPhotoLibrary.authorizationStatus()
        switch accessStatus {
        case .notDetermined:
            DispatchQueue.main.async {
                self.requestForPhotos()
            }
            return false
        case .restricted, .denied:
            DispatchQueue.main.async {
                self.alertForAccessPhotos(alertFor: .Photos)
            }
            return false
        case .authorized, .limited:
            return true
        @unknown default:
            DispatchQueue.main.async {
                self.alertForAccessPhotos(alertFor: .Photos)
            }
            return false
        }
    }
    
    func checkCameraAccess() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            self.alertForAccessPhotos(alertFor: .Camera)
            return false
        case .authorized:
            return true
        case .notDetermined:
            self.requestAccessCamera()
            return false
        @unknown default:
            self.alertForAccessPhotos(alertFor: .Camera)
            return false
        }
    }
    
    // MARK: - Request for Accessing Photos
    func requestForPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self.selectImageFrom(.photoLibrary)
                case .denied, .restricted, .notDetermined:
                    self.alertForAccessPhotos(alertFor: .Photos)
                @unknown default:
                    self.alertForAccessPhotos(alertFor: .Photos)
                }
            }
        }
    }
    
    // MARK: - Request for Accessing Camera
    func requestAccessCamera() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.selectImageFrom(.camera)
                }
            }
        }
    }
    
    // MARK: - Alert for Access Permissions
    func alertForAccessPhotos(alertFor: PermissionAlertFor) {
        let message = alertFor == .Photos ? "Turn on Photo Library access in settings" : "Set camera access to On in settings."
        let title = alertFor == .Photos ? "Photo Library" : "Camera Access"
        
        self.showAlert(title: title, message: message, okTitle: "Open Settings", cancelTitle: "Cancel") {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } cancelCallback: {
            
        }
    }
    
    func getImageSizeInMB(image: UIImage) -> Double? {
        // Convert the UIImage to Data in PNG or JPEG format
        guard let imageData = image.pngData() else { // Use pngData() for PNG
            return nil
        }
        
        // Get the size in bytes
        let sizeInBytes = Double(imageData.count)
        
        // Convert bytes to megabytes (1 MB = 1,048,576 bytes)
        let sizeInMB = sizeInBytes / 1048576
        
        return sizeInMB
    }
    
    func checkInternetSpeed(
        url: String = "https://example.com/test-file", // Replace with a small test file URL
        completion: @escaping (Double) -> Void // Speed in Mbps
    ) {
        guard let downloadURL = URL(string: url) else {
            print("Invalid URL")
            completion(0)
            return
        }
        
        let startTime = Date()
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: downloadURL) { data, _, error in
            guard error == nil, let data = data else {
                print("Error measuring speed: \(error?.localizedDescription ?? "Unknown error")")
                completion(0)
                return
            }
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime) // in seconds
            let dataSize = Double(data.count) / 1000000 // Convert bytes to megabytes
            let speed = dataSize / duration // Speed in Mbps
            
            completion(speed)
        }
        
        task.resume()
    }
    
}

//MARK: - TextField Delegates
extension BaseVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let returnValue = self.beginTextField?(textField) {
            return returnValue
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nextTextField(textField: textField)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.textContentType == UITextContentType.telephoneNumber {
            return range.location < 11
        }
        else {
            return true
        }
    }
    
    func nextTextField(textField: UITextField) {
        let nextTag = textField.tag + 1
        if let nextResponder = self.view.viewWithTag(nextTag) as? UITextField {
            if nextResponder.isUserInteractionEnabled {
                nextResponder.becomeFirstResponder()
            }
            else {
                self.nextTextField(textField: nextResponder)
            }
        } else {
            textField.resignFirstResponder()
        }
    }
}

// MARK: - Select Profile Picture From
extension BaseVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Image Picker
    func selectImageFrom(_ source: ImageSource) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = source == .camera ? .camera : .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        let finalImage = selectedImage.fixOrientation()
        
        
        let imgData = NSData(data: finalImage.jpegData(compressionQuality: 1)!)
        let imageSize: Int = imgData.count
        print("actual size of image in MB: %f ", Double(imageSize) / 1024 / 1024)
        
        switch self.imageFor {
        case .Profile:
            let cropViewController = TOCropViewController(croppingStyle: .default, image: finalImage)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        }
    }
}

// MARK: - TOCropViewControllerDelegate
extension BaseVC: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        self.isImageUpload = true
        
        let finalImage = image.resizeImageLimite(targetSize: CGSize(width: 140, height: 140))
        let imgData = NSData(data: finalImage.jpegData(compressionQuality: 1)!)
        let imageSize: Int = imgData.count
        print("actual size of image in MB: %f ", Double(imageSize) / 1024 / 1024)
        
        self.delegate?.didCropImage(finalImage)
    }
}

extension BaseVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Check if the touched view is the button
        if let touchedView = touch.view {
            if touchedView is UITextField {
                return false // Allow the text field to handle the touch
            }
            if touchedView is UILabel {
                return false // Allow the label to handle the touch
            }
            if touchedView is UIButton {
                return false // Ignore the gesture for buttons
            }
        }
        return true
    }
}
