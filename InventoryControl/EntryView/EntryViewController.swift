//
//  EntryViewController.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/07/01.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

class EntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var SKULabel: UILabel!
    @IBOutlet weak var goodsField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var valField: UITextField!
    @IBOutlet var EntryView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var code: String = ""
    var SKUnum: Int = 1
    
    var goodsList: GoodsInfo?
    
    var userDefaultKey: String = "SKUKey"
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //アカウントごとにkeyを変える
        let user = AccountManager.LoginUid
        userDefaultKey = user + userDefaultKey
        
        valField.keyboardType = UIKeyboardType.numberPad
        databaseRef = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    //キーボードを隠す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if code == "" {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        if let item = goodsList {
            //indexから遷移した時
            SKULabel.text = item.SKU
            goodsField.text = item.goods
            codeLabel.text = item.code
            valField.text = item.val
            let userRef = self.getUserRef(item.SKU)
            self.downloadFromCloudStorage(userRef: userRef)
        } else {
            //scanから遷移した時
            let skunum: Int = UserDefaults.standard.integer(forKey: userDefaultKey)
            SKUnum = skunum + 1
            SKULabel.text = String(SKUnum)
            //読み取ったコードの値
            codeLabel.text = code
        }
        
        
        
    }
    
    @IBAction func tapEntryButton(_ sender: Any) {
        if let item = goodsList {
            //indexから遷移した時
            let updateKey = item.key
            let sku = item.SKU
            if let goods = goodsField.text, let val = valField.text, let inputCode = codeLabel.text {
                let goodsData = ["SKU": sku, "goods": goods, "code": inputCode, "val": val, "key": updateKey] as [String : Any]
                
                databaseRef.child(AccountManager.LoginUid).child(updateKey).setValue(goodsData)
                
                //Cloud Storageへアップロード
                self.uploadToCloudStorage(sku)
                
                goodsField.text = ""
                valField.text = ""
                code = ""
                
                self.navigationController?.popViewController(animated: true)
//                let vc = tabBarController?.viewControllers?[0];
//                tabBarController?.selectedViewController = vc
            }
        } else {
            //scanから遷移した時
            guard let key = databaseRef.child(AccountManager.LoginUid).childByAutoId().key else { return }
            if let goods = goodsField.text, let val = valField.text, let inputCode = codeLabel.text {
                let goodsData = ["SKU": String(SKUnum), "goods": goods, "code": inputCode, "val": val, "key": key]
                
                databaseRef.child(AccountManager.LoginUid).child(key).setValue(goodsData)
                
                //Cloud Storageへアップロード
                self.uploadToCloudStorage(String(SKUnum))
                
                goodsField.text = ""
                valField.text = ""
                code = ""
                
                UserDefaults.standard.set(SKUnum, forKey: userDefaultKey)
                //self.navigationController?.popToRootViewController(animated:false)
                
                let vc = tabBarController?.viewControllers?[1];
                tabBarController?.selectedViewController = vc
            }
        }
        
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tapImageView(_ sender: Any) {
        print("🌞 imageView をタップしたよ")
        
        // アクションシートを表示する
        let alertSheet = UIAlertController(title: nil, message: "選択してください", preferredStyle: .actionSheet)
        //カメラを選んだとき
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { action in
            print("カメラが選択されました")
            self.presentPicker(sourceType: .camera)
        }
        //アルバムを選んだとき
        let albumAction = UIAlertAction(title: "アルバムから選択", style: .default) { action in
            print("アルバムが選択されました")
            self.presentPicker(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in
        }
        print("キャンセルが選択されました")
        alertSheet.addAction(cameraAction)
        alertSheet.addAction(albumAction)
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true)
    }
    
    //アルバムとカメラの画面を生成する関数
    func presentPicker(sourceType:UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            //ソースタイプが利用できるとき
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            //デリゲート先に自らのクラスを指定
            picker.delegate = self
            //画面を表示する
            present(picker, animated: true, completion: nil)
        } else {
            print("The SourceType is not found")
        }
    }
    
    //撮影もしくは画像を選択したら呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("撮影もしくは画像を選択したよ！")
        
        if let pickedImage = info[.originalImage] as? UIImage{
            //撮影or選択した画像をimageViewの中身に入れる
            imageView.image = pickedImage.resize(toWidth: 200)
            imageView.contentMode = .scaleAspectFit
        }
        //表示した画面を閉じる処理
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Cloud Storageへアップロード
    func uploadToCloudStorage(_ sku: String){
        
        guard let data = self.imageView.image?.pngData() else {return}
        
        let meta = StorageMetadata()
        meta.contentType = "image/png"
        
        let userRef = self.getUserRef(sku)
        
        userRef.putData(data, metadata: meta) { (metadata, err) in
            guard let metadata = metadata else {
                print("upload error")
                return
            }
            
            let size = metadata.size
            //アップロード時の画像のサイズ
            print("\(size):size")
            
            //画像アップ時に端末のキャッシュ削除することで、画像変更時の反映が素早くなる（SDWebImageはFirebaseUIが採用しているライブラリ）
            SDImageCache.shared.clearMemory()
            SDImageCache.shared.clearDisk()
      }
    }
    
    //CloudStorageからダウンロードしてくる関数
    func downloadFromCloudStorage(userRef:StorageReference){
        //placeholderの役割を果たす画像をセット
        let placeholderImage = UIImage(systemName: "photo")
        //読み込み
        self.imageView.sd_setImage(with: userRef, placeholderImage: placeholderImage)
    }
}

extension UIImage {
    //画像をリサイズする処理
    func resize(toWidth width:CGFloat) ->UIImage?{
        //描画するサイズを指定
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        //Contextを開始
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        //遅延実行(defer内部で書かれた処理は、スコープを抜けるときに呼ばれる）
        defer {
            //Contextを終了
            UIGraphicsEndImageContext()
        }
        //指定されたサイズのCGRectで描画
        draw(in: CGRect(origin: .zero, size: canvasSize))
        //リサイズされた画像を戻り値として返す
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIViewController{
    
    func getUserRef(_ sku: String) -> StorageReference{
        let storage = Storage.storage()
        //ルートのレファレンスを作成
        let storageRef = storage.reference()
        let user = AccountManager.LoginUid
        
        let userRef = storageRef.child("user/\(user)goodsImages/\(sku).png")
        return userRef
    }
}
