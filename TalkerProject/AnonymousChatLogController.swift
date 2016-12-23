//
//  AnonymousChatLogController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 11/26/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
import AFNetworking
import MobileCoreServices
import AVFoundation
import AVKit


class AnonymousChatController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var chatID = ""  // for video call
    let cellID = "cellCollectionID"
    var spinnerActivity : MBProgressHUD!
    let anonymousChannelRef = FIRDatabase.database().reference().child("channel")
    var user : User? {
        didSet {
            self.navigationItem.title = "Anonymous User"
            
            // just added by Eastern Neverlose
            let videoCall : UIBarButtonItem = UIBarButtonItem(title: "Video Call", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AnonymousChatController.videoCallButtonClicked))
            
            self.navigationItem.rightBarButtonItem = videoCall
        }
    }
    var messages = [Message]()
    var timer : Timer?
    var connectedChannel = ""
    var channelCount = 0
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    // Video Call
    
    // just added by Eastern Neverlose
    // go to the VideoCallController
    func videoCallButtonClicked() {
        let videoCallController = VideoCallController()
        chatID = randomStringGenerator()
        videoCallController.hotelRoomNumber = chatID
        videoCallController.isInviter = true
        
        // send a special message to indicate a video call to invite your friend
        // this message is as #20 random characters|
        sendMessagesWithProperties(properties: ["text" : "#" + chatID + "|"])
        
        self.navigationController?.pushViewController(videoCallController, animated: true)
    }
    
    // copied from stackOverFlow
    func randomStringGenerator(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
    func specialMessagefilter(message: String) -> Bool{
        if message.characters.first == "#" && message.characters.last == "|" {
            if message.characters.count == 22 {
                return true
            }
        }
        return false
    }
    
    func checkTimestamp(time: NSNumber) -> Bool{
        let timeStamp : Int = Int(NSDate().timeIntervalSince1970)
        if timeStamp - Int(time) < 60 {
            return true
        }
        return false
    }
    
    // this is the person get invited to the call
    func VideoCallMessageTouched() {
        let videoCallController = VideoCallController()
        videoCallController.hotelRoomNumber = chatID
        videoCallController.isInviter = false
        
        self.navigationController?.pushViewController(videoCallController, animated: true)
    }
    
    // Video Call End
    
    
    
    func lookingForChannel() {
        showHUD()
        var didFindChannel = false
        //get the number of channel
        anonymousChannelRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.channelCount = Int(snapshot.childrenCount)
            if (self.channelCount == 0) {
                self.setupChannel()
            }
            else {
                var count = 0
                self.anonymousChannelRef.observe(.childAdded, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String : AnyObject] else {
                        return
                    }
                    
                    count += 1
                    if !didFindChannel && dictionary["users"] as? Int == 1 {
                        self.connectedChannel = snapshot.key
                        self.connectToChannel()
                        didFindChannel = true
                    }
                    else if !didFindChannel && count == self.channelCount {
                        self.setupChannel()
                        didFindChannel = true
                    }
                })
            }
            
        })
    }
    
    
    
    func connectToChannel() {
        let channelRef = anonymousChannelRef.child(connectedChannel)
        channelRef.child("users").setValue(2)
        //        pairingWithStranger(channelRef: channelRef)
        hideHUD()
        self.observeMessages()
        self.handleChannelTerminated()
    }
    
    func setupChannel() {
        let channelRef = anonymousChannelRef.childByAutoId()
        connectedChannel = channelRef.key
        channelRef.child("users").setValue(1)
        //        pairingWithStranger(channelRef: channelRef)
        
        channelRef.observe(.childChanged, with: { (snapshot) in
            if snapshot.value as? Int == 2 {
                self.hideHUD()
            }
        })
        self.observeMessages()
        self.handleChannelTerminated()
    }
    
    func handleChannelTerminated() {
        if (connectedChannel != "") {
            anonymousChannelRef.child(connectedChannel).observe(.childRemoved, with: { snapshot in
                self.showHUDOnKickedOut()
            })
        }
    }
    
    func handleAppTerminated(){
        print("IM HERE")
        FIRDatabase.database().reference().child("presence").observe(.childRemoved, with: {(snapshot) in
            print("A user has been logged out")
            if (snapshot.key == self.userID!) {
                self.removeChannel()
                self.anonymousChannelRef.removeAllObservers()
                NotificationCenter.default.removeObserver(self)
            }
        })
    }
    
    func observeMessages() {
        let messagesRef = anonymousChannelRef.child(connectedChannel).child("messages")
        messagesRef.observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value else {
                return
            }
            let message = Message(dictionary: dictionary as! [String : AnyObject])
            self.messages.append(message)
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadCollectionView), userInfo: nil, repeats: false)
        })
    }
    
    func findChatPartnerByID(userID : String) {
        let userRef = FIRDatabase.database().reference().child("users")
        userRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else {
                return
            }
            self.user?.setValuesForKeys(dictionary)
            self.user?.id = snapshot.key
            self.observeMessages()
        })
    }
    
    func removeChannel() {
        if (connectedChannel != "" ) {
            let channelRef = anonymousChannelRef.child(connectedChannel)
            channelRef.observeSingleEvent(of: .value, with: { (snapshot) in
                snapshot.ref.removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                    }
                })
            })
        }
    }
    
    func handleReloadCollectionView() {
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
            if self.messages.count > 0 {
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
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
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(r: 244, g: 66, b: 66)
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.keyboardDismissMode = .interactive
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(forName: APP_TERMINATE, object: nil, queue: nil, using: { notification in
            self.removeChannel()
        })
        lookingForChannel()
        hideKeyboard()
        setupKeyBoard()
        
        //        setupInputsContainer()
    }
    
    
    
    var inImagePicker = false
    override func viewDidDisappear(_ animated: Bool) {
        if !inImagePicker {
            removeChannel()
            anonymousChannelRef.removeAllObservers()
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    
    func setupKeyBoard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowKeyBoard), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHideKeyBoard), name: .UIKeyboardDidHide, object: nil)
    }
    
    func handleHideKeyBoard(notification : NSNotification) {
        if self.messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    var keyBoardDidShow = false
    
    func handleShowKeyBoard(notification : NSNotification) {
        //        let keyboard = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as! NSValue
        //        let keyboardFrame = keyboard.cgRectValue
        if self.messages.count > 0 && keyBoardDidShow {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        
        keyBoardDidShow = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //NEED TO ADD function VIEWWILLTRANSITION TO HANDLE WHEN ROTATE THE SCREEN HORIZONTALLY
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MessageCell
        
        let message = messages[indexPath.item]
        cell.messageImageView.isHidden = true
        setupCellUI(cell: cell, message: message)
        cell.anonymousChatLogController = self
        cell.message = message
        cell.delegate = self
        
        // added by Eastern Neverlose
        // check if this message if a special message
        if message.text != nil {
            if specialMessagefilter(message: message.text!) {
                cell.textView.text = "📞 video called"
                
                // check if this message is new, sent less than 1 minute by now
                // also check who send this message. if sent by you, you cannot touch it to answer
                let isFromSender = message.fromID == FIRAuth.auth()?.currentUser?.uid
                if checkTimestamp(time: message.timeStamp!) && !isFromSender {
                    cell.textView.text = "📞 video calling, tap to answer"
                    // add gesture to it, so we can click to this message
                    // and to straight to videoCallController
                    cell.textView.isUserInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: #selector(VideoCallMessageTouched))
                    cell.textView.addGestureRecognizer(tap)
                    var mes = message.text!
                    
                    _ = mes.characters.popFirst()
                    _ = mes.characters.popLast()
                    chatID = mes
                }
            } else {
                cell.textView.text = message.text!
            }
        }
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = getEstimatedFrameForText(text: text).width + 16
        }
        else if message.imageURL != nil {
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.bubbleWidthAnchor?.constant = 200
        }
        cell.playButton.isHidden = message.videoURL == nil
        return cell
    }
    
    var blackBackground : UIView?
    var originalImageFrame : CGRect?
    var originalImageView : UIImageView?
    
    func performZoomInToViewImageMessage(originalImageView : UIImageView) {
        dismissKeyboard()
        originalImageFrame = originalImageView.superview?.convert(originalImageView.frame, to: nil)
        self.originalImageView = originalImageView
        self.originalImageView?.isHidden = true
        let zoomingImageView = UIImageView(frame: originalImageFrame!)
        zoomingImageView.image = originalImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutToCancelViewImageMessage)))
        zoomingImageView.isUserInteractionEnabled = true
        self.blackBackground?.backgroundColor = UIColor.black
        inputAccessoryView?.isHidden = true
        if let screenFrame = UIApplication.shared.keyWindow {
            blackBackground = UIView(frame: screenFrame.frame)
            screenFrame.addSubview(blackBackground!)
            screenFrame.addSubview(zoomingImageView)
            
            let zoomingHeight : CGFloat = (originalImageFrame!.height / originalImageFrame!.width) * screenFrame.frame.width
            UIView.animate(withDuration: 0.5, animations: {
                self.blackBackground?.backgroundColor = UIColor.black
                self.blackBackground?.alpha = 1
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: screenFrame.frame.width, height: zoomingHeight)
                zoomingImageView.center = screenFrame.center
            }, completion: nil)
        }
    }
    
    func handleZoomOutToCancelViewImageMessage(tapGesture : UITapGestureRecognizer) {
        if let zoomOutImage = tapGesture.view {
            zoomOutImage.layer.cornerRadius = 16
            zoomOutImage.clipsToBounds = true
            inputAccessoryView?.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                zoomOutImage.frame = self.originalImageFrame!
                self.blackBackground?.alpha = 0
            }) { (completed) in
                //do something
                zoomOutImage.removeFromSuperview()
                self.originalImageView?.isHidden = false
            }
        }
    }
    
    private func setupCellUI(cell : MessageCell, message : Message) {
        if let messageImageURL = message.imageURL {
            cell.messageImageView.setImageWith(URL(string: messageImageURL)!)
            cell.messageImageView.isHidden = false
            cell.textView.isHidden = true
        }
        else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }
        
        if let profileImageURL = self.user?.profileImageURL {
            cell.profileImageView.setImageWith(URL(string: profileImageURL)!, placeholderImage: UIImage(named: "default_avatar"))
        }
        
        //Check to setup the UI if it is from the current user or not
        if message.fromID != userID! {
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
        let width = UIScreen.main.bounds.width
        
        if let text = messages[indexPath.item].text {
            height = getEstimatedFrameForText(text: text).height + 20
        } else if let originalWidth = messages[indexPath.item].imageWidth?.floatValue,
            let originalHeight = messages[indexPath.item].imageHeight?.floatValue {
            height = CGFloat((originalHeight * 200) / originalWidth)
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func getEstimatedFrameForText(text : String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        
        //NOTE : try to google how to dynamically change the height of UICollectionViewCell
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func handleUploadImageOrVideoTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        inImagePicker = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL {
            handleSelectVideoFromPicker(localVideoURL: videoURL)
        } else {
            handleSelectImageFromPicker(info: info as [String : AnyObject])
        }
        dismiss(animated: true, completion: { completion in
            self.inImagePicker = false
        })
    }
    
    private func handleSelectImageFromPicker(info : [String : AnyObject]) {
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
            uploadImageToFireBaseStorage(imageToUpload: selectedImage, completion: { (imageURL) in
                self.sendMessagesWithProperties(properties: ["imageURL" : imageURL, "imageHeight" : selectedImage.size.height,
                                                             "imageWidth" : selectedImage.size.width])
            })
        }
    }
    
    //videoURL parameter below is
    private func handleSelectVideoFromPicker(localVideoURL : NSURL) {
        let fileName = UUID().uuidString + ".mov"
        let uploadTask = FIRStorage.storage().reference().child("movie-messages").child(fileName).putFile(localVideoURL as URL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Fail to upload video", error!)
                return
            }
            
            //get the URL to video URL on Firebase
            if let storageVideoURL = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageForLocalVideoMessage(localVideoURL: localVideoURL) {
                    self.uploadImageToFireBaseStorage(imageToUpload: thumbnailImage, completion: { (imageURL) in
                        let properties: [String : Any] = ["videoURL" : storageVideoURL, "imageWidth" : thumbnailImage.size.width, "imageHeight" : thumbnailImage.size.height, "imageURL" : imageURL]
                        self.sendMessagesWithProperties(properties: properties)
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageForLocalVideoMessage(localVideoURL : NSURL) -> UIImage? {
        let asset = AVAsset(url: localVideoURL as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let error {
            print(error)
        }
        
        return nil
    }
    
    lazy var inputViewContainer : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image")?.withRenderingMode(.alwaysOriginal)
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImageOrVideoTap)))
        
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
        
        containerView.addSubview(self.inputsTextField)
        self.inputsTextField.rightAnchor.constraint(equalTo: sendButtonView.leftAnchor).isActive = true
        self.inputsTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputsTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        self.inputsTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let lineSepeartor = UIView()
        lineSepeartor.backgroundColor = UIColor.darkGray
        lineSepeartor.translatesAutoresizingMaskIntoConstraints = false
        lineSepeartor.alpha = 0.5
        
        containerView.addSubview(lineSepeartor)
        lineSepeartor.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        lineSepeartor.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        lineSepeartor.bottomAnchor.constraint(equalTo: self.inputsTextField.topAnchor).isActive = true
        lineSepeartor.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputViewContainer
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func handleSend() {
        sendMessagesWithProperties(properties: ["text" : inputsTextField.text!])
    }
    
    private func sendMessagesWithProperties(properties : [String : Any]) {
        let fromID = FIRAuth.auth()?.currentUser?.uid
        let timeStamp : Int = Int(NSDate().timeIntervalSince1970)
        
        var values : [String : Any] = ["fromID" : fromID!, "timeStamp" : timeStamp]
        
        for key in properties.keys {
            values[key] = properties[key]
        }
        let ref = anonymousChannelRef.child(connectedChannel).child("messages")
        let messagesRef = ref.childByAutoId()
        messagesRef.updateChildValues(values)
        self.inputsTextField.text = nil
    }
    
    private func removeAnonymousMessages() {
        var channelToRemove = ""
        (connectedChannel == "") ? (channelToRemove = connectedChannel) : (channelToRemove = connectedChannel)
        let messagesRef = FIRDatabase.database().reference().child("anonymous-messages").child(channelToRemove)
        let userMessagesRef = FIRDatabase.database().reference().child("anonymous-user-messages").child(connectedChannel).child(channelToRemove)
        messagesRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                snapshot.ref.removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                    }
                })
            }
            
        })
        userMessagesRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                snapshot.ref.removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                    }
                })
            }
        })
    }
    
    private func uploadImageToFireBaseStorage(imageToUpload : UIImage, completion: @escaping (_ imageURL: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("image_messages").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(imageToUpload, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                }
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    completion(imageURL)
                }
            })
        }
    }
}

extension AnonymousChatController : messageCellProtocol {
    func didPressPlayVideoButton(videoURL: String) {
        let playerVC = AVPlayerViewController()
        let player = AVPlayer(url: URL(string: videoURL)!)
        if #available(iOS 10.0, *) {
            player.playImmediately(atRate: 1)
        } else {
            // Fallback on earlier versions
        }
        playerVC.player = player
        present(playerVC, animated: true, completion: nil)
    }
}

extension AnonymousChatController {
    
    func showHUD() {
        spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerActivity.label.text = "Matching a new user..."
        spinnerActivity.mode = MBProgressHUDMode.indeterminate
        spinnerActivity.button.setTitle("Cancel", for: .normal)
        spinnerActivity.button.addTarget(self, action: #selector(handleCancelOnHUD), for: .touchUpInside)
        spinnerActivity.button.isUserInteractionEnabled = true
        self.inputAccessoryView?.isUserInteractionEnabled = false
    }
    
    func showHUDOnKickedOut() {
        spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerActivity.label.text = "Your partner has gone:("
        spinnerActivity.detailsLabel.text = "Press OK to dismiss"
        spinnerActivity.mode = MBProgressHUDMode.text
        spinnerActivity.button.setTitle("OK", for: .normal)
        spinnerActivity.button.addTarget(self, action: #selector(dismissThisView), for: .touchUpInside)
        spinnerActivity.button.isUserInteractionEnabled = true
        self.inputAccessoryView?.isUserInteractionEnabled = false
    }
    
    func dismissThisView() {
        self.spinnerActivity.hide(animated: true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func hideHUD() {
        self.spinnerActivity.mode = MBProgressHUDMode.customView
        self.spinnerActivity.customView = UIImageView(image: UIImage(named: "checkmark"))
        self.spinnerActivity.label.text = "Matched !!!"
        self.spinnerActivity.hide(animated: true, afterDelay: 2)
        self.view.isUserInteractionEnabled = true
        self.inputAccessoryView?.isUserInteractionEnabled = true

    }
    
    func handleCancelOnHUD() {
        removeChannel()
        handleChannelTerminated()
    }
    
}

//    func pairingWithStranger(channelRef : FIRDatabaseReference) {
//        channelRef.observeSingleEvent(of: .value, with: { snapshot in
//            guard let dictionary = snapshot.value as? [String : AnyObject] else {
//                return
//            }
//            var chatID = ""
//            if (snapshot.childrenCount == 1) {
//                channelRef.observe(.childAdded, with: { (snapshot) in
//                    if (snapshot.key == "Second") {
//                        self.findChatPartnerByID(userID: snapshot.value as! String)
//                    }
//                })
//            }
//            else if (snapshot.childrenCount == 2) {
//                (dictionary["Second"] as! String == self.userID!) ? (chatID = dictionary["First"] as! String) : (chatID = dictionary["Second"] as! String)
//                self.findChatPartnerByID(userID: chatID)
//            }
//        })
//    }



