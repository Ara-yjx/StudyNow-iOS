//
//  AppDelegate.swift
//  StudyNow1
//
//  Created by 刘恒宇 on 2018/1/24.
//  Copyright © 2018年 GoStudyNow. All rights reserved.
//

import CoreData
import Firebase
import UIKit
import UserNotifications

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true

        // Set initial View Controller
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: MessagesController())

        // Configure Firebase Cloud Message
        postToken()
        return true
    }

    func registerRemoteNotification(_ application: UIApplication) {
        // Configure Firebase Cloud Message
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        let notificationOptions: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current().requestAuthorization(options: notificationOptions) { _, err in
            debugPrint(err ?? "")
        }
        application.registerForRemoteNotifications()
    }

    func messaging(_: Messaging, didReceiveRegistrationToken _: String) {
        postToken()
    }

    func postToken() {
        if let userID = Auth.auth().currentUser?.uid, let token = Messaging.messaging().fcmToken {
            Database.database().reference().child("users").child(userID).child("token").setValue(token)
        } else {
            debugPrint("[FCM] Cannot post token")
        }
    }
}
