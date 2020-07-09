//
//  IndexViewController.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/06/30.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit
import FirebaseDatabase

class IndexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var indexViewTableView: UITableView!
    
    var databaseRef: DatabaseReference!
    
    var goodsList: [[AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
        
        configureTableViewCell()
        
        let userRef = databaseRef.child(AccountManager.LoginUid)
        
        goodsList = []
        userRef.observe(.childAdded, with: {snapshot in
            if let data = snapshot.value as? Dictionary<String, AnyObject> {
                if let goods = data["goods"], let val = data["val"], let SKU = data["SKU"], let key = data["key"], let code = data["code"] {
                    let list: [AnyObject] = [goods, val, SKU, key, code]
                    self.goodsList.append(list)
                    print(self.goodsList)
                }
            }
            self.indexViewTableView.reloadData()
        })
        
        indexViewTableView.delegate = self
        indexViewTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(goodsList.count)
        return goodsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsID", for: indexPath) as! GoodsTableViewCell
        cell.goodsLabel.text = goodsList[indexPath.row][0] as? String
        cell.valLabel.text = goodsList[indexPath.row][1] as? String
         
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func configureTableViewCell() {
        let nib = UINib(nibName: "GoodsTableViewCell", bundle: nil)
        let cellID = "GoodsID"
        
        indexViewTableView.register(nib, forCellReuseIdentifier: cellID)
        
    }
    
    //スワイプアクション
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 削除のアクションを設定する
        let deleteAction = UIContextualAction(style: .destructive, title:"delete") {
            (ctxAction, view, completionHandler) in
            let key = self.goodsList[indexPath.row][3] as! String
            self.databaseRef.child(AccountManager.LoginUid).child(key).removeValue()
            //tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        // 削除ボタンのデザインを設定する
        let trashImage = UIImage(systemName: "trash.fill")?.withTintColor(UIColor.white , renderingMode: .alwaysTemplate)
        deleteAction.image = trashImage
        deleteAction.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        
        let shareAction = UIContextualAction(style: .normal  , title: "comp") {
            (ctxAction, view, completionHandler) in
            let vc = EntryViewController()
            vc.code = self.goodsList[indexPath.row][4] as! String
            vc.goodsList = self.goodsList[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            completionHandler(true)
        }
        // 完了ボタンのデザインを設定する
        let shareImage = UIImage(systemName: "checkmark.shield.fill")?.withTintColor(UIColor.white, renderingMode: .alwaysTemplate)
        shareAction.image = shareImage
        shareAction.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 255/255, alpha: 1)
        
        // スワイプでの削除を無効化して設定する
        let swipeAction = UISwipeActionsConfiguration(actions:[shareAction, deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        
        return swipeAction
        
    }
}
