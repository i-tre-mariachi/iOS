//
//  FARoundedButton.swift
//  tiera
//
//  Created by Christos Christodoulou on 02/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import UIKit

class FARoundedButton: UIButton {
    
    @IBInspectable var cornerRadiusButton : CGFloat  = 3.0 {
        didSet {
            self.layer.cornerRadius = cornerRadiusButton
        }
    }
    
    override func awakeFromNib() {
        self.setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = cornerRadiusButton
    }
    
}
