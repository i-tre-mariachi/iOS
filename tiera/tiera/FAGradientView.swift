//
//  FAGradientView.swift
//  tiera
//
//  Created by Christos Christodoulou on 02/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import UIKit

class FAGradientView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func draw(_ rect: CGRect) {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        let startColor: UIColor = UIColor(red: 97.0/255.0, green: 130.0/255.0, blue: 122.0/255.0, alpha: 1.0)
        let endColor: UIColor = UIColor(red: 66.0/255.0, green: 82.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        
        let colors = [startColor.cgColor, endColor.cgColor]
        let locations: [CGFloat] = [0, 1]
        let gradient: CGGradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!
        
        let startPoint: CGPoint = CGPoint(x:rect.midX, y: rect.minY)
        let endPoint: CGPoint = CGPoint(x: rect.midX, y: rect.maxY)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
    }

}
