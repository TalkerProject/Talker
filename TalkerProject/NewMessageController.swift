//
//  NewMessageController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/22/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    var users = [User]()
    let cellID = "newMessageCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUsersMessages()
        tableView.register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellReuseIdentifier: <#T##String#>)
    }

    func setupUI() {
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
                
                //if app crash. Lets use dispatch_async
                self.tableView.reloadData()
            }
            }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let user = users[indexPath.row]
        let name = user.name
        let email = user.email
        
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = email
        return cell
    }

}
