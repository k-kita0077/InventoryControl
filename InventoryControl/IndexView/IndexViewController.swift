//
//  IndexViewController.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/06/30.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

class IndexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var indexViewTableView: UITableView!
    
    var databaseRef: DatabaseReference!
    
    var goodsList: [GoodsInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
        
        
        
        indexViewTableView.delegate = self
        indexViewTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableViewCell()
        
        let userRef = databaseRef.child(AccountManager.LoginUid)
        
        goodsList = []
        userRef.observe(.childAdded, with: {snapshot in
            if let data = snapshot.value as? Dictionary<String, AnyObject> {
                if let goods = data["goods"], let val = data["val"], let SKU = data["SKU"], let key = data["key"], let code = data["code"] {
                    let goodsInfo: GoodsInfo = GoodsInfo(goods: goods, val: val, SKU: SKU, key: key, code: code)
                    self.goodsList.append(goodsInfo)
                }
            }
            self.indexViewTableView.reloadData()
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(goodsList.count)
        return goodsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsID", for: indexPath) as! GoodsTableViewCell
        cell.goodsLabel.text = goodsList[indexPath.row].goods
        cell.valLabel.text = goodsList[indexPath.row].val
        
        let userRef = self.getUserRef(goodsList[indexPath.row].SKU)
        let placeholderImage = UIImage(systemName: "photo")
        cell.cellImage.sd_setImage(with: userRef, placeholderImage: placeholderImage)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EntryViewController()
        vc.code = self.goodsList[indexPath.row].code
        vc.goodsList = self.goodsList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //スワイプアクション
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 削除のアクションを設定する
        let deleteAction = UIContextualAction(style: .destructive, title:"delete") {
            (ctxAction, view, completionHandler) in
            let key = self.goodsList[indexPath.row].key
            self.databaseRef.child(AccountManager.LoginUid).child(key).removeValue()
            
            self.goodsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        // 削除ボタンのデザインを設定する
        let trashImage = UIImage(systemName: "trash.fill")?.withTintColor(UIColor.white , renderingMode: .alwaysTemplate)
        deleteAction.image = trashImage
        deleteAction.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        
        // スワイプでの削除を無効化して設定する
        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        
        return swipeAction
        
    }
}
