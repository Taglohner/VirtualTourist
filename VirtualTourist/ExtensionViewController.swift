//
//  ExtensionViewController.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 09/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import UIKit
import Foundation

extension UIViewController {
    
    func displayAlert(_ alertTitle: String?,_ message: String,_ actionTitle: String) {
        let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
