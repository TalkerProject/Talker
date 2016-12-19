//
//  CopyRight.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 12/20/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
class CopyRight : UIViewController {
    
    let subView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        view.addSubview(subView)
        subView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        subView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        subView.heightAnchor.constraint(equalToConstant: 30)
        subView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
    }
    
    
}
