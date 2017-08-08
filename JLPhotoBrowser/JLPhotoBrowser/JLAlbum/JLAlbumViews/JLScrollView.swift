//
//  JLScrollView.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class JLScrollView: UIScrollView {

    var image:UIImage?{
        didSet{
            self.imageView?.image = image
            
            let radio = (image?.size.height)!/(image?.size.width)!
            let imageViewH = radio * UIScreen.main.bounds.width
            
            if imageViewH < UIScreen.main.bounds.height {
                self.imageView?.frame.size = CGSize(width: UIScreen.main.bounds.width, height: imageViewH)
                self.imageView?.center = CGPoint(x: self.frame.width/2, y:self.frame.height/2)
            }else{
                self.imageView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: imageViewH)
            }
            
            self.contentSize = CGSize(width: UIScreen.main.bounds.width, height: imageViewH)
            
        }
    }
    fileprivate var imageView:UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.maximumZoomScale = 3.0
        self.minimumZoomScale = 1.0
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(zonmTap(_:)))
        tap.numberOfTapsRequired = 2;
        imageView.addGestureRecognizer(tap)
        
        self.imageView = imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        //销毁事把image置为nil的目的是为了防止内存飙升
        self.imageView?.image = nil
    }
}

extension JLScrollView {
    func getZoomView() -> UIView {
        return self.imageView!
    }
    
    @objc fileprivate func zonmTap(_ tap:UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) { 
            if self.zoomScale == 1.0 {
                self.zoomScale = 3.0
            }else{
                self.zoomScale = 1.0
            }
        }
    }
}

class JLScrollViewDelegate: NSObject,UIScrollViewDelegate{
    //获取要放大的子视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        let zoomScrollView = scrollView as! JLScrollView
        
        return zoomScrollView.getZoomView()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let jlScrollView = scrollView as! JLScrollView;
        
        let imageView = jlScrollView.getZoomView() as! UIImageView;
        let imageViewY = (scrollView.frame.height - imageView.frame.height)/2
        
        imageView.frame.origin.y = imageViewY > 0 ? imageViewY : 0;
        
    }
    
}
