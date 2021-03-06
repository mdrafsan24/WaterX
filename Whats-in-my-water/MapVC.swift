//
//  MapVC.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 3/10/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import MapKit
import QuartzCore
import Alamofire

class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var numBlueGreen: Int!
    var numRedBrown: Int!
    var warnings = [Warnings]()
    var coordinateUser = CLLocation()
    override func viewDidLoad() {
        super.viewDidLoad() // Processor when switch between -> we may change the defination from double to float !
        numBlueGreen = 0
        numRedBrown = 0
        self.mapView.layer.cornerRadius = 10.0;
        determineMyCurrentLocation()
        warnings = [Warnings]()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    func determineMyCurrentLocation() {
        warnings = [Warnings]()
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
        warnings = [Warnings]()
        numBlueGreen = 0
        numRedBrown = 0
        locationManager.stopUpdatingLocation()
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if error != nil {
                print("Error getting the state name")
            } else {
                
                let placeArray = placemarks as [CLPlacemark]!
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                print(placeMark.administrativeArea!)
                let distancespan:CLLocationDegrees = 2000
                let latitude = userLocation.coordinate.latitude
                let longitude = userLocation.coordinate.longitude
                
                self.coordinateUser = CLLocation(latitude: latitude, longitude: longitude)
                
                self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude, longitude), distancespan, distancespan), animated: true)
                
                /// WE CAN EDIT A LOT OF THE STUFF HERE
                DataServices.ds.REF_USERDATABASE.observe(FIRDataEventType.value, with: { (snapshot) in
                    self.numBlueGreen = 0
                    self.numRedBrown = 0
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            self.warnings = [Warnings]()
                            print(snap)
                            if let input = snap.value as? Dictionary<String,Any> {
                                
                                let locationToPin: CLLocationCoordinate2D = CLLocationCoordinate2DMake(input["latitude"] as! CLLocationDegrees, input["longitude"] as! CLLocationDegrees)
                                
                                let MapPin = Map(title: input["complaint"] as! String, subtitle: input["supplierName"] as! String, coordinate: locationToPin)
                                
                                self.mapView.addAnnotation(MapPin)
                                let coordinatePin = CLLocation(latitude: input["latitude"] as! CLLocationDegrees, longitude: input["longitude"] as! CLLocationDegrees)
                                let distanceInMeters = self.coordinateUser.distance(from: coordinatePin)
                                
                                // ^^ Goes through each lat and long and checks distance (in the snaps)
                                
                                if (distanceInMeters < 2000) {
                                    if let complaint = input["complaint"] as? String {
                                        let newComplaint = complaint.lowercased()
                                        if (newComplaint.range(of: "blue") != nil) || (newComplaint.range(of: "green") != nil) {
                                            self.numBlueGreen = (self.numBlueGreen+1)
                                        }
                                        if (newComplaint.range(of: "red") != nil) || (newComplaint.range(of: "brown") != nil) {
                                            self.numRedBrown = (self.numRedBrown+1)
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    self.mapView.reloadInputViews()
                    self.tableView.reloadData()
                })
                DataServices.ds.REF_SMSDATABASE.observe(FIRDataEventType.value, with: { (snapshot) in
                    self.numBlueGreen = 0
                    self.numRedBrown = 0
                    var zip = String()
                    var complaintTOSend = String()
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            
                            if let data = snap.children.allObjects as? [FIRDataSnapshot] {
                                if let zipData = data[0].value as? Dictionary<String, Any>{
                                    if let zipCode = zipData["ZipCode"] as? String {
                                        zip = zipCode
                                    }
                                }
                                if let complaintData = data[1].value as? Dictionary<String, Any> {
                                    if let complaint = complaintData["Complaint"] as? String {
                                        complaintTOSend = complaint
                                        let newComplaint = complaintTOSend.lowercased()
                                        
                                        if (newComplaint.range(of: "blue") != nil) || (newComplaint.range(of: "green") != nil) {
                                            self.numBlueGreen = (self.numBlueGreen+1)
                                        }
                                        if (newComplaint.range(of: "red") != nil) || (newComplaint.range(of: "brown") != nil) {
                                            self.numRedBrown = (self.numRedBrown+1)
                                            
                                        }
                                    }
                                }
                                self.alamofireService(zipCode: zip, complaint: complaintTOSend)
                            }
                        
                        }
                        //self.alamofireService(zipCode: zip, complaint: complaintTOSend)
                        
                    }
                    if (self.numBlueGreen > 0) {
                        self.warnings.append(Warnings(warning: "\(self.numBlueGreen!) complaints in your area correlate to an increased copper level. Please check in with your supplier"))
                        self.warnings.append(Warnings(warning: "\(self.numBlueGreen!) complaints in your area indidcates that there might be some issues with copper plumbing or brass fittings. Please contact your water supplier immideately!"))
                        
                    }
                    if (self.numRedBrown > 0) {
                        self.warnings.append(Warnings(warning: "\(self.numRedBrown!) complaints correlate to an increased iron or manganese level. Please check in with your supplier"))
                    }
                    self.mapView.reloadInputViews()
                    self.tableView.reloadData()
                })
                //print("THIS IS THE USERS STATE: \(placeMark.administrativeArea!)")
                
                //DataServices.ds.state = placeMark.administrativeArea!
            }
        }
        //print("user latitude = \(userLocation.coordinate.latitude)")
        //print("user longitude = \(userLocation.coordinate.longitude)")
    }
    func alamofireService(zipCode: String, complaint: String) { // ONLY FOR OHIO FOR NOW
        
        Alamofire.request("https://www.zipcodeapi.com/rest/po0UFq25mHXa24h5me8ckkKMjh66LkeaIf4nG7t2PqdRuuXRJ544qOQJ6WQRg52Z/info.json/\(zipCode)/degrees").responseJSON { response in
            
            if let JSON = response.result.value as? Dictionary <String,Any> {
                let locationToPin: CLLocationCoordinate2D = CLLocationCoordinate2DMake((JSON["lat"] as? CLLocationDegrees)!, (JSON["lng"] as? CLLocationDegrees)!)
                
                let MapPin = Map(title: complaint, subtitle: "Phone", coordinate: locationToPin)
                
                self.mapView.addAnnotation(MapPin)
                let coordinatePin = CLLocation(latitude: JSON["lat"] as! CLLocationDegrees, longitude: JSON["lng"] as! CLLocationDegrees)
                let distanceInMeters = self.coordinateUser.distance(from: coordinatePin)
                
                if (distanceInMeters < 5000) {
                    //self.warnings.append(Warnings(warning: complaint))
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
        self.mapView.reloadInputViews()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.warnings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let warning = warnings[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "warningCell") as? WarningCell {
            
            cell.configureCell(warning: warning)
            return cell
        } else {
            return WarningCell()
        }
    }
    
}
