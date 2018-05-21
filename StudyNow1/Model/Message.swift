//
//  Message.swift
//  StudyNow1
//
//  Created by YUAN YAO on 1/31/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import Firebase
import UIKit

enum messageType {
    case group
    case individual
    case publicg
}

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var type: messageType

    init(dictionary: [String: Any], type: messageType) {
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        toId = dictionary["toId"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String

        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber

        self.type = type
    }

    func chatPartnerId() -> String? {
        if type == .group || type == .publicg {
            return toId
        } else {
            if fromId == Auth.auth().currentUser?.uid {
                return toId
            } else {
                return fromId
            }
        }
    }
}
