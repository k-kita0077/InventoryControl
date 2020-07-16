//
//  MyQRCodeReader.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/07/01.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import AVFoundation
import UIKit

class MyQRCodeReader {
    
    let captureSession = AVCaptureSession()
    let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    var metadataOutput = AVCaptureMetadataOutput()
    var delegate:AVCaptureMetadataOutputObjectsDelegate? {
        get{
            return self.forwardDelegate
        }
        set(v){
            self.forwardDelegate = v
            self.metadataOutput.setMetadataObjectsDelegate(v, queue: DispatchQueue.main)
        }
    }
    var forwardDelegate:AVCaptureMetadataOutputObjectsDelegate?
    var preview:UIView?
    var previewLayer = AVCaptureVideoPreviewLayer()
    let qrView = UIView()

    //info.plist Privacy - Camera Usage Description:String
    func setupCamera( view:UIView, borderWidth:Int = 1, borderColor:CGColor =  UIColor.red.cgColor ){
        
        self.preview = view
        
        //デバイスからの入力
        do {
            let videoInput = try AVCaptureDeviceInput(device: self.videoDevice!) as AVCaptureDeviceInput
            self.captureSession.addInput(videoInput)
        } catch let error as NSError {
            print(error)
        }
        //出力
        self.captureSession.addOutput(self.metadataOutput)
        
        //読み込み対象タイプ
        self.metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        //カメラ映像を表示
        self.cameraPreview(view)
        
        //認識QRの確認表示
        self.targetCapture( borderWidth:borderWidth, borderColor: borderColor )
        
        // 読み取り開始
        self.captureSession.startRunning()

    }
       
    private func cameraPreview( _ view:UIView ){
        //カメラ映像を画面に表示
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(previewLayer)
    }
    
    private func targetCapture(borderWidth:Int, borderColor:CGColor){
        self.qrView.layer.borderWidth = CGFloat(borderWidth)
        qrView.layer.borderColor = borderColor
        qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        if let v = self.preview {
            v.addSubview(qrView)
        }
    }
    
    //読み取り範囲の指定
    public func readRange( frame:CGRect = CGRect(x: 0.2, y: 0.3, width: 0.6, height: 0.4) ){
        
        self.metadataOutput.rectOfInterest = CGRect(x: frame.minY,y: 1-frame.minX-frame.size.width, width: frame.size.height,height: frame.size.width)
        
        let v = UIView()
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.red.cgColor
        if let preview = self.preview {
            v.frame = CGRect(x: preview.frame.size.width * frame.minX, y:  preview.frame.size.height * frame.minY, width: preview.frame.size.width * frame.size.width, height: preview.frame.size.height * frame.size.height )
            preview.addSubview(v)
        }
    }

    func delegate(_ delegate:AVCaptureMetadataOutputObjectsDelegate){
        //オブジェクトを読み込んだ時のdelegate AVCaptureMetadataOutputObjectsDelegate.metadataOutput
        self.metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
    }
}
