//
//  ChatLogController.swift
//  StudyNow1
//
//  Created by YUAN YAO on 1/30/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.

import Firebase
import UIKit

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    var temTitle: String! {
        didSet {
            navigationItem.title = temTitle
        }
    }

    // MARK: - FireBase API

    var messages = [Message]()
    var roomType: messageType?
    var roomID: String? {
        didSet {
            setTitle()
//            observeMessages()
        }
    }
    var messagesController: MessagesController?

    var containerViewBottomAnchor: NSLayoutConstraint?

    func setTitle() {
        guard let roomID = self.roomID, let type = self.roomType else {
            return
        }
        switch type {
        case .group:
            let roomRef = Database.database().reference().child("groups").child(roomID).child("Name")
            roomRef.observeSingleEvent(of: .value, with: { snapchat in
                guard let nameString = snapchat.value as? String else {
                    fatalError("This is not String")
                }
                self.navigationItem.title = nameString
            })
        case .publicg:
            let roomRef = Database.database().reference().child("groups").child(roomID).child("Name")
            roomRef.observeSingleEvent(of: .value, with: { snapchat in
                guard let nameString = snapchat.value as? String else {
                    fatalError("This is not String")
                }
                self.navigationItem.title = nameString
            })
        case .individual:
            let roomRef = Database.database().reference().child("users").child(roomID).child("name")
            roomRef.observeSingleEvent(of: .value, with: { snapchat in
                guard let nameString = snapchat.value as? String else {
                    fatalError("This is not String")
                }
                self.navigationItem.title = nameString
            })
        }
    }

    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let roomID = self.roomID, let type = self.roomType else {
            return
        }
        let roomRef: DatabaseReference
        let roomMessageRef: DatabaseReference

        switch type {
        case .group:
            roomRef = Database.database().reference().child("groups").child(roomID)
            roomMessageRef = roomRef.child("Messages")
        case .publicg:
            roomRef = Database.database().reference().child("groups").child(roomID)
            roomMessageRef = roomRef.child("Messages")
        case .individual:
            roomRef = Database.database().reference().child("user-messages").child(uid).child("Individual").child(roomID)
            roomMessageRef = roomRef
        }

        roomMessageRef.observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)

            messageRef.observeSingleEvent(of: .value, with: { snapshot in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary, type: type)
                self.messages.append(message)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
            })
        }
    }
    
    
    
    func removeMessageObserver() {
        guard let uid = Auth.auth().currentUser?.uid, let roomID = self.roomID, let type = self.roomType else {
            return
        }
        let roomRef: DatabaseReference
        let roomMessageRef: DatabaseReference
        
        switch type {
        case .group:
            roomRef = Database.database().reference().child("groups").child(roomID)
            roomMessageRef = roomRef.child("Messages")
        case .publicg:
            roomRef = Database.database().reference().child("groups").child(roomID)
            roomMessageRef = roomRef.child("Messages")
        case .individual:
            roomRef = Database.database().reference().child("user-messages").child(uid).child("Individual").child(roomID)
            roomMessageRef = roomRef
        }
        roomMessageRef.removeAllObservers()
    }

    // MARK: - Life Cycle

    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)

        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive

        view.addSubview(inputContainerView)
        containerViewBottomAnchor = inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        inputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Group Detail", style: .plain, target: self, action: #selector(handleGroupDetail))
        
    }
    
    @objc func handleGroupDetail() {
        switch roomType! {
        case .group:
            let groupDetailVC = PrivateGroupDetailTableViewController()
            groupDetailVC.roomID = roomID!
            groupDetailVC.messagesController = self.messagesController
            navigationController?.pushViewController(groupDetailVC, animated: true)
        case .publicg:
            let groupDetailVC = GroupDetailTableViewController()
            groupDetailVC.roomID = roomID!
            groupDetailVC.messagesController = self.messagesController
            navigationController?.pushViewController(groupDetailVC, animated: true)
        case .individual:
            let alert = UIAlertController(title: "No group detail", message: "It's a private conversation", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        
    }

    // MARK: - Collection View

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatLogController = self

        let message = messages[indexPath.item]
        cell.textView.text = message.text
        setupCell(cell, message: message)

        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            // Fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }

        return cell
    }

    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        let ref = Database.database().reference().child("users").child(message.fromId!)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(dictionary: dictionary)
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
        }

        if message.fromId == Auth.auth().currentUser?.uid {
            // outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true

            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false

        } else {
            // incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false

            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }

        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }

    override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80

        if indexPath.item >= self.messages.count {
            return CGSize(width: 0, height: 0)
        }
        
        let message = messages[indexPath.item]

        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1

            height = CGFloat(imageHeight / imageWidth * 200)
        }

        // let width = UIScreen.main.bounds.width
        return CGSize(width: view.frame.width, height: height)
    }

    // MARK: - Keyboard and inputContainer related

    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView()
        chatInputContainerView.chatLogController = self
        chatInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        return chatInputContainerView
    }()

    lazy var itemSelectionView: ChatItemSelectionView = {
        let chatItemSelectionView = ChatItemSelectionView()
        chatItemSelectionView.chatLogController = self
        chatItemSelectionView.translatesAutoresizingMaskIntoConstraints = false
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeGesture.direction = .down
        chatItemSelectionView.addGestureRecognizer(swipeGesture)
        return chatItemSelectionView
    }()

    var backgroundView: UIView?
    var moreSelectionViewEnabled = false
    var moreSelectionViewIsAnimating = false

    @objc func handleMoreSelection() {
        if moreSelectionViewIsAnimating {
            return
        }
        if !moreSelectionViewEnabled {
            moreSelectionViewIsAnimating = true
            if let keyWindow = UIApplication.shared.keyWindow {
                backgroundView = UIView(frame: keyWindow.frame)
                backgroundView?.backgroundColor = UIColor(red: 128 / 256, green: 128 / 256, blue: 128 / 256, alpha: 0.5)
                backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSwipeDown)))
                backgroundView?.alpha = 0
                view.addSubview(backgroundView!)
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundView?.alpha = 1
                })
            }

            view.addSubview(itemSelectionView)
            view.bringSubview(toFront: inputContainerView)

            itemSelectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            itemSelectionView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8).isActive = true
            itemSelectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            itemSelectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true

            inputContainerView.rotateMoreButtonOpen(open: true)

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
                self.itemSelectionView.frame.origin.y -= 100
            }, completion: { _ in
                self.moreSelectionViewEnabled = true
                self.moreSelectionViewIsAnimating = false
            })
        } else {
            handleSwipeDown()
        }
    }

    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func handleSwipeDown() {
        moreSelectionViewIsAnimating = true
        inputContainerView.rotateMoreButtonOpen(open: false)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
            self.backgroundView?.backgroundColor = UIColor.clear
            self.itemSelectionView.frame.origin.y += 100
        }) { _ in
            self.moreSelectionViewEnabled = false
            self.moreSelectionViewIsAnimating = false
            self.itemSelectionView.removeFromSuperview()
            self.backgroundView?.removeFromSuperview()
        }
    }

    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage)
        }

        dismiss(animated: true, completion: nil)
    }

    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)

        if let uploadData = UIImageJPEGRepresentation(image, 0.1) {
            ref.putData(uploadData, metadata: nil, completion: { metadata, error in

                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }

                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl, image: image)
                }

            })
        }
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupKeyboardObservers()
        observeMessages()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeMessageObserver()
        messages.removeAll()
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height

        DispatchQueue.main.async {
            if self.messages.count > 0 {
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }

        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }

    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // estimation of height
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    @objc func handleSend() {
        guard let messageText = inputContainerView.inputTextField.text else {
            fatalError("[ChatLog] Input should not be nil")
        }
        if messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            inputContainerView.inputTextField.text = ""
            inputContainerView.inputTextField.shake(2, withDelta: 4, speed: 0.07)
        } else {
            let properties = ["text": inputContainerView.inputTextField.text!]
            sendMessageWithProperties(properties as [String: AnyObject])
        }
    }

    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
    }

    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = roomID!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))

        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]

        // append properties dictionary onto values somehow??
        // key $0, value $1
        properties.forEach({ values[$0] = $1 })
        
        switch roomType! {
        case .group:
            Database.database().reference().child("user-messages").child(fromId).child("Group").updateChildValues([toId : 1])
        case .publicg:
            Database.database().reference().child("groups").child(fromId).child("Tag").observeSingleEvent(of: .value) { (snapshot) in
                if let groupTag = snapshot.value as? String {
                    Database.database().reference().child("user-messages").child(fromId).child("Public").updateChildValues([toId : groupTag])
                }
            }
        case .individual:
            Database.database().reference().child("user-messages").child(fromId).child("Individual").updateChildValues([toId : 1])
        }
        

        childRef.updateChildValues(values) { error, _ in
            if error != nil {
                print(error!)
                return
            }
            self.inputContainerView.inputTextField.text = nil
            let messageId = childRef.key

            switch self.roomType! {
            case .group:
                let roomRef = Database.database().reference().child("groups").child(toId).child("Messages")
                roomRef.updateChildValues([messageId: 1])
            case .publicg:
                let roomRef = Database.database().reference().child("groups").child(toId).child("Messages")
                roomRef.updateChildValues([messageId: 1])
            case .individual:
                let roomRef = Database.database().reference().child("user-messages").child(fromId).child("Individual").child(toId)
                roomRef.updateChildValues([messageId: 1])
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child("Individual").child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
            }
        }
    }

    // MARK: - Sending and zooming image related

    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?

    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)

        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))

        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)

            keyWindow.addSubview(zoomingImageView)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0

                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width

                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)

                zoomingImageView.center = keyWindow.center

            }, completion: { _ in
                //                    do nothing
            })
        }
    }

    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            // need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1

            }, completion: { _ in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }

    @objc func handleDocumentSelection() {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.composite-content"], in: UIDocumentPickerMode.import)
        // documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        documentPickerController.delegate = self
        present(documentPickerController, animated: true, completion: nil)
    }

    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // if controller.documentPickerMode == UIDocumentPickerMode.exportToService {
        print(urls[0])
        let url = Bundle.main.url(forResource: "http://www.orimi.com/pdf-test", withExtension: "pdf")
        if let url = url {
            let webView = UIWebView(frame: view.frame)
            let urlRequest = URLRequest(url: url)
            webView.loadRequest(urlRequest)

            view.addSubview(webView)
        }
        // do some stuff
        //  }
    }
}
