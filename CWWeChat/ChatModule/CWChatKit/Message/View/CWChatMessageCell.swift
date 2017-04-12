//
//  CWChatMessageCell.swift
//  CWWeChat
//
//  Created by chenwei on 2017/3/26.
//  Copyright © 2017年 chenwei. All rights reserved.
//

import UIKit

protocol CWChatMessageCellDelegate: NSObjectProtocol {
    
    /**
     头像点击的代理方法
     
     - parameter userId: 用户唯一id
     */
    func messageCellUserAvatarDidClick(_ userId: String)
    
}

class CWChatMessageCell: UITableViewCell {

    weak var delegate: CWChatMessageCellDelegate?

    var messageModel: CWChatMessageModel!
    
    // MARK: 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }

    func addGeneralView() {
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.usernameLabel)
        self.contentView.addSubview(self.messageContentView)
        self.contentView.addSubview(self.activityView)
        self.contentView.addSubview(self.errorButton)
    }
    
    /// 设置数据
    func configureCell(message messageModel: CWChatMessageModel) {
        
        // 设置数据
        
        
        // 更新UI
        

    }
    
    /// 
    func updateMessage(_ messageModel: CWChatMessageModel) {
        self.messageModel = messageModel
        // 消息实体
        let message = messageModel.message
        
        var userId: String
        // 是自己的
        if message.direction == .send {
            
            // 头像
            avatarImageView.snp.remakeConstraints({ (make) in
                make.width.height.equalTo(kAvaterImageViewWidth)
                make.right.equalTo(self.contentView).offset(-kAvaterImageViewMargin)
                make.top.equalTo(kMessageCellTopMargin)
            })
            
            usernameLabel.snp.remakeConstraints({ (make) in
                make.top.equalTo(avatarImageView.snp.top);
                make.right.equalTo(avatarImageView.snp.left).offset(-kMessageCellEdgeOffset)
                make.width.lessThanOrEqualTo(120)
                make.height.equalTo(0)
            })
            
            // 内容
            messageContentView.snp.remakeConstraints({ (make) in
                make.right.equalTo(avatarImageView.snp.left).offset(-kAvatarToMessageContent)
                make.top.equalTo(usernameLabel.snp.bottom)
                make.size.equalTo(messageModel.messageFrame.contentSize)
            })
            
            let image = #imageLiteral(resourceName: "bubble-default-sended")
            let cap = ChatCellUI.right_cap_insets
            backgroundImageView.image = image.resizableImage(withCapInsets: cap)
            
            userId = message.senderId ?? ""
    
        } else {
            
            avatarImageView.snp.remakeConstraints({ (make) in
                make.width.height.equalTo(kAvaterImageViewWidth)
                make.left.equalTo(kAvaterImageViewMargin)
                make.top.equalTo(kMessageCellTopMargin)
            })
            
            usernameLabel.snp.remakeConstraints({ (make) in
                make.top.equalTo(avatarImageView.snp.top);
                make.left.equalTo(avatarImageView.snp.right).offset(kMessageCellEdgeOffset)
                make.width.lessThanOrEqualTo(120)
                make.height.equalTo(0)
            })
            
            // 内容
            messageContentView.snp.remakeConstraints({ (make) in
                make.left.equalTo(avatarImageView.snp.right).offset(kAvatarToMessageContent)
                make.top.equalTo(usernameLabel.snp.bottom).offset(0)
                make.size.equalTo(messageModel.messageFrame.contentSize)
            })

            let image = #imageLiteral(resourceName: "bubble-default-received")
            let cap = ChatCellUI.left_cap_insets
            backgroundImageView.image = image.resizableImage(withCapInsets: cap)
            
            userId = message.targetId
        }
        
        let avatarURL = "\(kHeaderImageBaseURLString)\(userId).jpg"
        avatarImageView.yy_setImage(with: URL(string: avatarURL), placeholder: defaultHeadeImage)
    }
    
    
    //MARK: 更新状态
    /// 上传消息进度（图片和视频）
    
    //更新消息状态
    func updateChatMessageCellState() {
        
        // 发送中展示
        if messageModel.message.sendStatus == .sending {
            activityView.startAnimating()
            errorButton.isHidden = true
        }
        // 如果失败就显示重发按钮
        else if messageModel.message.sendStatus == .failed {
            activityView.stopAnimating()
            errorButton.isHidden = false
        } else {
            activityView.stopAnimating()
            errorButton.isHidden = true
        }
    }
    
    
    // MARK: cell中的事件处理
    ///头像点击
    func avatarViewDidTapDown(_ tap: UITapGestureRecognizer) {
    
        guard let delegate = self.delegate, let messageModel = self.messageModel, tap.state == .ended  else {
            return
        }

        let message = messageModel.message
        let targetId = (message.direction == .receive) ? message.targetId : (message.senderId ?? "")
        delegate.messageCellUserAvatarDidClick(targetId)
    }
    
    // MARK: 属性
    /// 用户名称
    var usernameLabel:UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.backgroundColor = UIColor.clear
        usernameLabel.font = UIFont.systemFont(ofSize: 12)
        usernameLabel.text = "nickname"
        return usernameLabel
    }()
    
    /// 头像
    lazy var avatarImageView:UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.backgroundColor = UIColor.gray
        avatarImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarViewDidTapDown(_:)))
        avatarImageView.addGestureRecognizer(tap)
        return avatarImageView
    }()
    
    /// 消息的内容部分
    lazy var messageContentView: UIView = {
        let messageContentView = UIView()
        messageContentView.clipsToBounds = true
        return messageContentView
    }()
    
    lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.clipsToBounds = true
        return backgroundImageView
    }()
    
    
    /// 指示
    var activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    /// 发送失败
    lazy var errorButton:UIButton = {
        let errorButton = UIButton(type: .custom)
        errorButton.setImage(UIImage(named:"message_sendfaild"), for: UIControlState())
        errorButton.sizeToFit()
        errorButton.isHidden = true
        return errorButton
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
