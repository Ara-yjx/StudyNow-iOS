//
//  NewMessageController.swift
//  StudyNow1
//
//  Created by YUAN YAO on 1/28/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import Firebase
import UIKit

class NewMessageController: UITableViewController {
    let cellId = "cellId"

    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }

    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { snapshot in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.uid = snapshot.key
                // if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                self.users.append(user)

                //this will crash because of background thread, so lets use dispatch_async to fix
                // dont delete this yet
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    @objc func handleCancel() {
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 72
    }

    var messagesController: MessagesController?

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        let user = self.users[indexPath.row]
        self.messagesController?.showChatControllerForUser(roomID: user.uid!, roomType: .individual, title: user.name ?? "")
    }
}
