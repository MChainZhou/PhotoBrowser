//
//  UIViewExtension.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
extension UIView {
    func startkeyFramesAnimation() {
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/4.0, animations: {
                self.transform = self.transform.scaledBy(x: 1.3, y: 1.3);
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/4, relativeDuration: 2/4.0, animations: {
                self.transform = self.transform.scaledBy(x: 0.7, y: 0.7);
            })
            UIView.addKeyframe(withRelativeStartTime: 3/4, relativeDuration: 1/4.0, animations: {
                self.transform = CGAffineTransform.identity
            })
        }, completion: nil)
    }
}
