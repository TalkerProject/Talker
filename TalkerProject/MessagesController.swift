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
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
//        profileImageViewNavBar.translatesAutoresizingMaskIntoConstraints = false
//        profileImageViewNavBar.layer.cornerRadius = 20
//        profileImageViewNavBar.layer.masksToBounds = true
//        profileImageViewNavBar.contentMode = .scaleAspectFill
//        if let profileImageURL = user.profileImageURL {
//            self.profileImageViewNavBar.setImageWith(URL(string: profileImageURL)!)
//        }
//        else {
//            self.profileImageViewNavBar.image = UIImage(named: "default_avatar")
//        }
//        titleView.addSubview(profileImageViewNavBar)
//        
//        profileImageViewNavBar.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
//        profileImageViewNavBar.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
//        profileImageViewNavBar.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        profileImageViewNavBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let myMutableString = NSMutableAttributedString(string: user.name!, attributes: [NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!])
        nameLabel.attributedText = myMutableString
        nameLabel.textAlignment = .center
        
        titleView.addSubview(nameLabel)
        
        nameLabel.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true

        self.navigationItem.titleView = titleView
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))

    }
    
    func showChatController() {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let nav = UINavigationController(rootViewController: newMessageController)
        present(nav, animated: true, completion:  nil)
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

