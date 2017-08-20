//
//  AlbumCollectionViewController.swift
//  UdacityVirtualTurist
//
//  Created by Steven Taglohner on 02/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class AlbumCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var pin = Pin()
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = false
        mapViewSetup()
        performFetch()
        
        if fetchedResultsController.sections?.first?.numberOfObjects == 0 {
            RequestFlickrData.sharedInstance().getPhotosJSONFromFlickr(pin: pin)
        }
    }
    
    // MARK: MapView
    
    func mapViewSetup() {
        mapView.addAnnotation(pin as MKAnnotation)
        mapView.centerCoordinate = pin.coordinate
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.camera.altitude = 100000
    }
    
    // MARK: Private functions
    
    @IBAction private func loadNewPhotosCollection(_ sender: Any) {
        
    }
    
    // MARK: Core Data
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let context = AppDelegate.stack.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func performFetch(){
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print("Failed to retrieve photos \(error)")
        }
    }
    
    private func clearData() {
        do {
            let context = AppDelegate.stack.context
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                AppDelegate.stack.save()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        albumCollectionView.reloadData()
    }
}

extension AlbumCollectionViewController {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! CollectionViewCell
        cell.activityIndicatorForCell.startAnimating()
        if let photo = fetchedResultsController.object(at: indexPath) as? Photo {
            if photo.image == nil {
                DispatchQueue.main.async {
                    cell.cellPicture.image = UIImage(named: "placeholder")
                    cell.activityIndicatorForCell.stopAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    cell.cellPicture.image = UIImage(data: photo.image!)
                    cell.activityIndicatorForCell.stopAnimating()
                }
            }
        }

        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let count = fetchedResultsController.sections?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count  = fetchedResultsController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    // MARK: UICollectionViewLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.frame.size
        let width =  (collectionViewSize.width / 3) - 4
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(3, 3, 3, 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}








