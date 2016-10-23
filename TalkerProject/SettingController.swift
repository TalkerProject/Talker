//
//  SettingController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/23/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
class SettingController: UIViewController {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.red
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        
        return table
    }()
    
    func setupProfileImageViewConstraints() {
        //also needs x,y, width and height for autolayout
        profileImageView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 30).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupTableViewConstraints() {
//        tableView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
//        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        tableView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
//        view.addSubview(profileImageView)
//        view.addSubview(tableView)
//        tableView.delegate = self
//        tableView.dataSource = self
//        setupProfileImageViewConstraints()
//        setupTableViewConstraints()
        
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(r: 244, g: 66, b: 66)
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white,
                              NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)! ] as [String : Any]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 244, g: 66, b: 66)
        self.navigationItem.title = "Settings"
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
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
