//
//  UploadViewController.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 3/7/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
class UploadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var thankYou: UILabel!
    @IBOutlet weak var selectionLbl: UILabel!

    @IBOutlet weak var selected: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var complaintTextFld: UITextField!
    private var _disease: String!
    private var _latitude: Double!
    private var _longitude: Double!
    private var _complaint: String!
    var diseaseNamesAsString = [String]()
    var locationManager: CLLocationManager!
    // Necesarry location variables
    private var _nameOfSupplier = String()
    var nameOfSupplier: String {
        get {
            return _nameOfSupplier
        } set {
            _nameOfSupplier = newValue
        }
    }
    
    var diseaseNames = [DiseaseName]() // Array of water borne diseases
    override func viewDidLoad() {
        super.viewDidLoad()
        diseaseNamesAsString = [String]()
        self.diseaseNames = [DiseaseName]()
        self.complaintTextFld.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        determineMyCurrentLocation()
        
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func firebaseService() {
        self.diseaseNames = [DiseaseName]()
        DataServices.ds.REF_DISEASENAME.observe(FIRDataEventType.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let disease = snap.value as? String {
                        print(disease)
                        //let diseaseName = DiseaseName(name: disease)
                        self.diseaseNames.append(DiseaseName(name: disease))
                        self.diseaseNamesAsString.append(disease)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.complaintTextFld.resignFirstResponder()
        return true
    }
    @IBAction func postButton(_ sender: Any) {
        //let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("UserInputDatabase").childByAutoId().key
        
        let userInput = ["complaint" : self.complaintTextFld.text!,
                         "disease" : self._disease!,
                         "latitude" : self._latitude,
                         "longitude" : self._longitude,
                         "supplierName" : self._nameOfSupplier
                         ] as [String : Any]
        // REMEBER TO PUT "complaint" : self.complaintTextFld.text!,
        let postFeed = ["\(key)" : userInput]
        ref.child("UserInputDatabase").updateChildValues(postFeed)
        self.thankYou.isHidden = false
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.thankYou.isHidden = true
        }
        
    }
    
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 10;
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            locationManager.stopUpdatingLocation()
        }
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
                print(placeMark.administrativeArea!)
                self._latitude = userLocation.coordinate.latitude
                self._longitude = userLocation.coordinate.longitude
                self.firebaseService()//
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
        return diseaseNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nameOfDisease = diseaseNames[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "diseaseCell") as? DiseaseCell {
            cell.configureCell(name: nameOfDisease)
            return cell
        } else {
            return DiseaseCell()
        }
    }
    
    
    @IBAction func diseaseClicked(_ sender: Any) {

        let clickPos: CGPoint = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: clickPos)! as NSIndexPath
        self.selectionLbl.text = "You selected \(self.diseaseNamesAsString[indexPath.row])"
        self._disease = self.diseaseNamesAsString[indexPath.row]
    }
}
    
    
    
    
    

