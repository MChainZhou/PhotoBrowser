//
//  JLImageListView.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/4/26.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

fileprivate let kStatusImageMargin:CGFloat = 5.0

class JLImageListView: UIView {
    
    
    
    //MARK:懒加载
    fileprivate lazy var imageViews = [UIImageView]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension JLImageListView {
    fileprivate func setupUI(){
        for i in 0..<9 {
    
            let imageView = UIImageView()
            imageView.image = UIImage(named: "\(i+1)" + ".jpg")
            
            imageView.tag = i;
            
            imageView.isUserInteractionEnabled = true;
            imageView.clipsToBounds = true;
            imageView.contentMode = .scaleAspectFill;
            
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageTap(_:)))
            imageView.addGestureRecognizer(tap)
            
            //列数
            let column = i%3;
            //行数
            let row = i/3;
            //图片的宽高
            let iamgeViewWH = (self.bounds.width - 2 * kStatusImageMargin)/3
            // x轴的坐标
            let imageViewX = CGFloat(column) * (iamgeViewWH + kStatusImageMargin)
            // y轴的坐标
            let imageViewY = CGFloat(row) * (iamgeViewWH + kStatusImageMargin)
            
            
            imageView.frame = CGRect(x: imageViewX , y: imageViewY, width: iamgeViewWH, height: iamgeViewWH);
            self.imageViews.append(imageView);
            self.addSubview(imageView);
        }
    }
    
    @objc fileprivate func imageTap(_ tap:UITapGestureRecognizer) {
      
        let browser = JLPhotoBrowserView()
        browser.photos = self.imageViews;
        let path = Bundle.main.path(forResource: "Picture.plist", ofType: nil)
        let imageURLs = NSArray.init(contentsOfFile: path!)
        
        browser.imageURLs = imageURLs! as! [String]
        browser.currentIndex = (tap.view?.tag)!;
        browser.show();
    }
}
