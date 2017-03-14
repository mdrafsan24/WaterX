//
//  DataServices.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 2/11/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference() //ROOT DB URL

//let STORAGE_BASE = FIRStorage.storage().reference() //ROOT Storage URL

class DataServices {
    
    private var _state: String!
    
    static let ds = DataServices() //Signle Instance of DB Class
    typealias DownloadComplete = () -> ()
    //DB References
    
    private var _REF_BASE = DB_BASE
    private var _REF_NY = DB_BASE.child("NewYorkState") // Into NYS Now
    private var _REF_OH = DB_BASE.child("OH") // Into NYS Now
    private var _REF_SUPPLIERNAMES_NY = DB_BASE.child("NewYorkState").child("SupplierNames")
    private var _REF_SUPPLIERNAMES_OH = DB_BASE.child("OH").child("SupplierNames")
    private var _REF_DISEASENAMES = DB_BASE.child("DiseaseList")
    private var _REF_USERDATABASE = DB_BASE.child("UserInputDatabase")
    // EDIT : private var _REF_SUPPLIERNAMES_OH = DB_BASE.child("OH").child("County") ******
    
    //Storage Reference
    // DO STORAGE REFERENCE STUFF HERE
    var state: String {
        get {
            return _state
        }
        set {
            self._state = newValue
        }
    }
    var REF_USERDATABASE: FIRDatabaseReference {
        return _REF_USERDATABASE
    }
    var REF_DISEASENAME: FIRDatabaseReference {
        return _REF_DISEASENAMES
    }
    var REF_SUPPLIERNAMES_NY: FIRDatabaseReference {
        return _REF_SUPPLIERNAMES_NY
    }
    var REF_SUPPLIERNAMES_OH: FIRDatabaseReference {
        return _REF_SUPPLIERNAMES_OH
    }
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_NY: FIRDatabaseReference {
        return _REF_NY
    }
    var REF_OH: FIRDatabaseReference {
        return _REF_OH
    }
    
    // DONE SO FAR
    
    
}
