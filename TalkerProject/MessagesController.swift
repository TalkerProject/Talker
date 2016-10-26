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
    let profileImageViewNavBar = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        checkIfUserIsLoggedIn()
    }
    
    func setupUI() {
        let rightBarButtonImage = UIImage(named: "new_message")?.withRenderingMode(.alwaysOriginal)
        let leftBarButtonImage = UIImage(named: "setting")?.withRenderingMode(.alwaysOriginal)
        
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white,
                              NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)! ] as [String : Any]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 244, g: 66, b: 66)
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarButtonImage, style: .plain, target: self, action: #selector(handleNewMessage))
        //        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonImage,style: .plain, target: self, action: #selector(handleSetting))
        
    }
    
    func handleSetting() {
        let settingController = SettingController()
        let nav = UINavigationController(rootViewController: settingController)
        present(nav, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleAutomaticallyLogout), with: nil, afterDelay: 0)
        }
        else {
            fetchUser()
        }
    }
    
    func fetchUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setUpNavBar(user: user)
            }
        })
    }
    
    //this function is to setup the navbar UI after fetching user
    func setUpNavBar(user: User) {
        //self.navigationItem.title = user.name
        let titleView = UIView()
        profileImageViewNavBar.translatesAutoresizingMaskIntoConstraints = false
        profileImageViewNavBar.layer.cornerRadius = 20
        profileImageViewNavBar.layer.masksToBounds = true
        profileImageViewNavBar.contentMode = .scaleAspectFill
        if let profileImageURL = user.profileImageURL {
            UIView.animate(withDuration: 1, animations: {
                self.profileImageViewNavBar.setImageWith(URL(string: profileImageURL)!)
            })
        }
        else {
            UIView.animate(withDuration: 1, animations: {
                self.profileImageViewNavBar.image = UIImage(named: "default_avatar")
            })
        }
        titleView.addSubview(profileImageViewNavBar)
        var timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(navBarAnimation), userInfo: nil, repeats: true)
        
//        nameLabel.frame = CGRect(x: 0, y: 0, width: CGFloat, height: CGFloat)
        profileImageViewNavBar.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageViewNavBar.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageViewNavBar.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageViewNavBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func navBarAnimation() {
        if (profileImageViewNavBar.alpha == 0) {
            UIView.animate(withDuration: 1, animations: {
                self.profileImageViewNavBar.alpha = 1
            })
        }
        else {
            UIView.animate(withDuration: 1, animations: {
                self.profileImageViewNavBar.alpha = 0
            })
        }
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let nav = UINavigationController(rootViewController: newMessageController)
        present(nav, animated: true, completion: nil)
    }
    
    //call this function when user is not logged in
    func handleAutomaticallyLogout() {
        do {
            try FIRAuth.auth()?.signOut()
            print("Logout successfully")
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
}

