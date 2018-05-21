//
//  ClassPickerController.swift
//  StudyNow1
//
//  Created by YUAN YAO on 2/21/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import Firebase
import UIKit
import SwiftyJSON

class ClassPickerController: UITableViewController {
    var user: User?
    var selectedClassList = [String]()
    var indexTitles = [String]()
    var classList = [(String,[String])]()

    
    func makeDataSource(names:[String:[String]]) {
        //Temporary array to hold restaurants on different indexes
        var dict = [String:[String]]()
        
        //Character set taken to check whether the starting key is alphabet or any other character
        let letters = NSCharacterSet.letters
        
        for (_,value) in names {
            //Iterating Restaurants
            for resObj in value {
                var key = String(describing: resObj.first!)
                
                if let keyValue = dict[key] {
                    //Already value exists for that key
                    var filtered = keyValue
                    filtered.append(resObj)
                    
                    //Sorting of restaurant names alphabetically
//                    filtered = filtered.sorted(by: {$0.0.name < $0.1.name})
                    filtered = filtered.sorted(by: {$0 < $1})
                    dict[key] = filtered
                } else {
                    let filtered = [resObj]
                    dict[key] = filtered
                }
            }
        }
        //To sort the key header values
        classList = Array(dict).sorted(by: { $0.0 < $1.0 })
        
        //For setting index titles
        self.indexTitles = Array(dict.keys.sorted(by: <))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionIndexColor = .white
     
        let fileURL = Bundle.main.url(forResource: "ClassList", withExtension: "json")
        let fileData: Data = try! Data.init(contentsOf: fileURL!)
        let jsonValue = try! JSON(data: fileData)
        
        var temArr: [String: [String]] = [:]
        
        for temJSON in jsonValue {
            let temSubject = temJSON.0
            var temClasses = [String]()
            for temSubJSON in temJSON.1.arrayValue {
                temClasses.append(temSubJSON.stringValue)
            }
            temArr[temSubject] = temClasses
        }
        makeDataSource(names: temArr)
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        navigationController?.navigationBar.tintColor = UIColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleComplete))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "classes")
        tableView.separatorColor = UIColor.clear
        
        reloadForSelected()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList[section].1.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return classList.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return classList[section].0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classes", for: indexPath) as UITableViewCell
        let className = classList[indexPath.section].1[indexPath.row]
        cell.textLabel?.text = className
        cell.tintColor = .white
        if selectedClassList.contains(className) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if let ind = selectedClassList.index(where: {return $0 == cell.textLabel!.text}) {
            let alertVC = UIAlertController(title: "Warning", message: "Are you going to drop from this course?", preferredStyle: .alert)
            let dropAction = UIAlertAction(title: "Drop", style: .destructive) { (_) in
                self.handleDrop(from: ind, tableIndex: indexPath)
            }
            alertVC.addAction(dropAction)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        } else {
            let alertVC = UIAlertController(title: "Add this course?", message: "Are you going to join this course's channel?", preferredStyle: .alert)
            let addAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                self.handleAdd(tableIndex: indexPath)
            }
            alertVC.addAction(addAction)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
        cell.isSelected = false
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.indexTitles
    }
    
    func handleAdd(tableIndex: IndexPath) {
        let courseCell = tableView.cellForRow(at: tableIndex)
        courseCell?.accessoryType = .checkmark
        let courseName = courseCell!.textLabel!.text!
        selectedClassList.append(courseName)
        let ref = Database.database().reference().child("classes").child(courseName).child("Public")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let groupID = snapshot.value as? [String: AnyObject] {
                self.joinPublicChannel(roomID: groupID.first!.key, tag: courseName)
                self.sendJoinMessage(roomID: groupID.first!.key)
            } else {
                let key = self.addPublicChannel(tag: courseName)
                ref.updateChildValues([key: 1])
                self.sendJoinMessage(roomID: key)
            }
        })
    }
    
    func handleDrop(from courseIndex: Int, tableIndex: IndexPath) {
        let courseCell = tableView.cellForRow(at: tableIndex)
        courseCell?.accessoryType = .none
        selectedClassList.remove(at: courseIndex)
        let courseName = courseCell!.textLabel!.text!
        let ref = Database.database().reference().child("user-messages").child(Auth.auth().currentUser!.uid).child("Public")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dic = snapshot.value as? [String: String] {
                for (roomID, temCourseName) in dic {
                    if temCourseName == courseName {
                        Database.database().reference().child("groups").child(roomID).child("Members").child(Auth.auth().currentUser!.uid).removeValue()
                        
                        ref.child(roomID).removeValue()
                    }
                }
            }
        }
    }
    
    func reloadForSelected() {
        let ref = Database.database().reference().child("user-messages").child(Auth.auth().currentUser!.uid).child("Public")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let groupID = snapshot.value as? [String: AnyObject] {
                self.selectedClassList = []
                for g in groupID {
                    self.selectedClassList.append(g.value as! String)
                }
                self.tableView.reloadData()
            }
        })
    }

    @objc func handleComplete() {
        dismiss(animated: true, completion: nil)
    }
    
    func joinPublicChannel(roomID: String, tag: String) {
        Database.database().reference().child("groups").child(roomID).child("Members").updateChildValues([Auth.auth().currentUser!.uid: 1])
        Database.database().reference().child("user-messages").child(Auth.auth().currentUser!.uid).child("Public").updateChildValues([roomID: tag])
    }
    
    func addPublicChannel(tag: String) -> String {
        
        guard let myUser = user else {
            fatalError("喵喵喵???")
        }
        let groupRootRef = Database.database().reference().child("groups")
        let roomRef = groupRootRef.childByAutoId()
        let roomID = roomRef.key

        // Update group part
        let groupName = tag
        roomRef.updateChildValues(["Name": groupName])
        roomRef.updateChildValues(["Tag": tag])
        roomRef.child("Members").updateChildValues([myUser.uid!: 1])
        
        // Update user-message part
        let userMessageRef = Database.database().reference().child("user-messages").child(myUser.uid!).child("Public")
        userMessageRef.updateChildValues([roomID: tag])
        
        return roomID
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
                    let values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "text": (username + " has joined this group") as AnyObject]
                    
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
                    let values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "text": "A new student has joined this group" as AnyObject]
                    
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
}

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[index(startIndex, offsetBy: i)];
        }
    }
}
