//
//  SettingController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/23/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
import AFNetworking
class SettingController: UIViewController {
    let uid = FIRAuth.auth()?.currentUser?.uid
    let databaseRef = FIRDatabase.database().reference()
    let currentUser = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    var messagesVC : MessagesController?
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfilePicture)))
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 75
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "default_avatar")
        return imageView
    }()
    
    var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        
        return table
    }()
    
    let subView : UILabel = {
        let lb = UILabel()
        lb.backgroundColor = UIColor(r: 244, g: 66, b: 66)
        lb.text = "TALKERS TEAM © all rights reserved"
        lb.textColor = UIColor.white
        lb.textAlignment = .center
        
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(profileImageView)
        view.addSubview(subView)
        

//        view.addSubview(tableView)
//        tableView.delegate = self
//        tableView.dataSource = self
        setupConstraints()
//        setupTableViewConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
}

extension SettingController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectProfilePicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else {
            if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                selectedImageFromPicker = originalImage
            }
        }
        
        if let selectedImage = selectedImageFromPicker  {
            profileImageView.image = selectedImage
            
            //this blog of code below is used for uploading the image to Firebase's storage then update to the user's database
            let uniqueImageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(uniqueImageName).jpg")
            if let uploadData = UIImageJPEGRepresentation(selectedImage,0.1) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print("Upload to storage successfully")
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        let currentUser = self.databaseRef.child("users").child(self.uid!)
                        let values = ["profileImageURL" : profileImageURL]
                        currentUser.updateChildValues(values, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print(error!)
                                return
                            }
                        })

                    }
                })
               
            }
        }
        dismiss(animated: true, completion: nil)
        
        
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(r: 244, g: 66, b: 66)
        
        //update the image for that shit
        self.currentUser.observeSingleEvent(of: .value, with: { (snapshot) in
            //get user value 
            let currentUserValue = snapshot.value as? NSDictionary
            if let profilePicture = currentUserValue?["profileImageURL"] as? String {
                self.profileImageView.setImageWith(URL(string:profilePicture)!)
            }
            
            }) { (error) in
                print(error)
        }
        
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white,
                              NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)! ] as [String : Any]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 244, g: 66, b: 66)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Settings"
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        let leftBarButtonImage = UIImage(named: "logout_button")?.withRenderingMode(.alwaysOriginal)
        let rightBarButtonImage = UIImage(named: "cancel_button")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonImage, style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarButtonImage, style: .plain, target: self, action: #selector(handleCancel))
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return UITableViewCell()
//    }
//    
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
            messagesVC?.myConnectionRef?.removeValue()
            print("Logout successfully")
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        loginController.messagesVC = self.messagesVC
        loginController.settingVC = self
        present(loginController, animated: true, completion: nil)
    }
    
    func setupConstraints() {
        //also needs x,y, width and height for autolayout
        profileImageView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 30).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        subView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        subView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        subView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    }
    
    func setupTableViewConstraints() {
        //        tableView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        //        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        //        tableView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
    }

}
