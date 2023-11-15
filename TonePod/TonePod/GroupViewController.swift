//
//  GroupViewController.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 11/15/23.
//

import UIKit

class GroupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initial UI
        self.view.backgroundColor = UIColor(red: 253/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        self.title = "Groups"
        navigationController?.tabBarItem.image = UIImage(systemName: "folder.fill")
        navigationController?.tabBarItem.title = "Groups"

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
