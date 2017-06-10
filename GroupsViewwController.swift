//
//  GroupsViewwController.swift
//  Peak
//
//  Created by Connor Monks on 6/4/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import FBSDKLoginKit
//import FBSDKCoreKit

class GroupsViewwController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /*MARK: PROPERTIES*/
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!

    
    let flh = FacebookLoginHandler()
    
    @IBOutlet weak var groupsTable: UITableView!
    
    
    var groupIDToSegueTo = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set our permissions for Facebook 
        facebookLoginButton.readPermissions = ["email", "public_profile", "user_friends"]
        
        facebookLoginButton.delegate = flh
        
        groupsTable.delegate = self
        groupsTable.dataSource = self
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group Cell", for: indexPath) as! GroupCell
        
        cell.groupName.text = "Hello Group"
        
        var meImages = [UIImage]()
        for _ in 0..<indexPath.row{
            
            meImages.append(#imageLiteral(resourceName: "ProperPeakyIcon"))
        }
        
        cell.groupiesView.groupies = meImages
        cell.groupID = indexPath.row
        
        //Add the gesture recognizer to the forward button
        
        cell.groupDetailButton.addTarget(self, action: #selector(showGroup(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func showGroup(_ button: UIButton){
        
        //Fetch the group id
        if let cell: GroupCell = button.superview?.superview as? GroupCell{
            
            groupIDToSegueTo = cell.groupID
            
        }
        
        /*NOW PERFORM THE SEGUE*/
        performSegue(withIdentifier: "Show Group Detail", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destVC = segue.destination as? GroupDetailController{
            
            destVC.groupID = groupIDToSegueTo
        }
    }
}
