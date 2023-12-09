//
//  MyTabBarController.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 12/9/23.
//

import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Load the saved tab index
        if let savedTabIndex = UserDefaults.standard.object(forKey: "lastSelectedTabIndex") as? Int {
            print("Retrieved saved tab index: \(savedTabIndex)") // Debugging
            self.selectedIndex = savedTabIndex
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Save the selected tab index
        UserDefaults.standard.set(tabBarController.selectedIndex, forKey: "lastSelectedTabIndex")
        print("Saved tab index: \(tabBarController.selectedIndex)") // Debugging
    }
}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

