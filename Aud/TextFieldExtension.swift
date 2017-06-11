//
//  TextFieldExtension.swift
//  Aud
//
//  Created by Connor Monks on 6/11/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation


extension UITextField{
    
    func resetSearch(_ del: UITextFieldDelegate){
        
        self.resignFirstResponder()
        self.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
        self.text = "Search by Song, Artist, or Album..."
        self.delegate = del
    }
}
