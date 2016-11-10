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
    
    func getChatID() -> String? {
        return fromID == FIRAuth.auth()?.currentUser?.uid ? toID : fromID
    }
}
