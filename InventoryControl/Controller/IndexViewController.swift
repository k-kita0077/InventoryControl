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
                if let goods = data["goods"], let val = data["val"] {
                    let list: [AnyObject] = [goods, val]
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
    
    
}
