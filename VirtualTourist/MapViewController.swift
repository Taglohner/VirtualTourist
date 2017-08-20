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
    var pin = Pin()

    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // MARK: Gesture recognizer
    
    func addGestureRecognizer () {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(newPin))
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.delaysTouchesBegan = true
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func createAnnotationFrom(_ location: CGPoint) -> MKPointAnnotation {
        let location = location
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
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
    
    // MARK: MapViewDelegate
    
    /* Creates and customize the map annotaion view */
    
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
    
    /* Act on selected pin. If the view is in the editing mode delete tapped pins, else perfom Segue */
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        pin = view.annotation as! Pin
        if isEditing {
            AppDelegate.stack.context.delete(pin)
            mapView.removeAnnotation(pin)
            AppDelegate.stack.save()
        } else {
            performSegue(withIdentifier: "toAlbum", sender: self)
        }
        mapView.deselectAnnotation(mapView.annotations as? MKAnnotation, animated: true)
    }
    
    /* Fetch pins and add them to the mapView after the map is rendered */
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        fetchDataAnd(.updateMap)
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAlbum" {
            let destinationViewController = segue.destination as! AlbumCollectionViewController
            destinationViewController.pin = self.pin
        }
    }
    
    // MARK: UI
    
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
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                switch action {
                case .clearData:
                    _ = objects.map{$0.map{context.delete($0)}}
                case .updateMap:
                    _ = objects.map{$0.map{mapView.addAnnotation($0 as! MKAnnotation)}}
                }
                AppDelegate.stack.save()
            } catch let error {
                print("ERROR FETCHING DATA : \(error)")
            }
        }
    }
}





