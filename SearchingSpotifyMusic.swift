//
//  SearchingSptotifyMusic.swift
//  Peak
//
//  Created by Cameron Monks on 5/17/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

//
//  SearchingAppleMusicApi.swift
//  Peak
//
//  Created by Cameron Monks on 4/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class SearchingSpotifyMusic {
    
    static var defaultSearch = SearchingSpotifyMusic()
    
    private var nextSearchTerm: String?
    private var nextSearchCompletion: ([SPTPartialPlaylist]) -> Void = { (_) -> Void in }
    
    private var isSearching = false
    
    private var searches = 0
    
    private var lastSearch: TimeInterval = 0
    
    private var lastSearchIndex = -1
    private var searchCount = 0
    
    func addSearch(term: String, completion: @escaping ([SPTPartialPlaylist]) -> Void) {
        if isSearching {
            nextSearchTerm = term
            nextSearchCompletion = completion
            if lastSearch + 5000 > NSDate().timeIntervalSince1970 {
                nextSearchTerm = nil
                doSearch(term: term, completion: completion)
            }
            else {
                nextSearchTerm = term
                nextSearchCompletion = completion
            }
        }
        else {
            isSearching = true
            doSearch(term: term, completion: completion)
        }
    }
    
    private func doSearch(term: String, completion: @escaping ([SPTPartialPlaylist]) -> Void) {
        let currentSearchIndex = searchCount
        searchCount += 1
        
        lastSearch = NSDate().timeIntervalSince1970
        
        let searchesAtTime = searches
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {
            timer -> Void in
            
            if searchesAtTime == self.searches {
                self.searches += 1
                
                if let search = self.nextSearchTerm {
                    
                    self.doSearch(term: search, completion: self.nextSearchCompletion)
                    self.nextSearchTerm = nil
                }
                else {
                    
                    self.isSearching = false
                }
            }
        })
        
        ConnectingToInternet.getSpotifySongs(query: term, completion: {
            (songs) -> Void in
            
            
            if currentSearchIndex > self.lastSearchIndex {
                self.lastSearchIndex = currentSearchIndex
                completion(songs)
                
                self.searches += 1
            }
            
            // self.searches += 1
            
            if let search = self.nextSearchTerm {
                
                self.doSearch(term: search, completion: self.nextSearchCompletion)
                self.nextSearchTerm = nil
            }
            else {
                
                self.isSearching = false
            }
        }, error: {
            
            if let search = self.nextSearchTerm {
                
                self.doSearch(term: search, completion: self.nextSearchCompletion)
                self.nextSearchTerm = nil
            }
            else {
                
                self.isSearching = false
            }

        })
        
    }
}
