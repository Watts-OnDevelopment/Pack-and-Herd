//
//  LogsPageController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/26/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit

class LogsPageController : UIViewController {
    //MARK: Properties
    
    let collectionView : UICollectionView = {
        let collView =  UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
            // Customization //
            collView.backgroundColor = UIColor.white
        
        return collView
    }()
    
    let logsList : UITableViewController = {
        let tView = UITableViewController(style: UITableViewStyle.plain)
        
            // Customization //
            
        
        return tView
    }()
    
    //MARK: Base Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set page title
        title = "Logs"
        
    }
    
    //MARK: Private Methods
    func SetSubviews(){
        /* List View
         
         */
        //self.view.addSubview(<#T##view: UIView##UIView#>)
        self.collectionView.frame = view.frame
    }
    
    
    //MARK: Public Methods
    
}
