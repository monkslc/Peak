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
    }
    
    
    // MARK: - Table View Delegate / DataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPeer = MPCManager.defaultMPCManager.foundPeers[indexPath.row] as MCPeerID
        
        MPCManager.defaultMPCManager.browser.invitePeer(selectedPeer, to: MPCManager.defaultMPCManager.session, withContext: nil, timeout: 20)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "popOverBasicCellID")!
        
        cell.textLabel?.text = MPCManager.defaultMPCManager.foundPeers[indexPath.row].displayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MPCManager.defaultMPCManager.foundPeers.count
    }

    
    // MARK: MPCManagerDelegate
    
    func foundPeer() {
        tableView.reloadData()
    }
    
    
    func lostPeer() {
        tableView.reloadData()
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        //OperationQueue.main.addOperation { () -> Void in
        //    self.performSegue(withIdentifier: "idSegueClient", sender: self)
        //}
    }
    
    func invitationWasReceived(fromPeer: String) {
        
        if peakMusicController.playerType == .Host {
            MPCManager.defaultMPCManager.invitationHandler(true, MPCManager.defaultMPCManager.session)
        }
    }

}
