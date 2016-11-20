//
//  FirebaseClient.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 11/20/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import Foundation
import Firebase

class FirebaseClient : AnyObject {
    static var sharedInstance = FirebaseClient()
    var databaseRef = FIRDatabase.database().reference()
    var authRef = FIRAuth.auth()
    var storageRef = FIRStorage.storage().reference()
}
