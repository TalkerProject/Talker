//
//  ViewController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/17/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
import PulsingHalo
class MessagesController: UIViewController {
    let profileImageViewNavBar = UIImageView()
    //    var messagesDict = [String : Message]()
    //
    //    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar
            .shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 244, g: 66, b: 66)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        checkIfUserIsLoggedIn()
        //        observeUserMessages()
        //        tableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
    }
    var timer : Timer?
    
    let subView : UILabel = {
        let lb = UILabel()
        lb.backgroundColor = UIColor(r: 244, g: 66, b: 66)
        lb.text = "TALKERS TEAM © all rights reserved"
        lb.textColor = UIColor.white
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleNewMessage)))
        btn.isUserInteractionEnabled = true
        btn.contentMode = .scaleAspectFill
        btn.layer.masksToBounds = true
        btn.setImage(UIImage(named: "find_user"), for: .normal)
        return btn
    }()
    
    func setupUI() {
        view.addSubview(subView)
        subView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        subView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        subView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        let halo = PulsingHaloLayer()
        halo.position = view.center
        halo.radius = 160
        halo.backgroundColor = UIColor.white.cgColor
        halo.haloLayerNumber = 3
        view.layer.addSublayer(halo)
        halo.start()
        view.addSubview(searchButton)
        searchButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        searchButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.view.backgroundColor = UIColor(r: 244, g: 66, b: 66)
        //        let rightBarButtonImage = UIImage(named: "new_message")?.withRenderingMode(.alwaysOriginal)
        let leftBarButtonImage = UIImage(named: "setting")?.withRenderingMode(.alwaysOriginal)
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white,
                              NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)! ] as [String : Any]
        
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarButtonImage, style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonImage,style: .plain, target: self, action: #selector(handleSetting))
        
    }
    
    func handleSetting() {
        let settingController = SettingController()
        settingController.messagesVC = self
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
                self.handleUserConnectionState()
                self.setUpNavBar(user: user)
            }
        })
    }
    
    //this function is to setup the navbar UI after fetching user
    func setUpNavBar(user: User) {
        self.navigationItem.title = user.name
        //        self.messages.removeAll()
        //        self.messagesDict.removeAll()
        //        self.tableView.reloadData()
        let titleView = UIView()
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        let myMutableString = NSMutableAttributedString(string: user.name!, attributes: [NSForegroundColorAttributeName: UIColor.white,
                                                                                         NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)!])
        nameLabel.attributedText = myMutableString
        nameLabel.textAlignment = .center
        titleView.addSubview(nameLabel)
        
        nameLabel.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func showChatController(user : User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    //    func showAnonymousChatController(user : User){
    //        let anonymousChatController = AnonymousChatController(collectionViewLayout: UICollectionViewFlowLayout())
    //        anonymousChatController.user = user
    //        self.navigationController?.pushViewController(anonymousChatController, animated: true)
    //    }
    
    func handleNewMessage() {
        //        let newMessageController = NewMessageController()
        //        newMessageController.messagesController = self
        //        let nav = UINavigationController(rootViewController: newMessageController)
        //        present(nav, animated: true, completion:  nil)
        let user = User()
        let anonymousChatController = AnonymousChatController(collectionViewLayout: UICollectionViewFlowLayout())
        anonymousChatController.user = user
        self.navigationController?.pushViewController(anonymousChatController, animated: true)
    }
    
    var myConnectionRef : FIRDatabaseReference?
    func handleUserConnectionState() {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        let usersOnlineRef = FIRDatabase.database().reference().child("presence")
        
        connectedRef.observe(.value, with: { (snapshot) in
            guard let connected = snapshot.value as? Bool , connected else { return }
            guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
            self.myConnectionRef = usersOnlineRef.child(uid)
            self.myConnectionRef?.onDisconnectRemoveValue()
            self.myConnectionRef?.setValue(true)
            
        }) { (error) in
            print(error)
        }
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
        loginController.messagesVC = self
        present(loginController, animated: true, completion: nil)
    }
}

//    func observeUserMessages() {
//        guard let userID = FIRAuth.auth()?.currentUser?.uid else {
//            return
//        }
//        let ref = FIRDatabase.database().reference().child("user-messages").child(userID)
//        ref.observe(.childAdded, with: { (snapshot) in
//            let toUserID = snapshot.key
//            FIRDatabase.database().reference().child("user-messages").child(userID).child(toUserID).observe(.childAdded, with: { (snapshot) in
//                let messageID = snapshot.key
//                let messageRef = FIRDatabase.database().reference().child("messages").child(messageID)
//                messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                    if let dictionary = snapshot.value as? [String : AnyObject] {
//                        let message = Message(dictionary : dictionary)
//                        if let toID = message.getChatID() {
//                            self.messagesDict[toID] = message
//                        }
//                    }
//                    self.timer?.invalidate()
//                    self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
//                })
//            }) { (error) in
//                print(error)
//            }
//
//        })
//    }



//    func handleReloadTable() {
//        self.messages = Array(self.messagesDict.values)
//        self.messages.sort(by: { (message1, message2) -> Bool in
//            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
//        })
//        DispatchQueue.main.async(execute: {
//            self.tableView.reloadData()
//        })
//
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! UserCell
//        cell.message = messages[indexPath.row]
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 72
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let message = messages[indexPath.row]
//
//        guard let chatID = message.getChatID() else {
//            return
//        }
//
//        let ref = FIRDatabase.database().reference().child("users").child(chatID)
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let dictionary = snapshot.value as? [String : AnyObject] else {
//                return
//            }
//            let user = User()
//            user.setValuesForKeys(dictionary)
//            user.id = chatID
//            self.showChatController(user: user)
//            }, withCancel: nil)
//    }





