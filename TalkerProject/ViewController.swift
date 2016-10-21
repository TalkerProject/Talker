//
//  ViewController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/17/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
    }
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(handleLogout))
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
            
        }
    }
    
    func handleLogout() {
        do {
           try FIRAuth.auth()?.signOut()
            print("Logout successfully")
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
}

