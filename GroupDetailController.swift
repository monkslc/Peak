//
//  GroupDetailController.swift
//  Aud
//
//  Created by Connor Monks on 6/9/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class GroupDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
/*MARK: Properties*/
    
    var groupID = 0
    
    var recommendationIDS = [Int]()
    var groupName = "Test Groupies"
    
    @IBOutlet weak var groupRecsTable: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*FETCH THE GROUP NAME AND RECOMMENDED IDS based on the group id*/
        
        /*TEST DATA*/
        recommendationIDS = [0,1,2,3,4]
        groupName = "Test Group Namie"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupRecsTable.dataSource = self
        groupRecsTable.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return recommendationIDS.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            
            //add a Person Ident Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Person Ident Cell", for: indexPath) as! PersonDetailCell
            
            /*Fetch the song Person Info for the recommended song in the array wit an index of section num*/
            
            /*TEST DATA*/
            cell.personName.text = "Bobby Joe \(indexPath.section)"
            cell.personImage.image = #imageLiteral(resourceName: "ProperPeakyIcon")
            
            return cell
        } else{
            
            //Add a Song Rec Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Rec Song Cell", for: indexPath) as! RecSongCell
            
            /*FETCH TEH SONG INFO for the recommended sonf in the array with an index of indexPath.section*/
            
            /*TEST DATA*/
            cell.albumImage.image = #imageLiteral(resourceName: "Spotify_Icon_RGB_Black")
            cell.songArtistLabel.text = "Artist Num. \(indexPath.section)"
            cell.songTitleLabel.text = "Title Num. \(indexPath.section)"
            
            /*ADD THE GESTURE RECOGNIZER AND SONG ALERTS*/
            
            return cell
        }
    }
    

}
