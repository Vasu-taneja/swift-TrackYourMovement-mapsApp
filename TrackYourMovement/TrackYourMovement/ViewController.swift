//
//  ViewController.swift
//  TrackYourMovement
//
//  Created by user197526 on 7/1/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {
//Label outlets
    @IBOutlet weak var currentSpeedOutputLabel: UILabel!
    @IBOutlet weak var averageSpeedOutputLabel: UILabel!
    @IBOutlet weak var maxSpeedOutputLabel: UILabel!
    @IBOutlet weak var maxAccelarationOutputLabel: UILabel!
    @IBOutlet weak var distanceOutputLabl: UILabel!
    @IBOutlet weak var overSpeedAlert: UILabel!
    @IBOutlet weak var inSpeedLimit: UILabel!
    
    
    @IBOutlet weak var mapViewOutlet: MKMapView!
    
    //variables
    var locationUpdateManager: CLLocationManager!
    var initialLocation: CLLocation!
    var recentLocation: CLLocation!
    var speedTotal: Double = 0.0
    var recordedSpeedCount:Double = 0.0
    var maxSpeed: Double = 0.0
    var avgSpeed: Double = 0.0
    var maxAcceleration: Double = 0.0
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMapView()
    }
    
    
    
    func setMapView() {
        locationUpdateManager = CLLocationManager()
        locationUpdateManager.delegate = self
        mapViewOutlet.showsUserLocation = true
        mapViewOutlet.delegate = self
        mapViewOutlet.mapType = .standard
        mapViewOutlet.isZoomEnabled = true
        mapViewOutlet.isScrollEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func startTripBtn(_ sender: Any) {
        let authStatus: CLAuthorizationStatus = locationUpdateManager.authorizationStatus
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse{
            locationUpdateManager.startUpdatingLocation()
            initialLocation = locationUpdateManager.location
            inSpeedLimit.backgroundColor = .green
            recentLocation = locationUpdateManager.location
        }else if authStatus ==  .notDetermined{
            locationUpdateManager.requestAlwaysAuthorization()
        }
        else{
            print("Location Access: \(authStatus.rawValue)")
        }
    }
    
    @IBAction func stopTrip() {
        locationUpdateManager.stopUpdatingLocation()
        inSpeedLimit.backgroundColor = .gray
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last!
    
        //speed conversion
        let speed = (lastLocation.speed) * 3.6
        let distance = (lastLocation.distance(from: initialLocation)) * 0.001
 
        if speed > maxSpeed{
            maxSpeed = speed
        }
        
        speedTotal = speedTotal + speed
        recordedSpeedCount = recordedSpeedCount + 1
        avgSpeed = speedTotal/recordedSpeedCount
        
        let locationCoordinates = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        let updateRegion = MKCoordinateRegion(center: locationCoordinates, latitudinalMeters: 100, longitudinalMeters: 100)
        mapViewOutlet.setRegion(updateRegion, animated: true)
                
        if speed > 115{
            overSpeedAlert.backgroundColor = .red
        }
        else{
            overSpeedAlert.backgroundColor = .gray
        }
        //speed differnce for accelaration
        let speedDifference = lastLocation.speed - recentLocation.speed
        //time difference for accelaration
        let timeDifference = lastLocation.timestamp.timeIntervalSince(recentLocation.timestamp)
        let currentAcceleration = speedDifference/timeDifference
                
        if currentAcceleration > maxAcceleration{
            maxAcceleration = currentAcceleration
        }
        
        currentSpeedOutputLabel.text = String(format: "%.2f km/hr", speed)
        distanceOutputLabl.text = String(format: "%.2f km", distance)
        maxAccelarationOutputLabel.text = String(format: "%.2f km/hr", maxSpeed)
        averageSpeedOutputLabel.text = String(format: "%.2f km/hr", avgSpeed)
        maxSpeedOutputLabel.text = String(format: "%.2f m/s^2", abs(maxAcceleration))
        recentLocation = lastLocation
                
    }
}

