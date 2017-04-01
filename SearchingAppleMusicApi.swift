//
//  SearchingAppleMusicApi.swift
//  Peak
//
//  Created by Cameron Monks on 4/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class SearchingAppleMusicApi {
    
    static let defaultSearch = SearchingAppleMusicApi()
    
    private var nextSearchTerm: String?
    private var nextSearchCompletion: ([Song]) -> Void = { (_) -> Void in }
    
    private var isSearching = false
    
    func addSearch(term: String, completion: @escaping ([Song]) -> Void) {
        if isSearching {
            nextSearchTerm = term
            nextSearchCompletion = completion
        }
        else {
            isSearching = true
            doSearch(term: term, completion: completion)
        }
    }
    
    private func doSearch(term: String, completion: @escaping ([Song]) -> Void) {
        ConnectingToInternet.getSongs(searchTerm: term, limit: 7, sendSongsAlltogether: true, completion: {
            (songs) -> Void in
            
            completion(songs)
            
            
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
