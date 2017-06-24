//
//  PopOverBluetoothViewController.swift
//  Peak
//
//  Created by Cameron Monks on 3/26/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PopOverBluetoothViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate, Page {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var isHostSwitch: UISwitch!
    
    @IBOutlet var connectedToLabel: UILabel!
    
    @IBOutlet var hostASessionLabel: UILabel!
    
    @IBOutlet var hostASessionStackView: UIStackView!
    
    @IBOutlet var disconectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        disconectButton.setTitleColor(UIColor.peakColor, for: .normal)
        isHostSwitch.onTintColor = UIColor.peakColor
        
        tableView.delegate = self
        tableView.dataSource = self
        
        MPCManager.delegate = self
        
        if peakMusicController.musicType == .Guest {
            //isHostSwitch.isHidden = true
            //hostASessionLabel.text = ""
            hostASessionStackView.isHidden = true
        }
        else {
            isHostSwitch.isOn = peakMusicController.playerType == .Host
        }
            
        //updateMPCManager()
        
        //self.isHostSwitch.isHidden = peakMusicController.musicType == .Guest
        MPCManager.defaultMPCManager.foundPeers = []
        self.connectedToLabel.text = "Join a Session:"
        self.tableView.isHidden = false
        self.disconectButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(PopOverBluetoothViewController.playerStateChanged(notification:)), name: .musicTypeChanged, object: nil)
        
    }
    
    
    // should be updated when PeakMusicController->EnumPlayerType is changed but cant
    // gets updated in self.playerTypeSegementedControlValueChanged which is an @IBACtion
    private func updateMPCManager() {
        
        switch peakMusicController.playerType {
        case .Host:
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.startAdvertisingPeer()
            DispatchQueue.main.async {
                self.hostASessionStackView.isHidden = false
                self.connectedToLabel.text = "Session Members:"
                self.tableView.isHidden = false
                self.disconectButton.isHidden = true
            }
        case .Contributor:
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
            DispatchQueue.main.async {
                self.hostASessionStackView.isHidden = true
                self.connectedToLabel.text = "Joined: \(MPCManager.defaultMPCManager.getDjName())"
                self.tableView.isHidden = true
                self.disconectButton.isHidden = false
            }
        case .Individual:
            MPCManager.defaultMPCManager.browser.startBrowsingForPeers()
            MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
            DispatchQueue.main.async {
                self.hostASessionStackView.isHidden = peakMusicController.musicType == .Guest
                MPCManager.defaultMPCManager.foundPeers = []
                self.connectedToLabel.text = "Join a Session:"
                self.tableView.isHidden = false
                self.disconectButton.isHidden = true
            }
        }
    }
    
    // MARK: IBOutlet
    
    @IBAction func isHostValueChanged(_ sender: UISwitch) {
        
        if peakMusicController.musicType == .Guest {
            sender.isOn = false
        }
        else {
            peakMusicController.playerType = (sender.isOn) ? .Host : .Individual
            
            updateMPCManager()
            tableView.reloadData()
            
            if sender.isOn && peakMusicController.musicType == .AppleMusic {
                let alert = UIAlertController(title: "Warning", message: "Your \(UIDevice.current.model) will download all songs sent to it", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func disconectButonClicked(_ sender: UIButton) {
        MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
        MPCManager.defaultMPCManager.resetSession()
        MPCManager.defaultMPCManager.browser.startBrowsingForPeers()
        //MPCManager.defaultMPCManager.session.disconnect()
        peakMusicController.playerType = .Individual
        updateMPCManager()
    }
    
    
    // MARK: - Table View Delegate / DataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if MPCManager.defaultMPCManager.foundPeers.count <= indexPath.row {
            tableView.reloadData()
            return
        }
        
        if peakMusicController.playerType == .Individual {
            
            let selectedPeer = MPCManager.defaultMPCManager.foundPeers[indexPath.row] as MCPeerID
            
            MPCManager.defaultMPCManager.browser.invitePeer(selectedPeer, to: MPCManager.defaultMPCManager.session, withContext: nil, timeout: 20)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "popOverBasicCellID")! as! BluetoothTableViewCell
        cell.loader.isHidden = true
        
        switch peakMusicController.playerType {
        case .Host:
            cell.nameLabel!.text = MPCManager.defaultMPCManager.session.connectedPeers[indexPath.row].displayName
        case .Contributor:
            cell.nameLabel!.text = MPCManager.defaultMPCManager.session.connectedPeers[indexPath.row].displayName
        case .Individual:
            cell.nameLabel!.text = MPCManager.defaultMPCManager.foundPeers[indexPath.row].displayName
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
    
    // Notification
    
    func playerStateChanged(notification: NSNotification) {
        DispatchQueue.main.async {
            self.hostASessionStackView.isHidden = peakMusicController.musicType == .Guest
            self.isHostSwitch.isOn = peakMusicController.playerType == .Host
        }
        //updateMPCManager()
    }
    
    // MARK: MPCManagerDelegate
    
    func foundPeer() {
        tableView.reloadData()
    }
    
    func lostPeer() {
        tableView.reloadData()
    }
    
    func lostConnectionWithPeer(peerID: MCPeerID) {
        switch peakMusicController.playerType {
        case .Individual:
            MPCManager.defaultMPCManager = MPCManager()
            fallthrough
        case .Host:
            DispatchQueue.main.sync {
                self.tableView.reloadData()
            }
        case .Contributor:
            if MPCManager.defaultMPCManager.getDj() == peerID {
                peakMusicController.playerType = .Individual
                MPCManager.defaultMPCManager.resetSession()
                updateMPCManager()
            }
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if peakMusicController.playerType == .Host {
            //SendingBluetooth.sendSongIdsFromHost(songs: peakMusicController.currPlayQueue)
            
            //if #available(iOS 10.3, *) {
            
            SendingBluetooth.sendSongsToPeer(songs: peakMusicController.currPlayQueue, peerID: peerID)
            //}
            //else {
            //    SendingBluetooth.sendSongIdsFromHost(songs: peakMusicController.currPlayQueue)
            //}

        }
        else if peakMusicController.playerType == .Individual {
            
            MPCManager.defaultMPCManager.dj = peerID
            
            peakMusicController.playerType = .Contributor
            
            updateMPCManager()
        }
    }
    
    func invitationWasReceived(fromPeer: String) {
        
        if peakMusicController.playerType == .Host {
            MPCManager.defaultMPCManager.invitationHandler(true, MPCManager.defaultMPCManager.session)
        }
        else {
            print("\n\nERROR: PopOverBluetoothViewController->invitationWasReceived ELSE \(fromPeer)\n\n")
        }
    }
    
    // MARK: PageDelegate
    
    func pageDidStick() {
        //MPCManager.defaultMPCManager.delegate = self

        updateMPCManager()
    }
    
    func pageIsShown() {
        
    }
    
    func pageLeft() {
        if peakMusicController.playerType == .Individual {
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
        }
    }
}
