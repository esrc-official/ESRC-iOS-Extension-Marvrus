//
//  ViewController.swift
//  ESRC-iOS
//
//  Created by Hyunwoo Lee on 28/05/2021.
//  Copyright © 2021 ESRC. All rights reserved.
//

import UIKit
import AVFoundation
import ESRC_SDK_iOS
import ESRC_SDK_iOS_Extension_Marvrus

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    // ESRC variables
    let APP_ID: String = "" // Application ID.
    let ENABLE_DRAW: Bool = false;  // Whether visualize result or not.
    var property: MarvrusProperty = MarvrusProperty(
        enableMeasureEnv: true,  // Whether analyze measurement environment or not.
        enableFace: true,  // Whether detect face or not.
        enableFacialLandmark: true,  // Whether detect facial landmark or not. If enableFace is false, it is also automatically set to false.
        enableFacialActionUnit: true,  // Whether analyze facial action unit or not. If enableFace or enableFacialLandmark is false, it is also automatically set to false.
        enableBasicFacialExpression: true,  // Whether recognize basic facial expression or not. If enableFace is false, it is also automatically set to false.
        enableValenceFacialExpression: true,  // Whether recognize valence facial expression or not. If enableFace is false, it is also automatically set to false.
        enableRemoteHR: true,  // Whether estimate remote hr or not.
        enableHRV: true,  // Whether analyze HRV or not. If enableRemoteHR is false, it is also automatically
        enableEngagement: true,  // Whether recognize engagement or not. If enableRemoteHR and enableHRV are false, it is also automatically set to false.
        enableMEEIndex: true)  // Whether recognize MEE index or not.
    var frame: UIImage? = nil
    var face: ESRCFace? = nil
    var facialLandmark: ESRCFacialLandmark? = nil
    
    // Camera variables
    @IBOutlet weak var preview: UIImageView!
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var overlayLayer: CAShapeLayer!
    
    // Timer variables
    var timer: Timer?
    var licenseTimer: Timer?
    
    @IBOutlet weak var facebox_image: UIImageView!
    @IBOutlet weak var info_container: UIView!
    @IBOutlet weak var upper_line_container: UIView!
    @IBOutlet weak var under_line_container: UIView!
    @IBOutlet weak var hr_container: UIView!
    @IBOutlet weak var hrv_sdnn_container: UIView!
    @IBOutlet weak var hrv_rmssd_container: UIView!
    @IBOutlet weak var basic_facial_exp_container: UIView!
    @IBOutlet weak var valence_facial_exp_container: UIView!
    @IBOutlet weak var attention_container: UIView!
    
    @IBOutlet weak var hr_indicator: UIActivityIndicatorView!
    @IBOutlet weak var hr_title_text: UITextField!
    @IBOutlet weak var hr_unit_text: UITextField!
    @IBOutlet weak var hr_val_text: UITextView!
    
    @IBOutlet weak var hrv_sdnn_indicator: UIActivityIndicatorView!
    @IBOutlet weak var hrv_sdnn_title_text: UITextField!
    @IBOutlet weak var hrv_sdnn_unit_text: UITextField!
    @IBOutlet weak var hrv_sdnn_val_text: UITextView!
    
    @IBOutlet weak var hrv_rmssd_indicator: UIActivityIndicatorView!
    @IBOutlet weak var hrv_rmssd_title_text: UITextField!
    @IBOutlet weak var hrv_rmssd_unit_text: UITextField!
    @IBOutlet weak var hrv_rmssd_val_text: UITextView!
    
    @IBOutlet weak var basic_facial_exp_title_text: UITextField!
    @IBOutlet weak var basic_facial_exp_val_text: UITextView!

    @IBOutlet weak var valence_facial_exp_title_text: UITextField!
    @IBOutlet weak var valence_facial_exp_val_text: UITextView!
    
    @IBOutlet weak var attention_title_text: UITextField!
    @IBOutlet weak var attention_val_text: UITextView!
    
    var hr_circularView = CircularProgressBarView(frame: .zero)
    var hrv_sdnn_circularView = CircularProgressBarView(frame: .zero)
    var hrv_rmssd_circularView = CircularProgressBarView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Always screen on
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Initialize face box
        facebox_image.layer.borderWidth = 4
        facebox_image.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        
        // Initialize container
        info_container.backgroundColor = UIColor(white: 1, alpha: 0.0)
        upper_line_container.backgroundColor = UIColor(white: 1, alpha: 0.0)
        under_line_container.backgroundColor = UIColor(white: 1, alpha: 0.0)
        hr_container.layer.cornerRadius = 10
        hrv_sdnn_container.layer.cornerRadius = 10
        hrv_rmssd_container.layer.cornerRadius = 10
        basic_facial_exp_container.layer.cornerRadius = 10
        valence_facial_exp_container.layer.cornerRadius = 10
        attention_container.layer.cornerRadius = 10
        
        // Start indicator animation
        hr_indicator.startAnimating()
        hrv_sdnn_indicator.startAnimating()
        hrv_rmssd_indicator.startAnimating()
        
        // Initialize progress bar constraints
        hr_circularView.center = hr_container.center
        hr_container.addSubview(hr_circularView)
        hr_circularView.translatesAutoresizingMaskIntoConstraints = false
        hr_circularView.centerXAnchor.constraint(equalTo:hr_container.centerXAnchor).isActive = true // ---- 1
        hr_circularView.centerYAnchor.constraint(equalTo:hr_container.centerYAnchor).isActive = true // ---- 2
        hrv_sdnn_circularView.center = hrv_sdnn_container.center
        hrv_sdnn_container.addSubview(hrv_sdnn_circularView)
        hrv_sdnn_circularView.translatesAutoresizingMaskIntoConstraints = false
        hrv_sdnn_circularView.centerXAnchor.constraint(equalTo:hrv_sdnn_container.centerXAnchor).isActive = true // ---- 1
        hrv_sdnn_circularView.centerYAnchor.constraint(equalTo:hrv_sdnn_container.centerYAnchor).isActive = true // ---- 2
        hrv_rmssd_circularView.center = hrv_rmssd_container.center
        hrv_rmssd_container.addSubview(hrv_rmssd_circularView)
        hrv_rmssd_circularView.translatesAutoresizingMaskIntoConstraints = false
        hrv_rmssd_circularView.centerXAnchor.constraint(equalTo:hrv_rmssd_container.centerXAnchor).isActive = true // ---- 1
        hrv_rmssd_circularView.centerYAnchor.constraint(equalTo:hrv_rmssd_container.centerYAnchor).isActive = true // ---- 2
        
        // Display circular view
        hr_circularView.isHidden = true
        hrv_sdnn_circularView.isHidden = true
        hrv_rmssd_circularView.isHidden = true
        
        // Display coming soon text
        attention_val_text.isHidden = false
    }
    
    func drawImage(size: CGSize, image: UIImage, width: Double, height: Double) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(at: CGPoint.zero)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.addRect(CGRect(x:0, y:0, width: width, height: height))
        context.strokePath()

        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup session
        captureSession = AVCaptureSession()
        
        // Select input device
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            else {
                fatalError("Unable to access front caemra.")
        }

        do {
            // Prepare the input
            let captureInput = try AVCaptureDeviceInput(device: device)
            
            // Configure the output
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) :
                                            NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.processing.queue"))
       
            // Attach the input and output
            if captureSession.canAddInput(captureInput) && captureSession.canAddOutput(videoOutput) {
                captureSession.addInput(captureInput)
                captureSession.addOutput(videoOutput)
                
                // Configure the output connection
                if let connection = self.videoOutput.connection(with: AVMediaType.video),
                   connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                    connection.isVideoMirrored = true
                }

                // Setup the preview
                setupPreview()
            }
        }
        catch _ {
            fatalError("Error Unable to initialize front camera.")
        }
        
        // Initialize Marvrus
        if (!Marvrus.initWithApplicationId(appId: APP_ID, licenseHandler: self)) {
            print("Marvrus init is failed.")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop timer
        self.timer?.invalidate()
        
        // Stop license timer
        self.licenseTimer?.invalidate()
        
        // Release Marvrus
        if(!Marvrus.stop()) {
            print("Marvrus stop is failed.")
        }

        // Stop the session on the background thread
        self.captureSession.stopRunning()
    }
    
    func startApp() {
        print("Start App")
        // Start Marvrus
        if (!Marvrus.start(property: self.property, handler: self)) {
            print("Marvrus start is failed.")
        }
        
        print("Start timer")
        // Start timer (10 fps)
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            // Feed ESRC
            if(self.frame != nil) {
                Marvrus.feed(frame: self.frame!)
            }
        }
        
        print("Start license timer")
        // Start license timer (after 80s)
        self.licenseTimer = Timer.scheduledTimer(withTimeInterval: 80, repeats: false) { timer in
            // Show alert dialog
            let alert = UIAlertController(title: "Alert", message: "If you want to use the ESRC SDK, please visit the homepage: https://www.esrc.co.kr", preferredStyle: .alert)
            let alertPositiveButton = UIAlertAction(title: "OK", style: .default) { action in
                // Nothing
            }
            alert.addAction(alertPositiveButton)
            self.present(alert, animated: true, completion: nil)
            
            // Close app
            _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                exit(0)
            }
        }
    }
    
    func setupPreview() {
        // Configure the preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        preview.layer.addSublayer(previewLayer)
        
        // Configure the overlay
        overlayLayer = CAShapeLayer()
        preview.layer.addSublayer(overlayLayer)

        // Start the session on the background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()

            // Size the preview layer to fit the preview
            DispatchQueue.main.async {
                self.previewLayer.frame = self.preview.bounds
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let videoBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let _ = CMSampleBufferGetFormatDescription(sampleBuffer) else {return}
        let captureImage = CIImage(cvImageBuffer: videoBuffer)
        let context: CIContext = CIContext.init(options: nil)
        let cgImage = context.createCGImage(captureImage, from: captureImage.extent)!
        let image = UIImage(cgImage: cgImage)
        
        // Set frame
        self.frame = image
        
        // Draw
        if (ENABLE_DRAW) {
            DispatchQueue.main.async {
                self.draw(image: image)
            }
        }

    }
    
    func draw(image: UIImage) {
        if (self.face != nil) {
            let wRatio: CGFloat = self.preview.frame.size.width / image.size.width
            let hRatio : CGFloat = self.preview.frame.size.height / image.size.height
            self.overlayLayer.path = UIBezierPath(roundedRect: CGRect(x: (CGFloat)(self.face!.getX()) * wRatio, y: (CGFloat)(self.face!.getY()) * hRatio, width: (CGFloat)(self.face!.getW()) * wRatio, height: (CGFloat)(self.face!.getH()) * hRatio), cornerRadius: 0).cgPath
            self.overlayLayer.strokeColor = UIColor.red.cgColor
            self.overlayLayer.lineWidth = 3
            self.overlayLayer.fillColor = UIColor.clear.cgColor
        } else {
            self.overlayLayer.path = nil
        }
    }
}

extension ViewController: ESRCLicenseHandler, MarvrusHandler {

    func onValidatedLicense() {
        print("onValidatedLicense.")
        
        // Start App
        startApp()
    }
    
    func onInvalidatedLicense() {
        print("onInvalidatedLicense.")
    }
    
    func onRecognizedESRC(id: Int, face: ESRCFace, facialLandmark: ESRCFacialLandmark, facialActionUnit: ESRCFacialActionUnit, basicFacialExpression: ESRCBasicFacialExpression, valenceFacialExpression: ESRCValenceFacialExpression, progressRatioOnRemoteHR: ESRCProgressRatio, remoteHR: ESRCRemoteHR, progressRatioOnHRV: ESRCProgressRatio, hrv: ESRCHRV, engagement: ESRCEngagement, meeIndex: MarvrusMEEIndex, meeJson: String) {
        
        // Whether face is detected or not
        if (face.getIsDetect()) {  // If face is detected
            self.face = face
            self.facialLandmark = facialLandmark
            
            // Hide facebox
            facebox_image.layer.borderWidth = 8
            facebox_image.layer.borderColor = UIColor(red: 0.92, green: 0.0, blue: 0.55, alpha: 1.0).cgColor
            
            // Show facial expressions
            basic_facial_exp_val_text.isHidden = false
            valence_facial_exp_val_text.isHidden = false
            
            // Set basic facial expression
            basic_facial_exp_val_text.isHidden = false
            basic_facial_exp_val_text.text = String(basicFacialExpression.getEmotionStr())
            
            // Set valence facial expression
            valence_facial_exp_val_text.isHidden = false
            valence_facial_exp_val_text.text = String(valenceFacialExpression.getEmotionStr())
            
            // Stop indicator animation for HR
            if (hr_indicator.isAnimating == true) {
                hr_indicator.stopAnimating()
            }

            // Whether remote hr is estimated or not
            if (progressRatioOnRemoteHR.getProgress() >= 100) {  // If remote hr is estimated
                // Hide circular view and show text
                hr_circularView.isHidden = true
                hr_val_text.isHidden = false
                hr_unit_text.isHidden = false
                
                // Set HR value
                hr_val_text.text = String(format: "%.0f", remoteHR.getHR())
            } else {  // If remote hr is not estimated
                // Display progress bar
                hr_circularView.isHidden = false
                hr_circularView.progressAnimation(ratio: progressRatioOnRemoteHR.getProgress(), oneStep: 0.01)
            }
            
            // Stop indicator animation for HRV
            if (hrv_sdnn_indicator.isAnimating == true) {
                hrv_sdnn_indicator.stopAnimating()
                hrv_rmssd_indicator.stopAnimating()
            }

            
            // Whether HRV is analyzed or not
            if (progressRatioOnHRV.getProgress() >= 100) {  // If HRV is analyzed
                // Hide circular view and show text
                hrv_sdnn_circularView.isHidden = true
                hrv_sdnn_val_text.isHidden = false
                hrv_sdnn_unit_text.isHidden = false
                hrv_rmssd_circularView.isHidden = true
                hrv_rmssd_val_text.isHidden = false
                hrv_rmssd_unit_text.isHidden = false
                
                // Set HRV values
                hrv_sdnn_val_text.text = String(format: "%.2f", hrv.getSdnn())
                hrv_rmssd_val_text.text = String(format: "%.2f", hrv.getRmssd())
            } else {  // If HRV is not analyzed
                // Display progress bar
                hrv_sdnn_circularView.isHidden = false
                hrv_rmssd_circularView.isHidden = false
                hrv_sdnn_circularView.progressAnimation(ratio: progressRatioOnHRV.getProgress(), oneStep: 0.01666)
                hrv_rmssd_circularView.progressAnimation(ratio: progressRatioOnHRV.getProgress(), oneStep: 0.01666)
            }
        } else {  // If face is not detected
            self.face = nil
            self.facialLandmark = nil
            
            // Display facebox
            facebox_image.layer.borderWidth = 4
            facebox_image.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
            
            // Hide view
            basic_facial_exp_val_text.isHidden = true
            valence_facial_exp_val_text.isHidden = true
            hr_circularView.isHidden = true
            hr_val_text.isHidden = true
            hr_unit_text.isHidden = true
            hrv_sdnn_circularView.isHidden = true
            hrv_sdnn_val_text.isHidden = true
            hrv_sdnn_unit_text.isHidden = true
            hrv_rmssd_circularView.isHidden = true
            hrv_rmssd_val_text.isHidden = true
            hrv_rmssd_unit_text.isHidden = true
        }
    }
}
