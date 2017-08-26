//
//  MapViewController.swift
//  UdacityVirtualTurist
//
//  Created by Steven Taglohner on 30/07/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapRegion()
        navigationItem.rightBarButtonItem = editButtonItem
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // MARK: MapView
    
    func addGestureRecognizer () {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(newPin))
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.delaysTouchesBegan = true
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView?.animatesDrop = true
        pinView?.isExclusiveTouch = true
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func newPin(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        } else if !isEditing {
            /* Get location */
            let location = gestureReconizer.location(in: mapView)
            let convertedLocation = mapView.convert(location, toCoordinateFrom: mapView)
            
            /* Add annotation to the context */
            let pin = Pin(pinLatitude: convertedLocation.latitude, pinLongitude: convertedLocation.longitude, context: AppDelegate.stack.context)
            
            /* Add annotation to the mapView */
            mapView.addAnnotation(pin as MKAnnotation)
            
            /* persist on the disk */
            AppDelegate.stack.save()
        }
    }
    
    private func createAnnotationFrom(_ location: CGPoint) -> MKPointAnnotation {
        let location = location
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = view.annotation as! Pin
        if isEditing {
            AppDelegate.stack.context.delete(pin)
            mapView.removeAnnotation(pin)
            AppDelegate.stack.save()
        } else {
            let destinationViewController = self.storyboard!.instantiateViewController(withIdentifier: "AlbumCollectionViewController") as! AlbumCollectionViewController
            destinationViewController.pin = pin
            self.navigationController!.pushViewController(destinationViewController, animated: true)
        }
        mapView.deselectAnnotation(mapView.annotations as? MKAnnotation, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(Double(mapView.region.center.latitude), forKey: "mapRegionLatitude")
        UserDefaults.standard.set(Double(mapView.region.center.longitude), forKey: "mapRegionLongitude")
        UserDefaults.standard.set(Double(mapView.region.span.latitudeDelta), forKey: "mapRegionSpanlatitudeDelta")
        UserDefaults.standard.set(Double(mapView.region.span.longitudeDelta), forKey: "mapRegionSpanlongitudeDelta")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        fetchDataAnd(.updateMap)
    }

    func setMapRegion(){
        var mapViewRegion = MKCoordinateRegion()
        let hasLaunchedBefore = UserDefaults.standard.value(forKey: "hasLaunchedBefore")
        
        if hasLaunchedBefore != nil {
            mapViewRegion.center.latitude = UserDefaults.standard.double(forKey: "mapRegionLatitude")
            mapViewRegion.center.longitude = UserDefaults.standard.double(forKey: "mapRegionLongitude")
            mapViewRegion.span.latitudeDelta = UserDefaults.standard.double(forKey: "mapRegionSpanlatitudeDelta")
            mapViewRegion.span.longitudeDelta = UserDefaults.standard.double(forKey: "mapRegionSpanlongitudeDelta")
            mapView.setRegion(mapViewRegion, animated: true)
        }
        else {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

    // MARK: Actions and helpers
    
    @IBAction func deleteAllPins(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        fetchDataAnd(.clearData)
    }
    
    override func setEditing (_ editing:Bool, animated:Bool) {
        super.setEditing(editing,animated:animated)
        if self.isEditing {
            self.navigationController?.setToolbarHidden(false, animated: true)
            self.editButtonItem.title = "Done"
            displayAlert("Delete Pins", "Tap on the pins you want to delete.", "Dismiss")
        } else {
            self.editButtonItem.title = "Edit"
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    // MARK: CoreData
    
    enum Action { case clearData, updateMap }
    
    private func fetchDataAnd(_ action: Action) {
        do {
            let context = AppDelegate.stack.context
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            do {
                if let objects  = try context.fetch(fetchRequest) as? [NSManagedObject] {
                    switch action {
                    case .clearData:
                        for object in objects {
                            context.delete(object)
                        }
                    case .updateMap:
                        for object in objects {
                            mapView.addAnnotation(object as! MKAnnotation)
                        }
                    }
                }
                AppDelegate.stack.save()
            } catch let error {
                print("ERROR FETCHING DATA : \(error)")
            }
        }
    }
    
    
}





