//
//  RegisterController.swift
//  StudyNow1
//
//  Created by YUAN YAO on 2/20/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import Firebase
import UIKit

class RegisterController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    var messageController: MessagesController?

    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()

    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.returnKeyType = .next
        tf.keyboardAppearance = .dark
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()

    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let passwordRepeatTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Repeat your Password"
        tf.returnKeyType = .join
        tf.keyboardAppearance = .dark
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()

    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "uploadProfileImage")
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))

        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(inputsContainerView)
        view.addSubview(registerButton)
        view.addSubview(profileImageView)

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordRepeatTextField.delegate = self

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignKeyboard)))

        setupInputsContainerView()
        setupProfileImageView()
        setupRegisterButton()
    }

    func setupProfileImageView() {
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -24).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }

    func setupInputsContainerView() {
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeparatorView)
        inputsContainerView.addSubview(passwordRepeatTextField)

        // name field
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1 / 4).isActive = true

        // separator
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // email field
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true

        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1 / 4).isActive = true

        // separator
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // password field
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1 / 4).isActive = true

        // separator
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // password repeat field
        passwordRepeatTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordRepeatTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordRepeatTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordRepeatTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1 / 4).isActive = true
    }

    func setupRegisterButton() {
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordRepeatTextField.becomeFirstResponder()
        } else if textField == passwordRepeatTextField {
            handleRegister()
        }
        return false
    }

    @objc func resignKeyboard() {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordRepeatTextField.resignFirstResponder()
    }

    @objc func handleRegister() {
        resignKeyboard()

        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let repeatPassword = passwordRepeatTextField.text
        else {
            fatalError("textfield is nil")
        }

        // TODO: Under development environment, ignore email constrain
        //        if !email.contains("ucsb"){
        //            print("not ucsb email")
        //            return
        //        }
        
        if repeatPassword != password {
            self.passwordTextField.shake(2, withDelta: 4, speed: 0.07)
            self.passwordRepeatTextField.shake(2, withDelta: 4, speed: 0.07)
            self.passwordRepeatTextField.text = ""
            self.passwordTextField.text = ""
            self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Please double check your password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.emailTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.passwordRepeatTextField.text = ""
                        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "🌚 Email address is invalid", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                    case .emailAlreadyInUse:
                        self.emailTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.passwordRepeatTextField.text = ""
                        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "🌚 Account has existed", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                    case .weakPassword:
                        self.passwordTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.passwordTextField.text = ""
                        self.passwordRepeatTextField.text = ""
                        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "🌚 Your password is too weak", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                    default:
                        self.emailTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.passwordTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.passwordRepeatTextField.text = ""
                    }
                }
                return
            }

            guard let uid = user?.uid else {
                return
            }

            // succesfully athenticated users
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                // change to JPEG for better compression, current resolution: 0.1
                storageRef.putData(uploadData, metadata: nil, completion: { metadata, error in
                    if error != nil {
                        print(error!)
                        return
                    }

                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String: AnyObject])
                    }
                })
            }
        }
    }

    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)

        usersReference.updateChildValues(values, withCompletionBlock: { err, _ in
            if err != nil {
                print(err!)
                return
            }
            let user = User(dictionary: values)
            user.uid = uid
            self.messageController?.fetchUserAndSetupNavBarTitle()
            let classPickerController = ClassPickerController()
            classPickerController.user = user
            self.navigationController?.pushViewController(classPickerController, animated: true)
            // self.dismiss(animated: true, completion: nil)
        })
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupKeyboardObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        UIView.animate(withDuration: keyboardDuration!, animations: {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height

                self.view.frame.origin.y = ((self.view.frame.height - (self.registerButton.frame.maxY + 12 + keyboardHeight)) > -100) && ((self.view.frame.height - (self.registerButton.frame.maxY + 12 + keyboardHeight)) < 0) ? (self.view.frame.height - (self.registerButton.frame.maxY + 12 + keyboardHeight)) : -100
            } else {
                self.view.frame.origin.y = -100
            }
        })
    }

    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.frame.origin.y = 0
        })
    }
}
