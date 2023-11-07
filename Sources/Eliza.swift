import UIKit
import ARKit
import AVKit
import SceneKit

import Foundation
import AVFoundation
import PlaygroundSupport

import Vision


class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    var completionHandler: () -> () = {}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        completionHandler()
    }
    // ... other delegate methods to handle capture results...
}


public class ElizaController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let bubbleDepth : Float = 0.01
    let bubbleTexts : [String] = [
        "You Rock!",
        "Way to go!",
        "Better luck next time :(",
        "Boo yah!"
    ]
    var bubbleText: String = ""
    
    var visionRequests = [VNRequest]()
    var captureSession: AVCaptureSession?
    var capturedImage: UIImage?
    
    var capturesInProgress = Set<PhotoCaptureProcessor>()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        // Set up the camera for capturing video input
        // let success = cameraAuthorize()
        
        guard let session = try? self.setupCaptureSession() else {
            view.backgroundColor = #colorLiteral(red: 0.9568627450980393, green: 0.6588235294117647, blue: 0.5450980392156862, alpha: 1.0)
            self.view = view
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        self.view = view
        
        // Load CoreML model for hair segmentation
        guard let mod = try? VNCoreMLModel(for: hair_model().model) else {
            fatalError("Could not load model. Ensure model has been drag and copied to XCode. Also ensure the model is part of a target - to do this, go to build folder and copy the .mlmodelc folder to resources.")
        }

        // Set up Vision-CoreML Request
        let segmentRequest = VNCoreMLRequest(model: mod, completionHandler: completeHandler)
        segmentRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [segmentRequest]
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openCamera))
        self.view.addGestureRecognizer(gesture)
        
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        
        guard session.canAddOutput(photoOutput) else { return }
        session.sessionPreset = .photo
        session.addOutput(photoOutput)
        
        let photoSettings: AVCapturePhotoSettings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        
        photoSettings.flashMode = .auto
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)

        
//        let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.image.ml"))
//        session.addOutput(dataOutput)
        
        // Begin Loop to Update CoreML
//        loopCoreMLUpdate()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession?.stopRunning()
    }
    
    @objc func openCamera() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .camera
        imgPicker.allowsEditing = false
        imgPicker.showsCameraControls = true
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:Any]) {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        
        label.text = "Got to the image picker"
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            capturedImage = img
            label.text = "Got the image"
            guard let pixelBuffer = buffer(from: img) else { return }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform(visionRequests)
            label.text = "Starting the request"
            
        } else {
            label.text = "Wasn't able to get the image"
            print("error")
        }
        
        self.view.addSubview(label)
    }
    
    public func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        
        label.text = "Got to photo output"
        
        guard let pixelBuffer = photo.pixelBuffer else { return }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform(visionRequests)
        
        label.text = "Starting request for photo output"
        
        self.view.addSubview(label)
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        
        label.text = "Got to capture Output"
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform(visionRequests)
        
        label.text = "Got to capture Output - request starting"
        
        self.view.addSubview(label)
    }
    
    private func completeHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let segmentationmap = observations.first?.featureValue.multiArrayValue {
            let segmentationView = DrawingSegmentationView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            segmentationView.backgroundColor = UIColor.clear
            segmentationView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(segmentationView)
            
            segmentationView.segmentationmap = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
            print(segmentationmap)
        }
    }
    
    private func cameraAuthorize() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                print("Authorized...")

            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        print("Granted")
                    }
                }

            case .denied: // The user has previously denied access.
                print("getting denied")

            case .restricted: // The user can't grant access due to restrictions.
                print("restricted")
        }
    }
    
    private func setupCaptureSession() -> AVCaptureSession? {
        
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        let discoverDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
        let devices = discoverDevices.devices
        print(devices)

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {
            print("Did not find any devices, returning...")
            return nil
        }

        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return nil }

        session.addInput(input)

        session.startRunning()
        
        return session
    }
    
//    private func loopCoreMLUpdate() {
//        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
//
//        dispatchQueueML.async {
//            // 1. Run Update.
//            self.updateCoreML()
//
//            // 2. Loop this function.
//            self.loopCoreMLUpdate()
//        }
//    }
    
//    private func updateCoreML() {
//        let pixbuff : CVPixelBuffer? = (captureSession?.outputs)
//        if pixbuff == nil { return }
//        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
//
//        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
//
//        do {
//            try imageRequestHandler.perform(self.visionRequests)
//        } catch {
//            print(error)
//        }
//    }
    
//    func maskToRGBA(maskArray: MultiArray<Double>,
//                    rgba: (r: Double, g: Double, b: Double, a: Double)) -> UIImage? {
//        let height = maskArray.shape[1]
//        let width = maskArray.shape[2]
//        var bytes = [UInt8](repeating: 0, count: height * width * 4)
//
//        for h in 0..<height {
//            for w in 0..<width {
//                let offset = h * width * 4 + w * 4
//                let val = maskArray[0, h, w]
//                bytes[offset + 0] = (val * rgba.r).toUInt8
//                bytes[offset + 1] = (val * rgba.g).toUInt8
//                bytes[offset + 2] = (val * rgba.b).toUInt8
//                bytes[offset + 3] = (val * rgba.a).toUInt8
//            }
//        }
//
//        return UIImage.fromByteArray(bytes, width: width, height: height,
//                                     scale: 0, orientation: .up,
//                                     bytesPerRow: width * 4,
//                                     colorSpace: CGColorSpaceCreateDeviceRGB(),
//                                     alphaInfo: .premultipliedLast)
//    }
}
