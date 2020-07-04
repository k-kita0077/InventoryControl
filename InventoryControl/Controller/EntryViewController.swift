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

    @IBOutlet weak var goodsField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var valField: UITextField!
    @IBOutlet var EntryView: UIView!
    
    
    var code: String = ""
    
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        //読み取ったコードの値
        codeLabel.text = code
        
    }
    
    @IBAction func tapEntryButton(_ sender: Any) {
        if let goods = goodsField.text, let val = valField.text, let inputCode = codeLabel.text {
            let goodsData = ["goods": goods, "code": inputCode, "val": val]
            databaseRef.child(AccountManager.LoginUid).childByAutoId().setValue(goodsData)
            
            goodsField.text = ""
            valField.text = ""
            code = ""
            
            //self.navigationController?.popToRootViewController(animated: true)
            
            let vc = tabBarController?.viewControllers?[1];
            tabBarController?.selectedViewController = vc
        }
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
