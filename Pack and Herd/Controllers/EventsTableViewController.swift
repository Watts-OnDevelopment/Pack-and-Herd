//
//  EventsTableViewController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/1/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: UITableViewController Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create header view by setting it to the content view of the header cell!

        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        let headerView = headerCell?.contentView
        
        return headerView
    }
    

}
