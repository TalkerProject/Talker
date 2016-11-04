//
//  ChatLogController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/27/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    let cellID = "cellCollectionID"
    var user : User? {
        didSet {
            self.navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    
    func observeMessages() {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(userID)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                //                if message.fromID != self.user?.id {
                self.messages.append(message)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
                //                }
                
                }, withCancel: nil)
            }, withCancel: nil)
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
        setupInputsContainer()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MessageCell
        let message = messages[indexPath.item]
        var name = ""
        
        
        if message.fromID == self.user?.id {
            cell.bubbleView.backgroundColor = UIColor.darkGray
            cell.textView.text = message.text!
        }
        else {
            cell.bubbleView.backgroundColor = UIColor(r: 0, g: 189, b: 252)
            cell.textView.text = message.text!
        }
        
        
        cell.bubbleWidthAnchor?.constant = getEstimatedFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = getEstimatedFrameForText(text: text).height + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func getEstimatedFrameForText(text : String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        
        //NOTE : try to google how to dynamically change the height of UICollectionViewCell
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17)], context: nil)
    }
    
    func setupInputsContainer() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("SEND", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputsTextField)
        inputsTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputsTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
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
        let sentUserRef = userMessagesRef.child(fromID!)
        let recipientUserRef = userMessagesRef.child(toID!)
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            sentUserRef.updateChildValues([messageID : 1])
            recipientUserRef.updateChildValues([messageID : 1])
            
        }
        
    }
    
}
