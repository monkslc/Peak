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
    
    @IBOutlet var isHostSwitch: UISwitch!
    
    @IBOutlet var connectedToLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        MPCManager.defaultMPCManager.delegate = self
        
        //Check what the player type is so we can set up the view
        switch peakMusicController.playerType {
        case .Host:
            isHostSwitch.isOn = true
            connectedToLabel.text = "Session Members:"
        case .Contributor:
            isHostSwitch.isOn = false
            connectedToLabel.text = "Joined:"
        case .Individual:
            isHostSwitch.isOn = false
            connectedToLabel.text = "Join a Session:"
        }
        
        updateMPCManager()
    }

    // should be updated when PeakMusicController->EnumPlayerType is changed but cant
    // gets updated in self.playerTypeSegementedControlValueChanged which is an @IBACtion
    private func updateMPCManager() {
        
        switch peakMusicController.playerType {
        case .Host:
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.startAdvertisingPeer()
        case .Contributor:
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
        case .Individual:
            MPCManager.defaultMPCManager.browser.startBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
        }
    }
    
    // MARK: IBOutlet
    
    @IBAction func isHostValueChanged(_ sender: UISwitch) {
        //Gets called when the Host Session switch changes
        
        if sender.isOn {
            connectedToLabel.text = "Session Members:"
            peakMusicController.playerType = .Host
        }
        else {
            connectedToLabel.text = "Join A Session:"
            peakMusicController.playerType = .Contributor
        }
        
        updateMPCManager()
        tableView.reloadData()
    }
    
    @IBAction func disconectButonClicked(_ sender: UIButton) {
        
        peakMusicController.playerType = .Individual
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table View Delegate / DataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch peakMusicController.playerType {
        case .Host:
            print("Clicked On \(MPCManager.defaultMPCManager.session.connectedPeers[indexPath.row].displayName)")
        case .Contributor:
            print("Clicked On \(MPCManager.defaultMPCManager.session.connectedPeers[indexPath.row].displayName)")
        case .Individual:
            let selectedPeer = MPCManager.defaultMPCManager.foundPeers[indexPath.row] as MCPeerID
            
            MPCManager.defaultMPCManager.browser.invitePeer(selectedPeer, to: MPCManager.defaultMPCManager.session, withContext: nil, timeout: 20)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "popOverBasicCellID")!
        
        switch peakMusicController.playerType {
        case .Host:
            cell.textLabel?.text = MPCManager.defaultMPCManager.session.connectedPeers[indexPath.row].displayName
        case .Contributor:
            cell.textLabel?.text = MPCManager.defaultMPCManager.session.connectedPeers[indexPath.row].displayName
        case .Individual:
            cell.textLabel?.text = MPCManager.defaultMPCManager.foundPeers[indexPath.row].displayName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch peakMusicController.playerType {
        case .Host:
            return MPCManager.defaultMPCManager.session.connectedPeers.count
        case .Contributor:
            return MPCManager.defaultMPCManager.session.connectedPeers.count
        case .Individual:
            return MPCManager.defaultMPCManager.foundPeers.count
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
        
        if peakMusicController.playerType == .Host {
            //SendingBluetooth.sendSongIdsFromHost(songs: peakMusicController.currPlayQueue)
            
            if #available(iOS 10.3, *) {
                var ids: [String] = []
            
                for song in peakMusicController.currPlayQueue {
                
                    ids.append("\(song.playbackStoreID)")
                }
            
                SendingBluetooth.sendSongIdsWithPeerId(ids: ids, peerID: peerID)
            }
            else {
                SendingBluetooth.sendSongIdsFromHost(songs: peakMusicController.currPlayQueue)
            }

        }
        else if peakMusicController.playerType == .Individual {
            peakMusicController.playerType = .Contributor
        }
    }
    
    func invitationWasReceived(fromPeer: String) {
        
        if peakMusicController.playerType == .Host {
            MPCManager.defaultMPCManager.invitationHandler(true, MPCManager.defaultMPCManager.session)
        }
        else {
            print("ERROR: PopOverBluetoothViewController->invitationWasReceived ELSE \(fromPeer)")
        }
    }

}
