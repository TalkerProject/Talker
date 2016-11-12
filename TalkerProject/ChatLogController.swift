//
//  ChatLogController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/27/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
import AFNetworking
class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let cellID = "cellCollectionID"
    var user : User? {
        didSet {
            self.navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    var timer : Timer?
    func observeMessages() {
        
        guard let userID = FIRAuth.auth()?.currentUser?.uid, let toID = user?.id else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(userID).child(toID)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary)

                if message.getChatID() == self.user?.id {
                    self.messages.append(message)
                }
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadCollectionView), userInfo: nil, repeats: false)
                
                }, withCancel: nil)
            }, withCancel: nil)
    }
    
    func handleReloadCollectionView() {
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
        })
    }
    lazy var inputsTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter messages....."
        textField.delegate = self
        textField.backgroundColor = UIColor.white
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.keyboardDismissMode = .interactive
        hideKeyboard()
        setupInputsContainer()
        setupKeyBoard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyBoard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowKeyBoard), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHideKeyBoard), name: .UIKeyboardWillHide, object: nil)
    }
    
    func handleHideKeyBoard(notification : NSNotification) {
        containerViewBottomAnchor?.constant = 0
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleShowKeyBoard(notification : NSNotification) {
        let frame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as! NSValue
        let keyboardFrame = frame.cgRectValue
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        containerViewBottomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    //NEED TO ADD function VIEWWILLTRANSITION TO HANDLE WHEN ROTATE THE SCREEN HORIZONTALLY
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MessageCell
        let message = messages[indexPath.item]
        setupCellUI(cell: cell, message: message)

        cell.textView.text = message.text
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = getEstimatedFrameForText(text: text).width + 10
        }
        else if message.imageURL != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
        return cell
    }
    
    private func setupCellUI(cell : MessageCell, message : Message) {
        if let messageImageURL = message.imageURL {
            cell.messageImageView.setImageWith(URL(string: messageImageURL)!)
            cell.messageImageView.isHidden = false
        }
        else {
            cell.messageImageView.isHidden = true
        }
        
        if let profileImageURL = self.user?.profileImageURL {
            cell.profileImageView.setImageWith(URL(string: profileImageURL)!, placeholderImage: UIImage(named: "default_avatar"))
        }
        
        //Check to setup the UI if it is from the current user or not
        if message.fromID == self.user?.id {
            cell.bubbleView.backgroundColor = UIColor.darkGray
            cell.profileImageView.isHidden = false
            cell.bubbleLeftAnchor?.isActive = true
            cell.bubbleRightAnchor?.isActive = false
        }
        else {
            cell.bubbleView.backgroundColor = UIColor(r: 0, g: 189, b: 252)
            cell.profileImageView.isHidden = true
            cell.bubbleLeftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = getEstimatedFrameForText(text: text).height + 20
        } else if messages[indexPath.item].imageURL != nil {
            height = 200
        }
        
        let width = UIScreen.main.bounds.width
    
        return CGSize(width: width, height: height)
    }
    
    private func getEstimatedFrameForText(text : String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        
        
        //NOTE : try to google how to dynamically change the height of UICollectionViewCell
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func handleUploadImageTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
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
            //this blog of code below is used for uploading the image to Firebase's storage then update to the user's database
            uploadImageToFireBaseStorage(imageToUpload: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    var containerViewBottomAnchor : NSLayoutConstraint?
    func setupInputsContainer() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image")?.withRenderingMode(.alwaysOriginal)
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImageTap)))
        
        containerView.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 6).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButtonView = UIImageView()
        sendButtonView.image = UIImage(named: "send_image")?.withRenderingMode(.alwaysOriginal)
        sendButtonView.isUserInteractionEnabled = true
        sendButtonView.translatesAutoresizingMaskIntoConstraints = false
        sendButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSend)))
        containerView.addSubview(sendButtonView)
        sendButtonView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        sendButtonView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        sendButtonView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButtonView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        containerView.addSubview(inputsTextField)
        inputsTextField.rightAnchor.constraint(equalTo: sendButtonView.leftAnchor).isActive = true
        inputsTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputsTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        inputsTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let lineSepeartor = UIView()
        lineSepeartor.backgroundColor = UIColor.darkGray
        lineSepeartor.translatesAutoresizingMaskIntoConstraints = false
        lineSepeartor.alpha = 0.5
        
        containerView.addSubview(lineSepeartor)
        lineSepeartor.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        lineSepeartor.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        lineSepeartor.bottomAnchor.constraint(equalTo: inputsTextField.topAnchor).isActive = true
        lineSepeartor.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func handleSend() {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = self.user?.id
        let fromID = FIRAuth.auth()?.currentUser?.uid
        let timeStamp : Int = Int(NSDate().timeIntervalSince1970)
        
        let values = ["text" : inputsTextField.text!, "toID" : toID!, "fromID" : fromID!, "timeStamp" : timeStamp] as [String : Any]
        
        //        childRef.updateChildValues(values)
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        let messageID = childRef.key
        let sentUserRef = userMessagesRef.child(fromID!).child(toID!)
        let recipientUserRef = userMessagesRef.child(toID!).child(fromID!)
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            sentUserRef.updateChildValues([messageID : 1])
            recipientUserRef.updateChildValues([messageID : 1])
            
        }
        self.inputsTextField.text = nil
        
    }
    
    private func uploadImageToFireBaseStorage(imageToUpload : UIImage) {
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("image_messages").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(imageToUpload, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    let ref = FIRDatabase.database().reference().child("messages")
                    let childRef = ref.childByAutoId()
                    let toID = self.user?.id
                    let fromID = FIRAuth.auth()?.currentUser?.uid
                    let timeStamp : Int = Int(NSDate().timeIntervalSince1970)
                    
                    let values = ["toID" : toID!, "fromID" : fromID!, "timeStamp" : timeStamp, "imageURL" : imageURL, "imageWidth" : imageToUpload.size.width, "imageHeight" : imageToUpload.size.height] as [String : Any]
                    
                    
                    //        childRef.updateChildValues(values)
                    let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
                    let messageID = childRef.key
                    let sentUserRef = userMessagesRef.child(fromID!).child(toID!)
                    let recipientUserRef = userMessagesRef.child(toID!).child(fromID!)
                    childRef.updateChildValues(values) { (error, ref) in
                        if error != nil {
                            print(error)
                            return
                        }
                        
                        sentUserRef.updateChildValues([messageID : 1])
                        recipientUserRef.updateChildValues([messageID : 1])
                        
                    }
                }
            })
        }
        
    }

    
}
