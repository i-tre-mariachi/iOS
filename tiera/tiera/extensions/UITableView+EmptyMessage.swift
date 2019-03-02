//
//  UITableView+EmptyMessage.swift
//  tiera
//
//  Created by Christos Christodoulou on 02/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import UIKit

public extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 24)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
        self.backgroundColor = UIColor(hexString: "#638791")
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
