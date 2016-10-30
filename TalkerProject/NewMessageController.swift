//
//  NewMessageController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/22/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
import AFNetworking

class NewMessageController: UITableViewController {
    var users = [User]()
    let cellID = "newMessageCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUsersMessages()
    }

    func setupUI() {
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white,
                              NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)! ] as [String : Any]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 244, g: 66, b: 66)
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = "Compose Message"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUsersMessages() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                
                //have to match the properties of the class exactly with the keys of dictionary, otherwise the app will crash.
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                user.id = snapshot.key
                
                //if app crashes. Lets use dispatch_async
                DispatchQueue.main.async(execute: { 
                    self.tableView.reloadData()

                })
            }
            }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath ) as! UserCell
        let user = users[indexPath.row]
        let name = user.name
        let email = user.email
        
        
        if let profileImageURL = user.profileImageURL {
            cell.profileImageView.setImageWith(URL(string: profileImageURL)!)
        }

        cell.textLabel?.text = name
        cell.detailTextLabel?.text = email
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    var messagesController : MessagesController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        let user = users[indexPath.row]
        self.messagesController?.showChatController(user: user)
    }

}
