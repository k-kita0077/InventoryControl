//
//  GoodsTableViewCell.swift
//  InventoryControl
//
//  Created by kita kensuke on 2020/07/03.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit

class GoodsTableViewCell: UITableViewCell {

    @IBOutlet weak var goodsLabel: UILabel!
    @IBOutlet weak var valLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
