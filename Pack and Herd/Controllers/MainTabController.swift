//
//  MainTabController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/26/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit

class MainTabController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // After view loads
        SetTabBarPages()
    }
    
    //MARK: Private Methods
    private func SetTabBarPages(){
        print("Set Tab Bar Items")
        // Page Controllers
        let logsPage : UIViewController = LogsPageController()
        let logsBarItem : UITabBarItem = UITabBarItem(title: "Logs", image: #imageLiteral(resourceName: "logsIcon"), selectedImage: #imageLiteral(resourceName: "homeIcon"))
        logsPage.tabBarItem = logsBarItem
        
        let messagesPage : UIViewController = LogsPageController()
        let messagesBarItem : UITabBarItem = UITabBarItem(title: "Messages", image: #imageLiteral(resourceName: "messagesIcon"), selectedImage: #imageLiteral(resourceName: "homeIcon"))
        messagesPage.tabBarItem = messagesBarItem
        
        let eventsPage : UIViewController = LogsPageController()
        let eventsBarItem : UITabBarItem = UITabBarItem(title: "Events", image: #imageLiteral(resourceName: "eventsIcon"), selectedImage: #imageLiteral(resourceName: "homeIcon"))
        eventsPage.tabBarItem = eventsBarItem
        
        // Set pages in array
        var pageControllers : [UIViewController] = []
        pageControllers.append(logsPage)
        pageControllers.append(messagesPage)
        pageControllers.append(eventsPage)
        
        self.viewControllers = pageControllers
        
    }
    
    //MARK: Super Methods
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let itemTitle = item.title else{
            fatalError("ERROR: The Tab Bar item title is nil!")
        }
        print("Selected: "+itemTitle)
    }
    
}
