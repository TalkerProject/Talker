//
//  MessageCell.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 11/3/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import AVFoundation
class MessageCell: UICollectionViewCell {
    
    var chatLogController : ChatLogController?
    var message : Message?
    let textView : UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isEditable = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    lazy var playButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play_button")
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor.white
        btn.addTarget(self, action: #selector(handlePlayVideo), for: .touchUpInside)
        return btn
    }()
    
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    func handlePlayVideo() {
        if let videoURL = message?.videoURL, let url = URL(string: videoURL) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            messageImageView.layer.addSublayer(playerLayer!)
            playButton.isHidden = true
            player?.play()
            print("Playing Video")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    let bubbleView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 189, b: 252)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_avatar")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapImageMessage)))
        return imageView
    }()
    
    func handleTapImageMessage(tapGesture : UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInToViewImageMessage(originalImageView: imageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has been failed")
    }
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleLeftAnchor : NSLayoutConstraint?
    var bubbleRightAnchor : NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(bubbleView)
        self.addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(textView)
        bubbleView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant: 8)
        bubbleLeftAnchor?.isActive = true
        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = textView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        
    }
    
}
