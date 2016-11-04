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
        tv.text = "ABCDEF"
        return tv
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has been failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(textView)
        
        //needs x,y,width, height as always
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
}
