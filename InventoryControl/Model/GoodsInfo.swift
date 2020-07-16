//
//  GoodsInfo.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/07/16.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import Foundation

class GoodsInfo {
    var goods: String
    var val: String
    var SKU: String
    var key: String
    var code: String
    
    init(goods: AnyObject, val: AnyObject, SKU: AnyObject, key: AnyObject, code: AnyObject) {
        self.goods = goods as! String
        self.val = val as! String
        self.SKU = SKU as! String
        self.key = key as! String
        self.code = code as! String
    }
}
