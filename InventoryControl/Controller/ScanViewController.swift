//
//  ScanViewController.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/07/01.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase


class ScanViewController: UIViewController {
    
    let myQRCodeReader = MyQRCodeReader()
    
    var databaseRef: DatabaseReference!
    var codeList:[AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        
        
        myQRCodeReader.delegate = self
        myQRCodeReader.setupCamera(view:self.view)
        //読み込めるカメラ範囲
        myQRCodeReader.readRange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}



extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    //対象を認識、読み込んだ時に呼ばれる
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //一画面上に複数のQRがある場合、複数読み込むが今回は便宜的に先頭のオブジェクトを処理
        if let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject{
            let barCode = myQRCodeReader.previewLayer.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
            //読み込んだQRを映像上で枠を囲む。ユーザへの通知。必要な時は記述しなくてよい。
            myQRCodeReader.qrView.frame = barCode.bounds
            //QRデータを表示
            if let str = metadata.stringValue {
                showActionSheet(str)
            }
        }
    }
    
    func showActionSheet(_ str: String) {
    
        let actionSheet = UIAlertController(title: "Code", message: str, preferredStyle: UIAlertController.Style.actionSheet)
        
        let action1 = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //実際の処理
            self.presentEntryViewController(str: str)
            print("表示させたいタイトル1の処理")
            
        })
        
        let action2 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        
        //実際にAlertを表示する
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func presentEntryViewController(str: String) {
        let vc = EntryViewController()
        vc.code = str
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
