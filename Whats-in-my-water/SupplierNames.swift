//
//  SupplierNames.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 2/11/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import Foundation

class SupplierNames {
    
    private var _supplierName: String!
    
    var supplierName: String {
        if _supplierName != nil {
            return _supplierName
        }
        return ""
    }
    
    init (name: String){
        self._supplierName = name
    }
    
    
    
    
}
