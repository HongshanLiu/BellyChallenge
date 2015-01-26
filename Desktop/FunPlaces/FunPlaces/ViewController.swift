//
//  ViewController.swift
//  FunPlaces
//
//  Created by Hongshan Liu on 10/10/14.
//  Copyright (c) 2014 Hongshan Liu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    

    var manager: CLLocationManager!
    
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var annotationArray: [MKAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchView.placeholder = "search places by category (e.g. pizza)"
        searchView.showsScopeBar == true
        searchView.delegate = self

        manager = CLLocationManager()
        
        manager.requestAlwaysAuthorization()
        
        
        if (CLLocationManager.locationServicesEnabled()) {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        }
        
        
        //set up span and region
        latitude = 40
        longitude = -43
        var latDelta: CLLocationDegrees = 0.01
        var lonDelta: CLLocationDegrees = 0.01
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var region: MKCoordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude), span)
        
        mapView.showsBuildings = false
        mapView.showsPointsOfInterest = false
        
        
        
        
        
        
        
        
        
        
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var userLocation: CLLocation = locations[0] as CLLocation
        println(userLocation)
        
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        var latDelta: CLLocationDegrees = 0.03
        var lonDelta: CLLocationDegrees = 0.03
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var region: MKCoordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude), span)
        
        mapView.setRegion(region, animated: true)
        
        
        if (userLocation.horizontalAccuracy < 50) {
            
            //stop updating
            manager.stopUpdatingLocation()
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
            
            //fourSquare api inforamtion
            var fourSquareUrlString: String = ("https://api.foursquare.com/v2/venues/explore?client_id=FARFF35L0FYS22Q0ZONSYTHEAES4E2JNGWEP2OFC4ODMW5G0&client_secret=REUF1KJ2F0IKQHXF1WYJCU0YSTZ4N2I4MP21OZ5A1YSDGMPZ&v=20130815&ll=\(latitude),\(longitude)&query=mexican&limit=25").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

            let fourSquareURL = NSURL(string: fourSquareUrlString)
            
            let sharedSession = NSURLSession.sharedSession()
            
            //start the URL call and fetch the data with the completionhandler
            let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(fourSquareURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                
                // check for HTTP response
                if (error == nil) {
                    println("works")
                    
                    
                    
                    let dataObject = NSData(contentsOfURL: location)
                    let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                    
                    
                    let newDict: NSDictionary = (weatherDictionary["response"] as NSDictionary)
                    let newArray: NSArray = newDict["groups"] as NSArray
                    let itemArray: NSArray = newArray[0]["items"] as NSArray
                    
                    for item in itemArray {
                        
                        var tempDict: NSDictionary = item as NSDictionary
                        var itemDict: NSDictionary = tempDict["venue"] as NSDictionary
                        
                        
                        let venueDict = VenueDict(itemDictionary: itemDict)
                        
                        var lat: CLLocationDegrees? = (venueDict.location?.latitude) as CLLocationDegrees?
                        var lng: CLLocationDegrees? = (venueDict.location?.longitude) as CLLocationDegrees?
                        
                        
                        //set up the annotation
                        var annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2DMake(lat!, lng!)
                        annotation.title = venueDict.name!
                        if (venueDict.price != nil && venueDict.rating != nil) {
                            annotation.subtitle = "rating:\(venueDict.rating!) price:\(venueDict.price!)"
                        } else if (venueDict.price == nil && venueDict.rating != nil){
                            annotation.subtitle = "rating:\(venueDict.rating!) price:?"
                        } else if (venueDict.price != nil && venueDict.rating == nil){
                            annotation.subtitle = "rating:7 price:?"
                        } else {
                            annotation.subtitle = "rating:7 price:?"
                        }
                        
                        self.mapView.addAnnotation(annotation)
                        self.annotationArray.append(annotation)
                        
                        
                        
                    }

                    
                    
                    
                    
                    
                } else {
                    println("yo,  api failed")
                    println(error)
                }
                
                
            })
            
            downloadTask.resume()
            
        
        
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func searchBarSearchButtonClicked( searchBar: UISearchBar!){
        var query = searchBar.text
        println(query)
        
        self.mapView.removeAnnotations(annotationArray)
        self.annotationArray = []
        println(self.annotationArray)
        
        var fourSquareUrlString: String = ("https://api.foursquare.com/v2/venues/explore?client_id=FARFF35L0FYS22Q0ZONSYTHEAES4E2JNGWEP2OFC4ODMW5G0&client_secret=REUF1KJ2F0IKQHXF1WYJCU0YSTZ4N2I4MP21OZ5A1YSDGMPZ&v=20130815&ll=\(latitude),\(longitude)&query=\(query)&limit=30").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let fourSquareURL = NSURL(string: fourSquareUrlString)
        
        let sharedSession = NSURLSession.sharedSession()
        
        //start the URL call and fetch the data with the completionhandler
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(fourSquareURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            // check for HTTP response
            if (error == nil) {
                println("works")
                
                
                
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                
                
                let newDict: NSDictionary = (weatherDictionary["response"] as NSDictionary)
                let newArray: NSArray = newDict["groups"] as NSArray
                let itemArray: NSArray = newArray[0]["items"] as NSArray
                
                for item in itemArray {
                    
                    
                    
                    var tempDict: NSDictionary = item as NSDictionary
                    var itemDict: NSDictionary = tempDict["venue"] as NSDictionary
                    
                    
                    let venueDict = VenueDict(itemDictionary: itemDict)
                    
                    var lat: CLLocationDegrees? = (venueDict.location?.latitude) as CLLocationDegrees?
                    var lng: CLLocationDegrees? = (venueDict.location?.longitude) as CLLocationDegrees?
                    
                    
                    //set up the annotation
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(lat!, lng!)
                    annotation.title = venueDict.name!
                    if (venueDict.price != nil && venueDict.rating != nil) {
                        annotation.subtitle = "rating:\(venueDict.rating!) price:\(venueDict.price!)"
                    } else if (venueDict.price == nil && venueDict.rating != nil){
                        annotation.subtitle = "rating:\(venueDict.rating!) price:?"
                    } else if (venueDict.price != nil && venueDict.rating == nil){
                        annotation.subtitle = "rating:7 price:?"
                    } else {
                        annotation.subtitle = "rating:7 price:?"
                    }
                    
                    self.mapView.addAnnotation(annotation)
                    self.annotationArray.append(annotation)
                    
                    
                    
                
                    
                    
                    
                }
                
                self.mapView.showAnnotations(self.annotationArray, animated: true)
                
                
            } else {
                println("yo,  api failed")
                println(error)
            }
            
            
            
        })
        
        downloadTask.resume()
        
        
    }
    
    func mapView(mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            
            if annotation is MKUserLocation {
                //return nil so map view draws "blue dot" for standard user location
                return nil
            }
            
            
            
            let reuseId = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
                pinView!.canShowCallout = true
                pinView!.animatesDrop = true
                pinView!.pinColor = .Purple
                
                
                let stringArray = (annotation.subtitle as String!).componentsSeparatedByString(" ")
                let stringArray2 = (stringArray[0] as String!).componentsSeparatedByString(":")
                var newString: NSString = stringArray2[1] as NSString
                var rating: Double = newString.doubleValue
                
                
                if (rating >= 9) {
                    pinView!.pinColor = .Green
                } else if (rating >= 8) {
                    pinView!.pinColor = .Purple
                } else {
                    pinView!.pinColor = .Red
                }
                
                
                
            }
            else {
                pinView!.annotation = annotation
            }
            
            return pinView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!){
        
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }


}

