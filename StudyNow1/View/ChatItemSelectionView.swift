//
//  ChatItemSelectionView.swift
//  StudyNow1
//
//  Created by YUAN YAO on 2/27/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import UIKit

class ChatItemSelectionView: UIView {
    var chatLogController: ChatLogController? {
        didSet {
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
            uploadDocumentView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleDocumentSelection)))
        }
    }

    let uploadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "uploadImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let uploadDocumentView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "uploadFile")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        layer.cornerRadius = 8
        layer.masksToBounds = true
        addSubview(uploadImageView)
       // addSubview(uploadDocumentView)
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

//        uploadDocumentView.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 12).isActive = true
//        uploadDocumentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        uploadDocumentView.widthAnchor.constraint(equalToConstant: 32).isActive = true
//        uploadDocumentView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
