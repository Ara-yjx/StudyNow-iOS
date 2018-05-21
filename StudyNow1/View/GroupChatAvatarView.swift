//
//  GroupChatAvatarView.swift
//  StudyNow1
//
//  Created by 刘恒宇 on 2018/3/2.
//  Copyright © 2018年 GoStudyNow. All rights reserved.
//

import Firebase
import UIKit

class GroupChatAvatarView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadImages(groupID: String) {
        var userImages = [UIImageView]()
        Database.database().reference().child("groups").child(groupID).child("Members").observeSingleEvent(of: .value) { snapchat in
            guard let dictionary = snapchat.value as? [String: AnyObject] else {
                return
            }
            for (userID, _) in dictionary {
                Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                            let temImageView = UIImageView()
                            temImageView.translatesAutoresizingMaskIntoConstraints = false
                            temImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                            userImages.append(temImageView)
                            self.updateImage(userImages: userImages)
                        }
                    }
                })
                if userImages.count >= 4 {
                    break
                }
            }
        }
    }

    func updateImage(userImages: [UIImageView]) {
        for (index, imageView) in userImages.enumerated() {
            switch index {
            case 0:
                addSubview(imageView)
                imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            case 1:
                addSubview(imageView)
                imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
                imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            case 2:
                addSubview(imageView)
                imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            case 3:
                addSubview(imageView)
                imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            default:
                break
            }
        }
    }
}
