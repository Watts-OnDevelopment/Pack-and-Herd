//
//  SettingsViewController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/13/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UITableViewController {
    //MARK: Properties
    private let cellIDs : [String : Int] = ["adminCell" : 45, "imageCell" : 170, "infoCell" : 55]
    private let profileInfo : [String : String] = ["Full Name" : "", "Location" : ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: Outlets
    
    //MARK: UITableViewController Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Admin
            return 1
        case 1: // Image
            return 1
        case 2: // Profile
            return profileInfo.count
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // Admin
            let cell = tableView.dequeueReusableCell(withIdentifier: "adminCell", for: indexPath)
            return cell
        case 1: // Image
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            return cell
        case 2: // Profile
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            return cell
        default:
            fatalError("ERROR: Too many sections were included!")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && UserData.isAdmin() {
            return 0
        }else{
            return tableView.rectForRow(at: indexPath).height
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 55
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        
        return headerCell
    }
    
    /*
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
    } */
    
}
