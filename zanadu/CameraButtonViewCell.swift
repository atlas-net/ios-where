//
//  CameraButtonViewCell.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/7/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit
import AVFoundation

/**
Cell 
containing a button with live video capture on background
*/
class CameraButtonViewCell: UICollectionViewCell, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //Mark: - Properties
    
    var delegate: CameraButtonViewCellSelectionDelegate?
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue : DispatchQueue!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    let session=AVCaptureSession()
    var currentFrame:CIImage!
    var done = false
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var cameraButton: UIButton!
    
    
    //MARK: - Actions

    @IBAction func onCameraButtonTapped(_ sender: UIButton) {

        if let delegate = delegate {
            delegate.onCameraButtonTapped()
        }
    }


    //MARK: - Methods
    
    func setupAVCapture(){
        
        GlobalUserInitiatedQueue.async {
        self.session.sessionPreset = AVCaptureSessionPreset640x480
        
        self.captureDevice = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).first as? AVCaptureDevice
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: self.captureDevice)
      
            if self.captureDevice != nil {
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                    self.beginSession()
                    self.done = true
                }
            }
        } catch {
            log.error("Capture error")
        }
        }
    }
    
    /**
    Start live session
    */
    func beginSession() {
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            if self.session.canAddInput(videoDeviceInput){
                self.session.addInput(videoDeviceInput)
            }
            
            self.videoDataOutput = AVCaptureVideoDataOutput()
            self.videoDataOutput.alwaysDiscardsLateVideoFrames=true
            self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: [])
            self.videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue)
            
            if session.canAddOutput(self.videoDataOutput){
                session.addOutput(self.videoDataOutput)
            }
            
            let conn: AVCaptureConnection = self.videoDataOutput.connection(withMediaType: AVMediaTypeVideo)
            conn.isEnabled = true
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            self.backgroundView = UIView(frame: self.frame)
            
            let rootLayer :CALayer = self.backgroundView!.layer
            rootLayer.masksToBounds=true
            self.previewLayer.frame = rootLayer.bounds
            rootLayer.addSublayer(self.previewLayer)
            session.startRunning()
        } catch {
            log.error("Capture error")
        }


    }
}

