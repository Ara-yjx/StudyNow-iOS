//
//  LoginController.swift
//  StudyNow1
//
//  Created by YUAN YAO on 1/26/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import Firebase
import GoogleSignIn
import UIKit
import UITextField_Shake

class LoginController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    var messageController: MessagesController?

    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    let loginButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()

    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        tf.placeholder = "Email"
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
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.keyboardAppearance = .dark
        tf.returnKeyType = .join
        return tf
    }()

    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "studyNowSplash")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Don't have an account? Register here!", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            handleLogin()
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            emailTextField.placeholder = "Email"
        } else if textField == passwordTextField {
            passwordTextField.placeholder = "Password"
        }
    }

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        navigationController?.navigationBar.tintColor = UIColor.white

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(inputsContainerView)
        view.addSubview(loginButton)
        view.addSubview(logoImageView)
        view.addSubview(registerButton)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignKeyboard)))

        emailTextField.delegate = self
        passwordTextField.delegate = self

        setupInputsContainerView()
        setupLoginButton()
        setupLogo()
        setupRegisterButton()
    }

    func setupRegisterButton() {
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        registerButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    func setupLogo() {
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -48).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }

    func setupInputsContainerView() {
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)

        // email field
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true

        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1 / 2).isActive = true

        // separator
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // password field
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1 / 2).isActive = true
    }

    func setupLoginButton() {
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    // MARK: - Action handler

    @objc func resignKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @objc func handleLogin() {
        loginButton.showLoading()

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        guard let email = emailTextField.text, let password = passwordTextField.text
        else {
            fatalError("textfield is nil")
        }

        if emailTextField.text == "" {
            emailTextField.shake(2, withDelta: 4, speed: 0.07)
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Email cannot be empty", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
        }

        if passwordTextField.text == "" {
            passwordTextField.shake(2, withDelta: 4, speed: 0.07)
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password cannot be empty", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
        }

        if (emailTextField.text == "") || (passwordTextField.text == "") {
            loginButton.hideLoading()
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if error != nil {
                debugPrint(error)

                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.emailTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "🌚 Email address is invalid", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                    case .userNotFound:
                        self.emailTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "🌚 Account doesn't exist", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                    case .wrongPassword:
                        self.passwordTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.passwordTextField.text = ""
                        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "🌚 The password is incorrect", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                    default:
                        self.emailTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.passwordTextField.shake(2, withDelta: 4, speed: 0.07)
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                    }
                }
                self.loginButton.hideLoading()
                return
            }

            // Ask for registor remote notification
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerRemoteNotification(UIApplication.shared)

            self.messageController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: {
            })
        }
    }

    @objc func handleRegister() {
        let registerController = RegisterController()
        registerController.messageController = messageController
        navigationController?.pushViewController(registerController, animated: true)
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

        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let maxYButton = loginButton.frame.maxY + 12
            let maxYKeyboard = SCREEN_HEIGHT - keyboardHeight
            if maxYButton > maxYKeyboard {
                UIView.animate(withDuration: keyboardDuration!, animations: {
                    self.view.frame.origin.y = maxYKeyboard - maxYButton
                })
            }
        } else {
            UIView.animate(withDuration: keyboardDuration!, animations: {
                self.view.frame.origin.y = -100
            })
        }
    }

    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.frame.origin.y = 0
        })
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
}
