//
//  DetailsVC.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 2/11/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import UIKit
import Firebase
class DetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var _contaminants = [String]()
    private var _levels = [String]()
    private var _descriptions = [String]()
    private var _supplierId = String()
    private var _supplierName: String!
    private var _supplierList = [String]()
    private var _doneDownloading: Bool!
    private var _stateFromBefore = String()
    var contaminants = [Contaminants]()
    private var _thingsReceived = [String] ()
    
    var thingsReceived: [String] {
        get {
            return _thingsReceived
        } set {
            _thingsReceived = newValue
        }
    }
    
    var supplierId: String {
        return _supplierId
    }
    
    var _whichSupplier: [String:FIRDatabaseReference] = [:]
    var _insideSupplier: [String:FIRDatabaseReference] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        _supplierId = thingsReceived[0]
        _stateFromBefore = thingsReceived[1]
        _whichSupplier = ["OH" : DataServices.ds.REF_SUPPLIERNAMES_OH, "NY" : DataServices.ds.REF_SUPPLIERNAMES_NY, "MI" : DataServices.ds.REF_SUPPLIERNAMES_MI] // ACTUALLY THE STATE
        _insideSupplier = ["OH" : DataServices.ds.REF_OH, "NY" : DataServices.ds.REF_NY, "MI" : DataServices.ds.REF_MI] // NOW INSIDE SUPPLIER

        self.completeDataserviceFirebase() //-> FOR NY ONLY
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

    
    
    func completeDataserviceFirebase() {
        print("GOT TO completeDataserviceFirebase")
        DataService() {
            print("DONE DOWNLOADING")
            self._supplierName = self._supplierList[Int(self.supplierId)!]
            print("YOU CHOOSE \(self._supplierList[Int(self.supplierId)!])")
            
            self.contamDone() {
                self.levelDone() {
                    self.descDone() {
                        
                        /*let contam = Contaminants(level: self._levels, description: self._descriptions, nameOfSubstance: self._contaminants)
                         self.contaminants.append(contam)*/
                        //print(self.contaminants.count)
                        //print(self._contaminants.count) // Checks out !
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    func DataService(completed: @escaping DataServices.DownloadComplete) {
        print("THIS IS THE STATE FROM BEFORE \(self._stateFromBefore)")
        self._whichSupplier["\(_stateFromBefore)"]?.observe(FIRDataEventType.value, with: { (snapshot) in
            
            print("I got here \(self.supplierId)")
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    self._supplierList.append((snap.value as? String!)!)
                    
                }
                //print("DONE MAKING THE LIST")
                self._doneDownloading = true
            }
            completed()
        })
        

    }
    
    func contamDone (completed: @escaping DataServices.DownloadComplete) {
        let dataBaseURL = self._insideSupplier["\(_stateFromBefore)"]?.child(self._supplierList[Int(self.supplierId)!])
        
        dataBaseURL?.child("Contaminants").observe(FIRDataEventType.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let contaminant = snap.value as? String {
                        self._contaminants.append(contaminant)
                    }
                }
                //Contaminants(nameOfSubstance: self._contaminants)
            }
            completed()
        })
    }
    func descDone (completed: @escaping DataServices.DownloadComplete) {
        let dataBaseURL = self._insideSupplier["\(_stateFromBefore)"]?.child(self._supplierList[Int(self.supplierId)!])
        
        dataBaseURL?.child("Descriptions").observe(FIRDataEventType.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let description = snap.value as? String {
                        self._descriptions.append(description)
                    }
                }
                //Contaminants(description: self._descriptions)
            }
            completed()
        })
    }
    func levelDone (completed: @escaping DataServices.DownloadComplete) {
        let dataBaseURL = self._insideSupplier["\(_stateFromBefore)"]?.child(self._supplierList[Int(self.supplierId)!])
        
        dataBaseURL?.child("Level").observe(FIRDataEventType.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let level = snap.value as? String {
                        self._levels.append(level)
                    }
                }
                //Contaminants(level: self._levels)
            }
            completed()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _contaminants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contamName = _contaminants[indexPath.row]
        let contamLevel = _levels[indexPath.row]
        let contemDesc = _descriptions[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contamCell") as? ContaminantCell {
            cell.configureCell(contamName: contamName, contamLevel: contamLevel, contamDesc: contemDesc)
            return cell
        } else {
            return ContaminantCell()
        }
    }
    
    @IBAction func userInput(_ sender: Any) {
        performSegue(withIdentifier: "goToUser", sender: self._supplierName)
    }
    @IBAction func goHomePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UploadViewController {
            if let thingsToSend = sender as? String {
                destination.nameOfSupplier = thingsToSend
            }
        }
    }

    
}
