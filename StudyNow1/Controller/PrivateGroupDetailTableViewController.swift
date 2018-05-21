//
//  PrivateGroupDetailTableViewController.swift
//  StudyNow1
//
//  Created by 刘恒宇 on 2018/4/22.
//  Copyright © 2018年 GoStudyNow. All rights reserved.
//

import UIKit
import Firebase

class PrivateGroupDetailTableViewController: UITableViewController {
    let cellId = "cellId"
    let cell2Id = "cell2Id"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Group members"
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change group name", style: .done, target: self, action: #selector(handleChangeName))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UserCell.self, forCellReuseIdentifier: cell2Id)
    }
    
    var roomID: String! {
        didSet {
            getUserArray()
            getInfo()
        }
    }
    
    var tag: String?
    
    var users = [User]()
    var selectedUsers = [User]()
    var groupID = [String]()
    var groupNames = [String: String]()
    var messagesController: MessagesController?
    
    func getInfo(){
        Database.database().reference().child("groups").child(roomID).child("Tag").observeSingleEvent(of: .value) { (snapshot) in
            if let tag = snapshot.value as? String {
                self.tag = tag
            }
        }
    }
    
    @objc func handleChangeName() {
        let alertController = UIAlertController(title: "Change the group name", message: "All changes will be shown to all group members immediately", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Group name"
        })
        let confirmAction = UIAlertAction(title: "Change", style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
            self.handleChangeNameServer(name: (alertController.textFields?[0].text)!)
        })
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func handleChangeNameServer(name: String) {
        Database.database().reference().child("groups").child(roomID).updateChildValues(["Name" : name])
        if let root = self.navigationController?.viewControllers.first as? MessagesController {
            root.attemptReloadOfTable()
        }
        if self.navigationController!.viewControllers.count > 0 , let parent = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as? ChatLogController {
            parent.title = name
        }
        sendJoinMessage(roomID: roomID, name: name)
    }
    
    fileprivate func sendJoinMessage(roomID: String, name: String) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = roomID
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        Database.database().reference().child("users").child(fromId).observeSingleEvent(of: .value, with: { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                if let username = user.name {
                    let values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "text": (username + " has changed the group name to " + name) as AnyObject]
                    
                    childRef.updateChildValues(values) { error, _ in
                        if error != nil {
                            print(error!)
                            return
                        }
                        let messageId = childRef.key
                        let roomRef = Database.database().reference().child("groups").child(toId).child("Messages")
                        roomRef.updateChildValues([messageId: 1])
                    }
                } else {
                    let values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "text": ("A student has changed the group name to " + name) as AnyObject]
                    
                    childRef.updateChildValues(values) { error, _ in
                        if error != nil {
                            print(error!)
                            return
                        }
                        let messageId = childRef.key
                        let roomRef = Database.database().reference().child("groups").child(toId).child("Messages")
                        roomRef.updateChildValues([messageId: 1])
                    }
                }
            }
        })
        
    }
    
    func handleSelectUI() {
        if selectedUsers.count > 0 {
            self.title = "Create a subgroup"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(handleCreate))
        } else {
            self.title = "Group members"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change group name", style: .done, target: self, action: #selector(handleChangeName))
        }
    }
    
    @objc func handleCreate() {
        
        if selectedUsers.count < 2 {
            navigationController?.popViewController(animated: true)
            self.messagesController?.showChatControllerForUser(roomID: selectedUsers[0].uid!, roomType: .individual, title: selectedUsers[0].name ?? "")
            return
        }
        
        
        let groupRootRef = Database.database().reference().child("groups")
        let roomRef = groupRootRef.childByAutoId()
        let roomID = roomRef.key
        
        // Update classes
        guard let tagg = tag else {return}
        
        Database.database().reference().child("classes").child(tagg).child("Private").updateChildValues([roomID:1])
        // Update group part
        let groupName = "Group Chat (\(selectedUsers.count + 1))"
        roomRef.updateChildValues(["Name": groupName])
        
        roomRef.child("Members").updateChildValues([Auth.auth().currentUser!.uid: 1])
        roomRef.updateChildValues(["Tag": tagg])
        
        for user in selectedUsers {
            roomRef.child("Members").updateChildValues([user.uid!: 1])
        }
        
        // Update user-message part
        
        Database.database().reference().child("user-messages").child(Auth.auth().currentUser!.uid).child("Group").updateChildValues([roomID: 1])
        for user in selectedUsers {
            let userMessageRef = Database.database().reference().child("user-messages").child(user.uid!).child("Group")
            userMessageRef.updateChildValues([roomID: 1])
        }

        navigationController?.popViewController(animated: true)
        self.messagesController?.showChatControllerForUser(roomID: roomID, roomType: .group, title: groupName)
    }
    
    
    func getUserArray() {
        Database.database().reference().child("groups").child(roomID).child("Members").observeSingleEvent(of: .value) { (shot) in
            // guard let 用来安全解包optional value
            guard let userDic = shot.value as? [String: AnyObject] else {
                fatalError("DataSnapShot.value cannot be converted to [String: AnyObject]")
            }
            var tempUserArray = [String]()
            for (key, _) in userDic {
                tempUserArray.append(key)
            }

            for userID in tempUserArray{
                Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        let user = User(dictionary: dictionary)
                        user.uid = snapshot.key
                        if user.uid != Auth.auth().currentUser?.uid {
                            self.users.append(user)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UserCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: cell2Id, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell!.textLabel?.text = user.name
        cell!.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            cell!.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.accessoryType != .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectedUsers.append(users[indexPath.row])
            
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            selectedUsers.remove(at: selectedUsers.index(where: { $0 == users[indexPath.row] })!)
        }
        
        if selectedUsers.count > 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        self.handleSelectUI()
        cell?.isSelected = false
    }
}

