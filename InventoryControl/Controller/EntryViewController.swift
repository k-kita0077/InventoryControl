//
//  EntryViewController.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/07/01.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EntryViewController: UIViewController {

    @IBOutlet weak var SKULabel: UILabel!
    @IBOutlet weak var goodsField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var valField: UITextField!
    @IBOutlet var EntryView: UIView!
    
    var code: String = ""
    var SKUnum: Int = 1
    
    var goodsList: [AnyObject]?
    
    let userDefaultKey: String = "SKUKey"
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if !(goodsList?.isEmpty ?? true) {
            SKULabel.text = goodsList?[2] as? String
            goodsField.text = goodsList?[0] as? String
            codeLabel.text = goodsList?[4] as? String
            valField.text = goodsList?[1] as? String
        } else {
            let skunum: Int = UserDefaults.standard.integer(forKey: userDefaultKey)
            SKUnum = skunum + 1
            SKULabel.text = String(SKUnum)
            //読み取ったコードの値
            codeLabel.text = code
        }
        
        
        
    }
    
    @IBAction func tapEntryButton(_ sender: Any) {
        if !(goodsList?.isEmpty ?? true) {
            guard let updateKey = goodsList?[3] else {return}
            if let goods = goodsField.text, let val = valField.text, let inputCode = codeLabel.text {
                let goodsData = ["SKU": SKUnum, "goods": goods, "code": inputCode, "val": val, "key": updateKey] as [String : Any]
                
                databaseRef.child(AccountManager.LoginUid).child(updateKey as! String).setValue(goodsData)
                
                goodsField.text = ""
                valField.text = ""
                code = ""
                
                let vc = tabBarController?.viewControllers?[0];
                tabBarController?.selectedViewController = vc
            }
        } else {
            guard let key = databaseRef.child(AccountManager.LoginUid).childByAutoId().key else { return }
            if let goods = goodsField.text, let val = valField.text, let inputCode = codeLabel.text {
                let goodsData = ["SKU": SKUnum, "goods": goods, "code": inputCode, "val": val, "key": key] as [String : Any]
                
                databaseRef.child(AccountManager.LoginUid).child(key).setValue(goodsData)
                
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
    

}
