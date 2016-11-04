//
//  MessageCell.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 11/3/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    let textView : UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 189, b: 252)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has been failed")
    }
    var bubbleWidthAnchor : NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(bubbleView)
        self.addSubview(textView)
        
        //needs x,y,width, height as always
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        bubbleView.widthAnchor.constraint(equalToConstant: 200).isActive = true

        //needs x,y,width, height as always
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        bubbleWidthAnchor = textView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
    }
    
}
