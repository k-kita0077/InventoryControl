//
//  ViewController.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/06/30.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isLogin() == true{
            //ログイン状態のときはスキップ
            AccountManager.LoginUid = String(describing: Auth.auth().currentUser?.uid)
            print("\(String(describing: Auth.auth().currentUser?.uid)):ログインユーザーのユーザーID")
        } else {
            //まだログインしていないときはログイン画面表示
            self.presentLoginViewController()
        }
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // navigation barの設定
    private func setupNavigationBar() {
        //画面上部のナビゲーションバーの左側にログアウトボタンを設置し、押されたらlogOut関数が走るように設定
        let leftButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logOut))
        navigationItem.leftBarButtonItem = leftButtonItem
    }
    
    //ログアウト処理
    @objc func logOut(){
        do{
            try Auth.auth().signOut()
            //ログアウトに成功したら、ログイン画面を表示
            self.presentLoginViewController()
        } catch let signOutError as NSError{
            print("サインアウトエラー:\(signOutError)")
        }
    }
    
    //ログイン認証されているかどうかを判定する関数
    func isLogin() -> Bool{
        //ログインしているユーザーがいるかどうかを判定
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    func presentLoginViewController() {
        let vc = LoginViewController()
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc,animated: false,completion: nil)
    }
    
}

