//
//  LoginController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/18/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    let inputsViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(r: 244, g: 66, b: 66)
        let inputsViewContainer = UIView()
        view.addSubview(inputsViewContainer)
        inputsViewContainer.backgroundColor = UIColor.white
        inputsViewContainer.translatesAutoresizingMaskIntoConstraints = false
        inputsViewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsViewContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsViewContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsViewContainer.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

   
}
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: g/255, alpha: 1)
    }
}
