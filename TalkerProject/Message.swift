//
//  Message.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/28/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
class Message : NSObject {
    var fromID : String?
    var text : String?
    var timeStamp : NSNumber?
    var toID : String?
    var imageURL : String?
    var imageHeight : NSNumber?
    var imageWidth : NSNumber?
    
    func getChatID() -> String? {
        return fromID == FIRAuth.auth()?.currentUser?.uid ? toID : fromID
    }
    
    init(dictionary : [String : AnyObject]) {
        super.init()
        self.fromID = dictionary["fromID"] as? String
        self.text = dictionary["text"] as? String
        self.timeStamp = dictionary["timeStamp"] as? NSNumber
        self.toID = dictionary["toID"] as? String
        
        self.imageURL = dictionary["imageURL"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
}
