//
//  SettingsViewController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/13/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Outlets
    private let cellIDs : [String : Int] = ["profileCell" : 200, "locationProfileCell" : 250]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: UICollectionViewDelegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellIDs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIDs.keys[cellIDs.keys.index(cellIDs.keys.startIndex, offsetBy: indexPath.item)] , for: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "settingsHeader", for: indexPath)
        
        
        if let isAdmin = UserData.userData["admin"] as? Bool{
            if isAdmin {
                return view
            }else{
                return UICollectionReusableView()
            }
        }else {
            fatalError("ERROR: |\(self)| admin field in User Data not found!")
        }
    }
    
    //MARK: UICollectionViewFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerSize = CGSize(width: 50, height: 50)
        
        if let isAdmin = UserData.userData["admin"] as? Bool{
            if isAdmin {
                return headerSize
            }else{
                return CGSize(width: 0,height: 0)
            }
        }else {
            fatalError("ERROR: |\(self)| admin field in User Data not found!")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: 375, height: cellIDs.values[cellIDs.values.index(cellIDs.startIndex, offsetBy: indexPath.item)])
        return cellSize
    }
    
}
