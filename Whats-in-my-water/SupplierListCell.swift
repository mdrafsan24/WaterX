//
//  SupplierListCell.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 2/11/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase

class SupplierListCell: UITableViewCell {

    @IBOutlet weak var supplierName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func configureCell(name: SupplierNames) {
        self.supplierName.text = name.supplierName
    }

    
}
