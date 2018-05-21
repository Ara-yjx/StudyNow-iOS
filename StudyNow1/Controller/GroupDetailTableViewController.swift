//
//  GroupDetailTableViewController.swift
//  StudyNow1
//
//  Created by 胡腾月 on 03/04/2018.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import UIKit
import Firebase

class GroupDetailTableViewController: UITableViewController {
    let cellId = "cellId"
    let cell2Id = "cell2Id"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Group members"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change group name", style: .done, target: self, action: #selector(handleChangeName))
        navigationItem.rightBarButtonItem = nil
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UserCell.self, forCellReuseIdentifier: cell2Id)
    }
    
    // MARK: - hty: get user number
    var roomID: String! {
        didSet {
            getUserArray()
            getInfo()
        }
    }
    
    var tag: String?{
        didSet{
            getGroupArray()
        }
    }
    
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
        
    }
    
    func handleSelectUI() {
        if selectedUsers.count > 0 {
            self.title = "Create a subgroup"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(handleCreate))
        } else {
            self.title = "Group members"
            navigationItem.rightBarButtonItem = nil
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change group name", style: .done, target: self, action: #selector(handleChangeName))
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
    
    func getGroupArray(){
        Database.database().reference().child("classes").child(self.tag!).child("Private").observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                for(key, _) in dictionary{
                    self.groupID.append(key)
               
                    Database.database().reference().child("groups").child(key).child("Name").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let name = snapshot.value as? String{
                            self.groupNames[key] = name
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                
                    
                    
                }
                
                print(self.groupID)
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ?? 表示如果之前的var为None的话 就执行？？之后的语句
        if(section == 0){
            return groupID.count
        }else{
            return users.count
        }
    }
    
    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "You can join these groups below"
        }else{
            return "Group Members"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UserCell?
        
        if indexPath.section == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
            cell!.textLabel?.text = groupNames[groupID[indexPath.row]] ?? "Loading..."
            cell!.groupImageView.loadImages(groupID: groupID[indexPath.row])
            cell!.groupImageView.alpha = 1;
            cell!.profileImageView.alpha = 0;
        } else if indexPath.section  == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: cell2Id, for: indexPath) as! UserCell
            let user = users[indexPath.row]
            cell!.textLabel?.text = user.name
            cell!.detailTextLabel?.text = user.email
            
            if let profileImageUrl = user.profileImageUrl {
                cell!.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
           
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if indexPath.section == 0 {
           
            Database.database().reference().child("user-messages").child(Auth.auth().currentUser!.uid).child("Group").child(groupID[indexPath.row]).observeSingleEvent(of: .value) { (snap) in
                if snap.value as? AnyObject != nil {
                    self.navigationController?.popToRootViewController(animated: true)
                    let temTitle = (tableView.cellForRow(at: indexPath) as! UserCell).textLabel?.text ?? ""
                    self.messagesController?.showChatControllerForUser(roomID: self.groupID[indexPath.row], roomType: .group, title: temTitle)
                } else {
                    Database.database().reference().child("groups").child(self.groupID[indexPath.row]).child("Members").updateChildValues([Auth.auth().currentUser!.uid: 1])
                    Database.database().reference().child("user-messages").child(Auth.auth().currentUser!.uid).child("Group").updateChildValues([self.groupID[indexPath.row]: self.tag])
                    self.navigationController?.popToRootViewController(animated: true)
                    let temTitle = (tableView.cellForRow(at: indexPath) as! UserCell).textLabel?.text ?? ""
                    self.messagesController?.showChatControllerForUser(roomID: self.groupID[indexPath.row], roomType: .group, title: temTitle)
                }
            }
            
        } else if indexPath.section == 1 {
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
        }
        self.handleSelectUI()
        cell?.isSelected = false
    }
}
