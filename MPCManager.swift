//
//  MPCManager.swift
//  Peak
//
//  Created by Cameron Monks on 3/25/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostConnectionWithPeer(peerID: MCPeerID)
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    static var defaultMPCManager = MPCManager()
    
    @available(iOS 7.0, *)
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        foundPeers.append(peerID)
        
        MPCManager.delegate?.foundPeer()
    }
    
    
    var session: MCSession!
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    static var delegate: MPCManagerDelegate?
    
    var dj: MCPeerID?
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcoda-mpc")
        advertiser.delegate = self
        
        //Add a player type listener
        NotificationCenter.default.addObserver(self, selector: #selector(playerTypeDidChange), name: .playerTypeChanged, object: nil)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        foundPeers.append(peerID)
        
        MPCManager.delegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated() { //enumerate(foundPeers){
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
        
        MPCManager.delegate?.lostPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //print("\n\n\nMPCMANAGER ERROR:")
        //print(error.localizedDescription)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        
        self.invitationHandler = invitationHandler
        
        MPCManager.delegate?.invitationWasReceived(fromPeer: peerID.displayName)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //print("\n\n\nMPCMANAGER ERROR:")
        //print(error.localizedDescription)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            //print("Connected to session: \(session)")
            
            MPCManager.delegate?.connectedWithPeer(peerID: peerID)
        case MCSessionState.connecting:
            break
            //print("Connecting to session: \(session)")
        case .notConnected:
            //print("Did not connect to session: \(session)")
            MPCManager.delegate?.lostConnectionWithPeer(peerID: peerID)
        }
    }
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let peersArray = NSArray(object: targetPeer)
        
        var wasAnError = false
        do {
            print("SEND SONGS")
            print(dictionary)
            try session.send(dataToSend, toPeers: peersArray as! [MCPeerID], with: .reliable)
        } catch {
            wasAnError = true
        }
        
        
        return wasAnError
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary: [String: AnyObject] = ["data": data as AnyObject, "fromPeer": peerID]
    
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: dictionary)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func resetSession() {
        
        session.disconnect()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
    }
    
    func getDj() -> MCPeerID {
        return dj!
    }
    
    func getDjName() -> String {
        return getDj().displayName
    }
    
    
    
    /*MARK: Notification Listener Methods*/
    func playerTypeDidChange() {
        
        switch peakMusicController.playerType{
            
        case .Host:
            MPCManager.defaultMPCManager.advertiser.startAdvertisingPeer()
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            
        case .Individual:
            MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
            MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            
        case .Contributor:
            MPCManager.defaultMPCManager.browser.startBrowsingForPeers()
            
        }
    }
}
