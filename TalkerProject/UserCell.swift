//
//  UserCell.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/22/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    var message : Message? {
        didSet {
            if let toID = message?.toID {
                let ref = FIRDatabase.database().reference().child("users").child(toID)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String : AnyObject] {
                        self.textLabel?.text = dictionary["name"] as? String
                        self.detailTextLabel?.text = self.message?.text
                        if let profileImageURL = dictionary["profileImageURL"] as? String {
                            self.profileImageView.setImageWith(URL(string: profileImageURL)!)
                        }
                        else {
                            self.profileImageView.image = UIImage(named: "default_avatar")
                        }
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm:ss a"
                        if let seconds = self.message?.timeStamp?.doubleValue {
                            print("Seconds +" + "\(seconds)")
                            let date = NSDate(timeIntervalSince1970: seconds)
                            print("date +" + "\(date)")
                            self.timeLabel.text = formatter.string(from: date as Date)
                        }
                    }
                    
                    }, withCancel: nil)
            }
        }
    }
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel : UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //x,y, width, height for constraints
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //x,y, width, heght for constraints
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: self.textLabel!.heightAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
}
