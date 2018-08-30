//
//  ViewController.swift
//  Mappies
//
//  Created by Hanafi Hisyam on 23/08/2018.
//  Copyright © 2018 Hanafi Hisyam. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var vMap: GMSMapView!
    @IBOutlet weak var lblCurrentLocation: UILabel!
    @IBOutlet weak var lblYouAreIn: UILabel!
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    
    let networkController = NetworkController()
    let locationManager = CLLocationManager()
    
    var area = [Area]()
    var coordinatesMarker = [CLLocationCoordinate2D]()
    var polygon = GMSPolygon()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        freshObject()
        forViewDidLoad()
        //loadDataFromJson()
    }

    @IBAction func btnHelp_TouchUpInside(_ sender: Any) {
        Freshchat.sharedInstance().showConversations(self)
    }
    
    @IBAction func btnZoonMarker_TouchUpInside(_ sender: Any) {
        cameraZoomToMarker(coordinate: coordinatesMarker.last!)
    }
    
    func cameraZoomToMarker(coordinate: CLLocationCoordinate2D) {
        vMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
    }
    
    func forViewDidLoad() {
        lblCurrentLocation.text = ""
        lblLongitude.text = ""
        lblLatitude.text = ""
        
        if lblLatitude.text == "" && lblLongitude.text == "" {
            lblYouAreIn.text = "Please tap the map!"
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        vMap.delegate = self
    }
    
    func freshObject(){
        let user = FreshchatUser.sharedInstance()
        
        user?.firstName = "Mohd Hanafi"
        user?.lastName = "Hisyam"
        user?.email = "test_mohdhanaifhisyam@telepod.com"
        user?.phoneCountryCode="65"
        user?.phoneNumber = "97778888"
        
        Freshchat.sharedInstance().setUser(user)
        Freshchat.sharedInstance().setUserPropertyforKey("customerType", withValue: "Premium")
        Freshchat.sharedInstance().setUserPropertyforKey("city", withValue: "San Bruno")
        Freshchat.sharedInstance().setUserPropertyforKey("loggedIn", withValue: "true")
        Freshchat.sharedInstance().setUserPropertyforKey("transactionCount", withValue: "3")
        Freshchat.sharedInstance().unreadCount { (count:Int) -> Void in
            print("Unread count (Async) :\(count)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name(FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED), object: nil)
        func methodOfReceivedNotification(notification: Notification){
            print(notification.userInfo!["count"] as! Int)
        }
    }
    
    @objc func methodOfReceivedNotification(notification: NotificationCenter) { }
    
    func reverseGeocodeCoordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if let city = placeMark.name {
                self.lblCurrentLocation.text = city
            }
        })
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func loadDataFromJson() {
        networkController.getDetails { (area) in
            self.area = area!
            
            var geoJson = [String]()
            var placeName = [String]()
            var result = [String:Any]()
            for value in self.area {
                geoJson.append(value.geojson)
                result = self.convertToDictionary(text: value.geojson)!
                placeName.append(value.pln_area_n)
                print(result)
            }
        }
    }
    
    func createPolygon(){
        let path = GMSMutablePath()
        for coordinate in coordinatesMarker{
            path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        path.add(CLLocationCoordinate2D(latitude: coordinatesMarker[0].latitude, longitude: coordinatesMarker[0].longitude))
        
        polygon = GMSPolygon(path: path)
        polygon.strokeColor = UIColor.red
        polygon.strokeWidth = 2.0
        polygon.map = vMap
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        locationManager.startUpdatingLocation()
        vMap.isMyLocationEnabled = true
        vMap.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        vMap.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
      
        locationManager.stopUpdatingLocation()
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        vMap.clear()
        
        lblLatitude.text = "\(coordinate.latitude)"
        lblLongitude.text = "\(coordinate.longitude)"
        lblYouAreIn.text = "Location tapped at:"
        reverseGeocodeCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let marker = GMSMarker(position: coordinate)
        marker.title = lblCurrentLocation.text
        marker.map = vMap
        coordinatesMarker.append(coordinate)
//        createPolygon()
    }
}
