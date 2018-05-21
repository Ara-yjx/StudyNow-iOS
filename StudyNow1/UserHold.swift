//
//  User.swift
//  StudyNow1
//
//  Created by YUAN YAO on 1/25/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import Foundation

class UserHold {
    var name: String
    var uid: String
    var email: String

    init(name: String, uid: String, email: String) {
        self.name = name
        self.uid = uid
        self.email = email
    }

    func formatUserToRegister() -> [String: String] {
        return ["name": self.name, "uid": self.uid, "email": self.email]
    }
}
