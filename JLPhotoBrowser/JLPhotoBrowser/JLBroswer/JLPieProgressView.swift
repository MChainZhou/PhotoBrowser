//
//  JLPieProgressView.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

let kInnerCircleRadius = 10.0


class JLPieProgressView: UIView {

    /// 进度值
    var progressValue:Float = 0.0{
        didSet {
            if self.progressValue == 1.0 {
                self.isHidden = true
            }else{

               setNeedsDisplay()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: 绘制进度条
extension JLPieProgressView {
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        //画外圆
        UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8).set()
        
        ctx?.addArc(center: CGPoint(x: rect.width/2, y: rect.height/2), radius: CGFloat(kInnerCircleRadius * 2 + 2.0), startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false)
        ctx!.strokePath();
        
        //画内圆
        ctx?.setLineWidth(CGFloat(kInnerCircleRadius*2))
        ctx?.addArc(center: CGPoint(x: rect.width/2, y: rect.height/2), radius: CGFloat(kInnerCircleRadius), startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(-Double.pi/2)+CGFloat(Double.pi * 2.0)*CGFloat(self.progressValue), clockwise: false)
        ctx!.strokePath();
    }
}
