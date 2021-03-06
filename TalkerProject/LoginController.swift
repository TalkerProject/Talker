//
//  LoginController.swift
//  TalkerProject
//
//  Created by Nguyen Duc Gia Bao on 10/18/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import UIKit
import Firebase
import BetterSegmentedControl
import SkyFloatingLabelTextField

class LoginController: UIViewController {
    
    //the container view to input email and password to login
    let inputsViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    //the textfields inside the above container view
    let nameTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Username"
        textField.lineColor = UIColor.clear
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.selectedTitleColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Email"
        textField.lineColor = UIColor.clear
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.selectedTitleColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let pwTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Password"
        textField.lineColor = UIColor.clear
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.selectedTitleColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        return textField
    }()
    
    //the login/register button under the above container view
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 224, g: 56, b: 56)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    //the segmented control to change between Login and Register
    lazy var loginRegisterControl : BetterSegmentedControl = {
        let control = BetterSegmentedControl(frame: CGRect(x: 0.0, y: 100.0,
                                                                        width: self.view.bounds.width, height: 44.0),
                                                          titles: ["  Login","Register"],
                                                          index: 1,
                                                          backgroundColor: UIColor.black,
                                                          titleColor: .white,
                                                          indicatorViewBackgroundColor: UIColor(red:0.55, green:0.26, blue:0.86, alpha:1.00),
                                                          selectedTitleColor: .black)
        control.cornerRadius = 6.0
        control.addTarget(self, action: #selector(loginRegisterControlValueChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    var inputsViewContainerHeightAnchor : NSLayoutConstraint?
    var emailTextFieldHeightAnchor : NSLayoutConstraint?
    var nameTextFieldHeightAnchor : NSLayoutConstraint?
    var pwTextFieldHeightAnchor : NSLayoutConstraint?

    
    func loginRegisterControlValueChanged() {
        let index : Int = (Int)(loginRegisterControl.index)
        let title = loginRegisterControl.titles[index]
        loginRegisterButton.titleLabel?.text = title
        inputsViewContainerHeightAnchor?.constant = (index) == 0 ? 120 : 180
     
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsViewContainer.heightAnchor, multiplier: (index) == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        if (index == 0) {
            nameTextField.isHidden = true
        }
        else {
            nameTextField.isHidden = false
        }
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsViewContainer.heightAnchor, multiplier: (index) == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        pwTextFieldHeightAnchor?.isActive = false
        pwTextFieldHeightAnchor = pwTextField.heightAnchor.constraint(equalTo: inputsViewContainer.heightAnchor, multiplier: (index) == 0 ? 1/2 : 1/3)
        pwTextFieldHeightAnchor?.isActive = true
        
}
    var messagesVC : MessagesController?
    var settingVC : SettingController?
    
    func handleLogin() {
        guard let email = emailTextField.text , let pw = pwTextField.text else {
            print("Email and password is not valid")
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: pw, completion: { (user, error) in
            if (error != nil) {
                print(error!)
                return
            }
            
            print("Sign in successfully")
            self.dismiss(animated: true, completion: nil)
            self.settingVC?.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleLoginRegister() {
        if (loginRegisterControl.index == 0) {
            handleLogin()
        }
        else {
            handleRegister()
        }
    }
    func handleRegister() {
        guard let name = nameTextField.text , let pw = pwTextField.text, let email = emailTextField.text  else {
            print("Email or password is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: pw, completion: { (user: FIRUser?, error) in
            if error != nil {
                print(error!)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            //authentication successfully
            print("Authenticated successfully")
            var ref : FIRDatabaseReference!
            ref = FIRDatabase.database().reference()
            let values = ["name" : name, "email" : email, "password" : pw]
            let userReference = ref.child("users").child(uid)
            userReference.updateChildValues(values, withCompletionBlock: { (error, ref : FIRDatabaseReference?) in
                if error != nil {
                    print(error!)
                    return
                }
                self.messagesVC?.fetchUser()
                self.dismiss(animated: true, completion: nil)
                self.settingVC?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    //the app icon
    let appIconView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "talk")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let backgroundImage : UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "login_background")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //view.backgroundColor = UIColor(r: 69, g: 72, b: 76)
//        view.backgroundColor = UIColor(patternImage: UIImage(named: "login_background")!)
        view.addSubview(inputsViewContainer)
        view.addSubview(loginRegisterButton)
        view.addSubview(appIconView)
        view.addSubview(loginRegisterControl)
        view.addSubview(backgroundImage)
        view.sendSubview(toBack: backgroundImage)
        
        hideKeyboard()
        setupInputsViewConstaints()
        setupLoginRegisterButtonConstraints()
        setupAppIconView()
        setupLoginRegisterControlConstraints()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //setup the autolayout for the app icon imageView
    func setupAppIconView() {
        //needs x, y , height, width
        appIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appIconView.bottomAnchor.constraint(equalTo:  loginRegisterControl.topAnchor, constant: -12).isActive = true
        appIconView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        appIconView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //setup the autolayout for the login/register segmented control
    func setupLoginRegisterControlConstraints() {
        //needs x, y , height, width
        loginRegisterControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterControl.bottomAnchor.constraint(equalTo: inputsViewContainer.topAnchor, constant: -12).isActive = true
        loginRegisterControl.widthAnchor.constraint(equalTo: inputsViewContainer.widthAnchor).isActive = true
        loginRegisterControl.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
    }

    //setup the autolayout for the input container view
    func setupInputsViewConstaints() {
        
        //needs x, y , height, width
        //set constraint for inputsViewContainer
        inputsViewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsViewContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsViewContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsViewContainerHeightAnchor = inputsViewContainer.heightAnchor.constraint(equalToConstant: 180)
        inputsViewContainerHeightAnchor?.isActive = true
        
        inputsViewContainer.addSubview(nameTextField)
        inputsViewContainer.addSubview(emailTextField)
        inputsViewContainer.addSubview(pwTextField)
        
        //set constraint for emailTextField
        nameTextField.leftAnchor.constraint(equalTo: inputsViewContainer.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsViewContainer.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsViewContainer.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsViewContainer.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //set constraint for nameTextField
        emailTextField.leftAnchor.constraint(equalTo: inputsViewContainer.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsViewContainer.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsViewContainer.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //set constraint for pwTextField
        pwTextField.leftAnchor.constraint(equalTo: inputsViewContainer.leftAnchor, constant: 12).isActive = true
        pwTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        pwTextField.widthAnchor.constraint(equalTo: inputsViewContainer.widthAnchor).isActive = true
        pwTextFieldHeightAnchor = pwTextField.heightAnchor.constraint(equalTo: inputsViewContainer.heightAnchor, multiplier: 1/3)
        pwTextFieldHeightAnchor?.isActive = true
        
    }
    
    //setup the autolayout for the login/register button
    func setupLoginRegisterButtonConstraints() {
        //needs x, y, height, width
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsViewContainer.bottomAnchor, constant: 50).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

// create a more convenient function by writing extension for class UIColor
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: g/255, alpha: 1)
    }
}

// function to dismiss the keyboard by tapping anywhere on the view
extension UIViewController {
    func hideKeyboard() {
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


