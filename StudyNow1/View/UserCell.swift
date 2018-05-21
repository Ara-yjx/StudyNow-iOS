//
//  UserCell.swift
//  StudyNow1
//
//  Created by YUAN YAO on 1/31/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import Firebase
import UIKit

class UserCell: UITableViewCell {
    var message: Message? {
        didSet {
            setupNameAndProfileImage()

            if let messageText = message?.text {
                detailTextLabel?.text = messageText
            } else if let imageURL = message?.imageUrl {
                detailTextLabel?.text = "[Picture]"
            }

            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)

                let dateFormatter = DateFormatter()
//                dateFormatter.dateStyle = .short
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }

    private func setupNameAndProfileImage() {
        if let id = message?.chatPartnerId() {
            switch message!.type {
            case .group:
                let ref = Database.database().reference().child("groups").child(id)
                ref.child("Name").observeSingleEvent(of: .value, with: { snapshot in
                    guard let name = snapshot.value as? String else {
                        fatalError("This is not a string")
                    }
                    self.textLabel?.text = name
                    self.groupImageView.loadImages(groupID: id)
                    self.groupImageView.alpha = 1
                    self.profileImageView.alpha = 0
                })
                ref.child("Tag").observeSingleEvent(of: .value) { (snapshot) in
                    guard let tag = snapshot.value as? String else{
                        return
                    }
                    if tag.components(separatedBy: " - ").count > 1 {
                        self.tagLabel.text = tag.components(separatedBy: " - ")[0]
                    } else {
                        self.tagLabel.text = tag
                    }
                }
            case .publicg:
                let ref = Database.database().reference().child("groups").child(id)
                ref.child("Name").observeSingleEvent(of: .value, with: { snapshot in
                    guard let name = snapshot.value as? String else {
                        fatalError("This is not a string")
                    }
                    self.textLabel?.text = name
                    self.groupImageView.loadImages(groupID: id)
                    self.groupImageView.alpha = 1
                    self.profileImageView.alpha = 0
                })
//                ref.child("Tag").observeSingleEvent(of: .value) { (snapshot) in
//                    guard let tag = snapshot.value as? String else{
//                        return
//                    }
//                    self.tagLabel.text = tag
//                }
            case .individual:
                let ref = Database.database().reference().child("users").child(id)
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.textLabel?.text = dictionary["name"] as? String
                        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                            self.groupImageView.alpha = 0
                            self.profileImageView.alpha = 1
                        }
                        
                    }
                })
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel?.font = UIFont.boldSystemFont(ofSize: textLabel!.font.pointSize)
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 1, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: textLabel!.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
        tagLabel.leftAnchor.constraint(equalTo: textLabel!.rightAnchor, constant: 4).isActive = true
        tagLabel.centerYAnchor.constraint(equalTo: textLabel!.centerYAnchor).isActive = true
        tagLabel.widthAnchor.constraint(equalTo: tagLabel.widthAnchor).isActive = true
        tagLabel.heightAnchor.constraint(equalTo: tagLabel.heightAnchor).isActive = true

        if let tLength = detailTextLabel?.text?.count, tLength > 0 {
            detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
            detailTextLabel?.leftAnchor.constraint(equalTo: textLabel!.leftAnchor).isActive = true
            detailTextLabel?.topAnchor.constraint(equalTo: textLabel!.bottomAnchor, constant: 6).isActive = true
            detailTextLabel?.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        }
    }

    let tagLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.font = UIFont.systemFont(ofSize: 16)
        tagLabel.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        return tagLabel
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let groupImageView: GroupChatAvatarView = {
        let imageView = GroupChatAvatarView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        tagLabel.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
    }

    override init(style _: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(groupImageView)
        addSubview(tagLabel)

        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        groupImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        groupImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        groupImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        groupImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
