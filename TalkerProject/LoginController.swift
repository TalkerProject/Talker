//
//  LoginController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/18/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    //the container view to input email and password to login
    let inputsViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    //the textfields inside the above container view
    let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your phone number"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    //the login/register button under the above container view
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 224, g: 56, b: 56)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(r: 244, g: 66, b: 66)
        view.addSubview(inputsViewContainer)
        view.addSubview(loginRegisterButton)
        setupInputsViewConstaints()
        setupLoginRegisterButtonConstraints()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //setup the autolayout for the input container view
    func setupInputsViewConstaints() {
        //needs x, y , height, width
        inputsViewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsViewContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsViewContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsViewContainer.heightAnchor.constraint(equalToConstant: 150).isActive = true
        inputsViewContainer.addSubview(phoneTextField)
        
        //needs x, y , height, width for text field
        phoneTextField.leftAnchor.constraint(equalTo: inputsViewContainer.leftAnchor, constant: 12).isActive = true
        phoneTextField.topAnchor.constraint(equalTo: inputsViewContainer.topAnchor).isActive = true
        phoneTextField.widthAnchor.constraint(equalTo: inputsViewContainer.widthAnchor).isActive = true
        phoneTextField.heightAnchor.constraint(equalTo: inputsViewContainer.heightAnchor, multiplier: 1/3).isActive = true
    }
    
    //setup the autolayout for the login/register button
    func setupLoginRegisterButtonConstraints() {
        //needs x, y, height, width
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsViewContainer.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: g/255, alpha: 1)
    }
}
