//
//  PopOverBluetoothViewController.swift
//  Peak
//
//  Created by Cameron Monks on 3/26/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PopOverBluetoothViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var typeOfUserSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        MPCManager.defaultMPCManager.delegate = self
        //appDelegate.mpcManager.browser.startBrowsingForPeers()
        //MPCManager.defaultMPCManager.advertiser.startAdvertisingPeer()
        
        switch peakMusicController.playerType {
        case .Host:
            typeOfUserSegmentedControl.selectedSegmentIndex = 2
        case .Contributor:
            typeOfUserSegmentedControl.selectedSegmentIndex = 1
        case .Individual:
            typeOfUserSegmentedControl.selectedSegmentIndex = 0
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // should be updated when PeakMusicController->EnumPlayerType is changed but cant
    // gets updated in self.playerTypeSegementedControlValueChanged which is an @IBACtion
    private func updateMPCManager() {
        switch peakMusicController.playerType {
        case .Host:
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.startAdvertisingPeer()
        case .Contributor:
            MPCManager.defaultMPCManager.browser.startBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
        case .Individual:
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
        }
    }
    
    // MARK: IBOutlet
    
    @IBAction func playerTypeSegementedControlValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            peakMusicController.playerType = .Individual
        case 1:
            peakMusicController.playerType = .Contributor
        case 2:
            peakMusicController.playerType = .Host
        default:
            print("ERROR: PopOverBluetoothViewController->playerTypeSegementedControlValueChanged \(sender.selectedSegmentIndex)")
        }
        
        updateMPCManager()
        tableView.reloadData()
    }
    
    
    // MARK: - Table View Delegate / DataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch peakMusicController.playerType {
        case .Host:
            print("Clicked On \(MPCManager.defaultMPCManager.session.connectedPeers[indexPath.row].displayName)")
        case .Contributor:
            let selectedPeer = MPCManager.defaultMPCManager.foundPeers[indexPath.row] as MCPeerID
            
            MPCManager.defaultMPCManager.browser.invitePeer(selectedPeer, to: MPCManager.defaultMPCManager.session, withContext: nil, timeout: 20)
        case .Individual:
            print("ERROR PopOverBluetoothViewController->tableView->UITableViewCell INDEXPATH: \(indexPath.row)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "popOverBasicCellID")!
        
        switch peakMusicController.playerType {
        case .Host:
            cell.textLabel?.text = MPCManager.defaultMPCManager.session.connectedPeers[indexPath.row].displayName
        case .Contributor:
            cell.textLabel?.text = MPCManager.defaultMPCManager.foundPeers[indexPath.row].displayName
        case .Individual:
            print("ERROR PopOverBluetoothViewController->tableView->UITableViewCell INDEXPATH: \(indexPath.row)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch peakMusicController.playerType {
        case .Host:
            return MPCManager.defaultMPCManager.session.connectedPeers.count
        case .Contributor:
            return MPCManager.defaultMPCManager.foundPeers.count
        case .Individual:
            return 0
        }
    }

    
    // MARK: MPCManagerDelegate
    
    func foundPeer() {
        tableView.reloadData()
    }
    
    func lostPeer() {
        tableView.reloadData()
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
            
        print("Connected")
        
        if peakMusicController.playerType == .Host {
            
            var ids: [String] = []
            
            for song in peakMusicController.currPlayQueue {
                ids.append("\(song.persistentID)")
            }
            
            sendSongIdsToClient(ids: ids)
        }
    }
    
    func invitationWasReceived(fromPeer: String) {
        
        if peakMusicController.playerType == .Host {
            MPCManager.defaultMPCManager.invitationHandler(true, MPCManager.defaultMPCManager.session)
        }
    }
    
    // Not Delegate
    func sendSongIdsToClient(ids: [String]) {
        
        var messageDictionary: [String: String] = [:]
        
        for (index, id) in ids.enumerated() {
            messageDictionary["\(index)"] = id
        }
        
        for peers in MPCManager.defaultMPCManager.session.connectedPeers {
            if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: peers as MCPeerID) {
                
                print("Sent")
            }
            else {
                print("ERROR SENDING DATA COULD HAPPEN LibraryViewController -> sendSongIdsToClient")
            }
        }
    }

}
