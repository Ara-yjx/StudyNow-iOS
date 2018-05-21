//
//  newGroupChatTableViewController.swift
//  StudyNow1
//
//  Created by 刘恒宇 on 2018/2/24.
//  Copyright © 2018年 GoStudyNow. All rights reserved.
//

import Firebase
import UIKit

class newGroupChatTableViewController: UITableViewController {
    var users = [User]()
    var selectedUsers = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Start Group Chat"
        selectedUsers.removeAll()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleCreate))
        fetchUser()
    }

    @objc func handleCancel() {
        navigationController?.popViewController(animated: true)
    }

    var messagesController: MessagesController?

    @objc func handleCreate() {
        if selectedUsers.count < 2 {
            navigationController?.popViewController(animated: true)
            return
        }

        // Update group part
        let groupRootRef = Database.database().reference().child("groups")
        let roomRef = groupRootRef.childByAutoId()

        let groupName = "Group Chat (\(selectedUsers.count + 1))"
        roomRef.updateChildValues(["Name": groupName])

        roomRef.child("Members").updateChildValues([Auth.auth().currentUser!.uid: 1])
        for user in selectedUsers {
            roomRef.child("Members").updateChildValues([user.uid!: 1])
        }

        // Update user-message part
        let roomID = roomRef.key
        Database.database().reference().child("user-messages").child(Auth.auth().currentUser!.uid).child("Group").updateChildValues([roomID: 1])
        for user in selectedUsers {
            let userMessageRef = Database.database().reference().child("user-messages").child(user.uid!).child("Group")
            userMessageRef.updateChildValues([roomID: 1])
        }
        
        sendJoinMessage(roomID: roomID)

        navigationController?.popViewController(animated: true)
        self.messagesController?.showChatControllerForUser(roomID: roomID, roomType: .group, title: groupName)
    }
    
    fileprivate func sendJoinMessage(roomID: String) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = roomID
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        Database.database().reference().child("users").child(fromId).observeSingleEvent(of: .value, with: { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                if let username = user.name {
                    var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "text": (username + " has joined this group") as AnyObject]
                    
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
                    var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "text": "A new student has joined this group" as AnyObject]
                    
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

    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.uid = snapshot.key
                if user.uid != Auth.auth().currentUser?.uid {
                    self.users.append(user)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return users.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        return cell
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
        cell?.isSelected = false
    }
}
