//
//  User.swift
//  StudyNow1
//
//  Created by YUAN YAO on 1/28/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import UIKit

class User: NSObject {
    var uid: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?

    init(dictionary: [String: AnyObject]) {
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
        profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
