//
//  ViewController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/17/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        checkIfUserIsLoggedIn()
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 244, g: 66, b: 66)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        let rightBarButtonImage = UIImage(named: "new_message")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarButtonImage, style: .plain, target: self, action: #selector(handleNewMessage))
        //        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }

    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(handleLogout))
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
            })
        }
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let nav = UINavigationController(rootViewController: newMessageController)
        present(nav, animated: true, completion: nil)
        
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

