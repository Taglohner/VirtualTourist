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
    
    // MARK: Outlets
    
    @IBOutlet weak var bottomButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var pin: Pin?
    
    // MARK: Indexes
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = false
        mapViewSetup()
        performFetch()
        updateBottomButtonMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fetchedResultsController.sections?.first?.numberOfObjects == 0 {
            bottomButtonOutlet.isEnabled = false
            loadPhotoCollectionFromFlickr()
        }
    }
    
    // MARK: Actions ans Helpers
    
    @IBAction func bottomButton(_ sender: Any) {
        if selectedIndexes.isEmpty {
            getNewPhotoCollection()
        } else {
            deleteSelectedPhotos()
        }
    }
    
    func mapViewSetup() {
        
        guard let annotation = pin else {
            displayAlert("Error", "could not get details for the selected pin", "Dismiss")
            return
        }
        
        mapView.addAnnotation(annotation)
        mapView.centerCoordinate = (annotation.coordinate)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.camera.altitude = 100000
    }
    
    func updateBottomButtonMode() {
        if selectedIndexes.count > 0 {
            bottomButtonOutlet.title = "Delete Selected Photos"
        } else {
            bottomButtonOutlet.title = "New Collection"
        }
    }
    
    func getNewPhotoCollection() {
        bottomButtonOutlet.isEnabled = false
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            AppDelegate.stack.context.delete(photo)
        }
        
        loadPhotoCollectionFromFlickr()
        AppDelegate.stack.save()
    }
    
    func loadPhotoCollectionFromFlickr() {
        
        guard let annotation = pin else {
            displayAlert("Error", "Could not get pictures for the selected pin.", "Dismiss")
            return
        }
        
        RequestFlickrData.sharedInstance().loadPhotoCollectionFromFlickr(selectePin: annotation) { (completion) in
            if completion == self.fetchedResultsController.sections?[0].numberOfObjects {
                self.bottomButtonOutlet.isEnabled = true
            }
        }
    }
    
    func deleteSelectedPhotos(){
        var photosToDelete = [Photo]()
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.object(at: indexPath) as! Photo)
        }
        for photo in photosToDelete {
            AppDelegate.stack.context.delete(photo)
        }
        selectedIndexes = [IndexPath]()
        AppDelegate.stack.save()
    }
    
    // MARK: Core Data
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let context = AppDelegate.stack.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
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
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! CollectionViewCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: CollectionViewCell, at indexPath: IndexPath) {
        
        cell.activityIndicatorForCell.hidesWhenStopped = true
        cell.activityIndicatorForCell.startAnimating()

        if let photo = self.fetchedResultsController.object(at: indexPath) as? Photo, let photoImage = photo.image {
            DispatchQueue.main.async {
                cell.cellPicture.image = UIImage(data: photoImage)
                cell.activityIndicatorForCell.stopAnimating()
            }
        } else {
            cell.cellPicture.image = UIImage(named: "placeholder")
        }
        
        if let _ = selectedIndexes.index(of: indexPath) {
            cell.cellPicture.alpha = 0.2
        } else {
            cell.cellPicture.alpha = 1.0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath)
        }
        configureCell(cell, at: indexPath)
        updateBottomButtonMode()
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        albumCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.albumCollectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.albumCollectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.albumCollectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: { (true) in
            self.updateBottomButtonMode()
        })
    }
}








