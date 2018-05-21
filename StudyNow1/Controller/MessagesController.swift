//
//  ViewController.swift
//  StudyNow1
//
//  Created by 刘恒宇 on 2018/1/24.
//  Copyright © 2018年 GoStudyNow. All rights reserved.
//

import Firebase
import SideMenu
import UIKit

class MessagesController: UITableViewController {
    let cellId = "cellId"
    let sideMenuController = SideMenuController()

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuController.messageController = self

        // Define the menus
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: sideMenuController)
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuAddPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: navigationController!.view)
        SideMenuManager.default.menuShadowOpacity = 0

        tableView.rowHeight = 72
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        checkIfUserIsLoggedIn()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
    }

    // MARK: - TableView related

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, commit _: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        if(indexPath.section == 1){
            let message = GroupMessages[indexPath.row]
            var ref = Database.database().reference().child("user-messages").child(uid)

//            if message.type == .group {
                ref = ref.child("Group")
            //} else if message.type == .individual {
              //  ref = ref.child("Individual")
           // }

            if let chatPartnerId = message.chatPartnerId() {
                ref.child(chatPartnerId).removeValue(completionBlock: { error, _ in
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                    // TODO: 这样做是存疑的
                    self.GroupMessageDic.removeValue(forKey: chatPartnerId)
                    self.GroupMessages.remove(at: indexPath.row)
                    DispatchQueue.main.async(execute: {
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                    })
                })
            }
        }else if (indexPath.section == 2){
            let message = IndividualMessages[indexPath.row]
            var ref = Database.database().reference().child("user-messages").child(uid)
          
                ref = ref.child("Individual")
            
            if let chatPartnerId = message.chatPartnerId() {
                ref.child(chatPartnerId).removeValue(completionBlock: { error, _ in
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                    // TODO: 这样做是存疑的
                    self.IndividualMessageDic.removeValue(forKey: chatPartnerId)
                    self.IndividualMessages.remove(at: indexPath.row)
                    DispatchQueue.main.async(execute: {
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                    })
                })
            }
        }
    }

    func attemptReloadOfTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadTable), userInfo: nil, repeats: false)
    }

    var timer: Timer?

    @objc func handleReloadTable() {
        PublicMessages = Array(PublicMessageDic.values)
        PublicMessages.sort(by: { (message1, message2) -> Bool in

            if let timestamp1 = message1.timestamp?.int32Value, let timestamp2 = message2.timestamp?.int32Value {
                return timestamp1 > timestamp2
            }
            return false
        })
        
        GroupMessages = Array(GroupMessageDic.values)
        GroupMessages.sort(by: { (message1, message2) -> Bool in
            
            if let timestamp1 = message1.timestamp?.int32Value, let timestamp2 = message2.timestamp?.int32Value {
                return timestamp1 > timestamp2
            }
            return false
        })
        
        IndividualMessages = Array(IndividualMessageDic.values)
        IndividualMessages.sort(by: { (message1, message2) -> Bool in
            
            if let timestamp1 = message1.timestamp?.int32Value, let timestamp2 = message2.timestamp?.int32Value {
                return timestamp1 > timestamp2
            }
            return false
        })
        
        
        
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            print("we reloaded the table")
            self.tableView.reloadData()
        })
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 72
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0){
            let message = PublicMessages[indexPath.row]
            guard let roomID = message.chatPartnerId() else {
                return
            }
            let temTitle = (tableView.cellForRow(at: indexPath) as! UserCell).textLabel?.text ?? ""
            showChatControllerForUser(roomID: roomID, roomType: message.type, title: temTitle)
        }else if (indexPath.section == 1){
             let message = GroupMessages[indexPath.row]
                guard let roomID = message.chatPartnerId() else {
                return
                }
                let temTitle = (tableView.cellForRow(at: indexPath) as! UserCell).textLabel?.text ?? ""
                showChatControllerForUser(roomID: roomID, roomType: message.type, title: temTitle)
        }else{
            let message = IndividualMessages[indexPath.row]
            guard let roomID = message.chatPartnerId() else {
            return
            }
            let temTitle = (tableView.cellForRow(at: indexPath) as! UserCell).textLabel?.text ?? ""
            showChatControllerForUser(roomID: roomID, roomType: message.type, title: temTitle)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return PublicMessages.count
        }else if (section == 1){
            return GroupMessages.count
        }else{
            return IndividualMessages.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        if(indexPath.section == 0){
            let message = PublicMessages[indexPath.row]
            cell.message = message
        }else if(indexPath.section == 1){
            let message = GroupMessages[indexPath.row]
            cell.message = message
        }else{
            let message = IndividualMessages[indexPath.row]
            cell.message = message
        }
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        observeUserMessages()
    }

    // MARK: - Messages related

    var PublicMessages = [Message]()
    var PublicMessageDic = [String: Message]()
    var GroupMessages = [Message]()
    var GroupMessageDic = [String: Message]()
    var IndividualMessages = [Message]()
    var IndividualMessageDic = [String: Message]()
    
    

    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        // Individual Message
        let individualRef = Database.database().reference().child("user-messages").child(uid).child("Individual")
        individualRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                for (key, _) in dic {
                    individualRef.child(key).observe(.childAdded, with: { snapshot in
                        let messageId = snapshot.key
                        self.fetchMessageWithMessageId(messageId: messageId, type: .individual)
                    })
                }
            }
        }
        individualRef.observe(.childAdded) { snapshot in
            let userId = snapshot.key

            individualRef.child(userId).observe(.childAdded, with: { snapshot in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId, type: .individual)
            })
        }
        individualRef.observe(.childRemoved, with: { snapshot in
            print(snapshot.key)
            print(self.PublicMessageDic)
            self.PublicMessageDic.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        })

        // Group Message
        let groupRef = Database.database().reference().child("user-messages").child(uid).child("Group")
        groupRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            for (groupId, _) in dictionary {
                Database.database().reference().child("groups").child(groupId).child("Messages").observe(.childAdded, with: { snapshot in
                    let messageId = snapshot.key
                    self.fetchMessageWithMessageId(messageId: messageId, type: .group)
                })
            }
        }
        groupRef.observe(.childAdded) { snapshot in
            let groupId = snapshot.key

            Database.database().reference().child("groups").child(groupId).child("Messages").observe(.childAdded, with: { snapshot in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId, type: .group)
            })
        }
        groupRef.observe(.childRemoved, with: { snapshot in
            print(snapshot.key)
            print(self.PublicMessageDic)
            self.PublicMessageDic.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        })
        
        // Group Message
        let publicRef = Database.database().reference().child("user-messages").child(uid).child("Public")
        publicRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            for (groupId, _) in dictionary {
                Database.database().reference().child("groups").child(groupId).child("Messages").observe(.childAdded, with: { snapshot in
                    let messageId = snapshot.key
                    self.fetchMessageWithMessageId(messageId: messageId, type: .publicg)
                })
            }
        }
        publicRef.observe(.childAdded) { snapshot in
            let groupId = snapshot.key
            
            Database.database().reference().child("groups").child(groupId).child("Messages").observe(.childAdded, with: { snapshot in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId, type: .publicg)
            })
        }
        publicRef.observe(.childRemoved, with: { snapshot in
            print(snapshot.key)
            print(self.PublicMessageDic)
            self.PublicMessageDic.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        })
    }

    private func fetchMessageWithMessageId(messageId: String, type: messageType) {
        let messageReference = Database.database().reference().child("messages").child(messageId)

        messageReference.observeSingleEvent(of: .value, with: { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary, type: type)
                // self.messages.append(message)
                
                switch type {
                case .publicg:
                    if let chatPartnerId = message.chatPartnerId() {
                        self.PublicMessageDic[chatPartnerId] = message
                    }
                case .group:
                    if let chatPartnerId = message.chatPartnerId() {
                        self.GroupMessageDic[chatPartnerId] = message
                        print("We have added groupMessage for \(chatPartnerId)")
                        print("abc \(self.GroupMessageDic)")
                    }
                case .individual:
                    if let chatPartnerId = message.chatPartnerId() {
                        self.IndividualMessageDic[chatPartnerId] = message
                    }
                }
            
                self.attemptReloadOfTable()
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "Forums"
        }else if (section == 1){
            return "Groups"
        }else{
            return "Individuals"
        }
    }

    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        navigationController?.pushViewController(newMessageController, animated: true)
    }

    @objc func handleNewGroupMessage() {
        let newMessageController = newGroupChatTableViewController()
        newMessageController.messagesController = self
        navigationController?.pushViewController(newMessageController, animated: true)
    }

    // MARK: - Login/out logistics

    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            // add delay to solve the warning message "Unbalanced calls to begin"
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            // Ask for registor remote notification
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerRemoteNotification(UIApplication.shared)

            // Configure navigation item
            fetchUserAndSetupNavBarTitle()
        }
    }

    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.uid = uid
                self.setupNavBarWithUser(user)
                self.sideMenuController.loadSideBarInfo(user: user)
            }
        })
    }

    func setupNavBarWithUser(_ user: User) {
        PublicMessages.removeAll()
        PublicMessageDic.removeAll()
        GroupMessages.removeAll()
        GroupMessageDic.removeAll()
        IndividualMessages.removeAll()
        IndividualMessageDic.removeAll()
        tableView.reloadData()

        observeUserMessages()

//        self.navigationItem.title = user.name
        navigationItem.title = "StudyNow"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.07450980392, green: 0.07450980392, blue: 0.07843137255, alpha: 1)
        navigationController?.navigationBar.barStyle = .black

        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        imageview.image = UIImage(named: "photo.jpg")
        imageview.contentMode = UIViewContentMode.scaleAspectFit
        imageview.layer.cornerRadius = 14
        imageview.layer.masksToBounds = true
        imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSideMenu)))
        imageview.isUserInteractionEnabled = true
        guard let profileImageUrl = user.profileImageUrl else { return }
        imageview.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        containView.addSubview(imageview)
        let leftBarButton = UIBarButtonItem(customView: containView)
        navigationItem.leftBarButtonItem = leftBarButton
    }

    @objc func showSideMenu() {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }

    func showChatControllerForUser(roomID: String, roomType: messageType, title: String) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.roomType = roomType
        chatLogController.roomID = roomID
        chatLogController.temTitle = title
        chatLogController.messagesController = self
        navigationController?.pushViewController(chatLogController, animated: true)
    }

    @objc func handleLogout() {
        do {
            if let uid = Auth.auth().currentUser?.uid {
                Database.database().reference().child("users").child(uid).child("token").removeValue()
                print("Deleted user past token")
            } else {
                print("No user token have to be deleted")
            }
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }

        let loginController = LoginController()
        loginController.messageController = self
        let navController = UINavigationController(rootViewController: loginController)
        navController.navigationBar.barStyle = .blackTranslucent
        present(navController, animated: true)
    }
}
