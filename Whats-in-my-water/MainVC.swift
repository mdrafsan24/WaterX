//
//  ViewController.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 2/11/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Alamofire
class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager!
    var state: String!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var waterSupplier: UILabel!
    var thingsToSend = [String]() // ARRAY OF THINGS TO SEND
    var supplierNames = [SupplierNames]() //Array of supplier names
    var _whichState: [String:FIRDatabaseReference] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _whichState = ["OH" : DataServices.ds.REF_SUPPLIERNAMES_OH, "NY" : DataServices.ds.REF_SUPPLIERNAMES_NY]
        tableView.delegate = self
        tableView.dataSource = self
        determineMyCurrentLocation() //FOR BOTH OH & NY ONLY
        //alamofireService() // FOR OHIO ONLY

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //determineMyCurrentLocation() // calls determine function
    }
    func firebaseService(state: String) {
        self._whichState["\(state)"]?.observe(FIRDataEventType.value, with: { (snapshot) in
            
            self.supplierNames = [SupplierNames]()
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    //print("These are individual snaps \(snap)")
                    
                    if let supplier = snap.value as? String {
                        let supplierName = SupplierNames(name: supplier)
                        self.supplierNames.append(supplierName)
                    }
                }
                
            }
            self.tableView.reloadData()
        })
    }
    
    func alamofireService() { // ONLY FOR OHIO FOR NOW
        Alamofire.request("https://api.myjson.com/bins/kd7p1").responseJSON { response in
            
            if let JSON = response.result.value as? Dictionary <String,Any> {
                if let items = JSON["items"] as? [Any] {
                    for item in items {
                        if let advisory = item as? Dictionary<String, Any> {
                            let supplierName = SupplierNames(name: advisory["County"] as! String)
                            self.supplierNames.append(supplierName)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 5;
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        manager.stopUpdatingLocation()
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if error != nil {
                print("Error getting the state name")
            } else {
                let placeArray = placemarks as [CLPlacemark]!
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                self.waterSupplier.text = ("Who is you water supplier in \(placeMark.administrativeArea!) state?")
                self.state = placeMark.administrativeArea!
                print(placeMark.administrativeArea!)
                self.firebaseService(state: placeMark.administrativeArea!)//
                //print("THIS IS THE USERS STATE: \(placeMark.administrativeArea!)")
                
                //DataServices.ds.state = placeMark.administrativeArea!
            }
        }
        //print("user latitude = \(userLocation.coordinate.latitude)")
        //print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supplierNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let nameOfSupplier = supplierNames[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "supplierName") as? SupplierListCell {
            cell.backgroundColor = UIColor.clear
            cell.configureCell(name: nameOfSupplier)
            return cell
        } else {
            return SupplierListCell()
        }
        
        
    }
 
    @IBAction func supplierClicked(_ sender: Any) {
        let clickPos: CGPoint = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: clickPos)! as NSIndexPath
        
        let supplierId = String(indexPath.row)
        thingsToSend = [supplierId, state]
        performSegue(withIdentifier: "goToDetails", sender: thingsToSend)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailsVC {
            if let thingsToSend = sender as? [String] {
                destination.thingsReceived = thingsToSend
            }
        }
    }

}

