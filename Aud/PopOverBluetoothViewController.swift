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
        
        switch peakMusicController.playerType {
        case .Host:
            isHostSwitch.isOn = true
            connectedToLabel.text = "Connected to you:"
        case .Contributor:
            isHostSwitch.isOn = false
            connectedToLabel.text = "Connect to:"
        case .Individual:
            isHostSwitch.isOn = false
            peakMusicController.playerType = .Contributor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
    
    @IBAction func isHostValueChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            connectedToLabel.text = "Connected to you:"
            peakMusicController.playerType = .Host
        }
        else {
            connectedToLabel.text = "Connect to:"
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
            //SendingBluetooth.sendSongIdsFromHost(songs: peakMusicController.currPlayQueue)
            
            var ids: [String] = []
            
            for song in peakMusicController.currPlayQueue {
                
                ids.append("\(song.artistPersistentID)")
            }
            
            SendingBluetooth.sendSongIdsWithPeerId(ids: ids, peerID: peerID)
        }
    }
    
    func invitationWasReceived(fromPeer: String) {
        
        if peakMusicController.playerType == .Host {
            MPCManager.defaultMPCManager.invitationHandler(true, MPCManager.defaultMPCManager.session)
        }
    }

}
