//
//  JLBadgeView.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class JLBadgeView: UIView {

    
    @IBOutlet weak var badgeLabel: UILabel!
    
    var badgeCount = 0 {
        didSet{
            self.badgeLabel.text = "\(self.badgeCount)"
            self.isHidden = self.badgeCount == 0;
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.isHidden = true
    }
    

}

//MARK:外部公开的方法
extension JLBadgeView {
    //通过xib加载view
    class func badgeView() -> JLBadgeView {
        let badgeView = Bundle.main.loadNibNamed("JLBadgeView", owner: nil, options: nil)?.last
        return badgeView as! JLBadgeView;
    }
    
    func setBadge(_ badge:Int,_ animation:Bool) {
        self.badgeCount = badge;
        if animation {
            self.startkeyFramesAnimation()
        }
    }
}
