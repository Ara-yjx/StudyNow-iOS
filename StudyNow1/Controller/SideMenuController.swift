//
//  SideMenuController.swift
//  StudyNow1
//
//  Created by YUAN YAO on 2/8/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import Firebase
import Foundation
import SideMenu

class SideMenuController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var messageController: MessagesController?
    var user: User?

    let profileImageView: UIButton = {
        let imageView = UIButton()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let nameField: UILabel = {
        let textView = UILabel()
        textView.text = "NAME"
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .black
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = .center
        return textView
    }()

    let pickClassButtom: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pick Class", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleClassPicker), for: .touchUpInside)
        return button
    }()

    let logoutItem: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log out", for: .normal)
        // button.backgroundColor = UIColor.lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard SideMenuManager.default.menuBlurEffectStyle == nil else {
            return
        }

        view.backgroundColor = UIColor.white
        setupProfileField()
    }

    func setupProfileField() {
        view.addSubview(profileImageView)
        view.addSubview(nameField)
        view.addSubview(pickClassButtom)
        view.addSubview(logoutItem)

        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageView.addTarget(self, action: #selector(handleSelectProfileImageView), for: .touchUpInside)

        nameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16).isActive = true
        nameField.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        nameField.heightAnchor.constraint(equalToConstant: 36).isActive = true

        pickClassButtom.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pickClassButtom.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16).isActive = true
        pickClassButtom.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pickClassButtom.heightAnchor.constraint(equalToConstant: 36).isActive = true

        logoutItem.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutItem.topAnchor.constraint(equalTo: pickClassButtom.bottomAnchor, constant: 16).isActive = true
        logoutItem.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        logoutItem.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

    func loadSideBarInfo(user: User) {
        self.user = user
        guard let profileImageUrl = user.profileImageUrl else { return }
        profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        nameField.text = user.name
    }

    @objc func handleLogout() {
        dismiss(animated: true, completion: {
            self.messageController?.handleLogout()
        })
    }

    @objc func handleClassPicker() {
        let classPickerController = ClassPickerController()
        classPickerController.user = user
        let navController = UINavigationController(rootViewController: classPickerController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func handleSelectProfileImageView() {
        print("clicked")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.setBackgroundImage(selectedImage, for: .normal)
        }
        
        // succesfully athenticated users
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
        if let profileImage = self.profileImageView.backgroundImage(for: .normal), let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            // change to JPEG for better compression, current resolution: 0.1
            storageRef.putData(uploadData, metadata: nil, completion: { metadata, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    self.user?.profileImageUrl = profileImageUrl
                    if let uid = self.user?.uid{
                        let values = ["name": self.user?.name, "email": self.user?.email, "profileImageUrl": self.user?.profileImageUrl]
                        Database.database().reference().child("users").child(uid).updateChildValues(values)
                    }
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
