//
//  JLPhotoBrowserView.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/4/26.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit


let keyWindow = UIApplication.shared.keyWindow

class JLPhotoBrowserView: UIView {

    //MARK: 属性
    var photos = [UIImageView]()
    var imageURLs = [String]()
    var currentIndex = 0
    
    
    fileprivate var originRects = [CGRect]()
    //MARK: 懒加载
    fileprivate lazy var bigScrollView:UIScrollView = { [weak self] in
        let scrollView = UIScrollView();
        scrollView.backgroundColor = UIColor.clear;
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.frame = (self?.bounds)!;
        scrollView.delegate = self;
        scrollView.isPagingEnabled = true;
        scrollView.bounces = true;
        return scrollView;
    }()
    fileprivate lazy var bgView:UIView = {
        let bgView = UIView();
        bgView.backgroundColor = UIColor.black;
        bgView.frame = self.bounds
        
        return bgView;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: 初始化方法
extension JLPhotoBrowserView {
    fileprivate func setupUI(){
        
        self.frame = (keyWindow?.bounds)!
        
        addSubview(self.bgView);
        
        addSubview(self.bigScrollView);
    }
}

//MARK: UIScrollViewDelegate
extension JLPhotoBrowserView:UIScrollViewDelegate {
    
}
//MARK: 私有方法
extension JLPhotoBrowserView {
 
    fileprivate func setupOriginRect(){
        for imageView in self.photos {
            let rect = keyWindow?.convert(imageView.frame, from: imageView.superview);
            self.originRects.append(rect!);
        }
    }
    
    fileprivate func setupSmallScrollView(){
        for imageView in self.photos {
            let i = self.photos.index(of: imageView);
            //创建里面的滚动视图
            let scrollView = creatSmallScrollView(i!);
            
            //创建里面的imageView
            let imageView = creatImageView(i!);
            scrollView.addSubview(imageView);
            
            //创建加载试图
            let loopView = creatLoopView()
            scrollView.addSubview(loopView)
            
            
            imageView.kf.setImage(with: ImageResource.init(downloadURL: URL(string: self.imageURLs[i!])!), placeholder: nil, options: nil, progressBlock: { (size, total) in
                let floatSize = Float(size)
                let floatTotal = Float(total)
                let value = floatSize / floatTotal
                loopView.progressValue = value
            }) { (image, error, cache, url) in
                //下载下来的图片
                if cache == CacheType.none {
                    self.setupImageViewFrame(i!, imageView: imageView)
                }else {
                    loopView.isHidden = true
                    imageView.frame = self.originRects[i!]
                    UIView.animate(withDuration: 0.3, animations: {
                        self.setupImageViewFrame(i!, imageView: imageView)
                    })
                }
            }
            
            
        }
    }
    
    fileprivate func creatLoopView() -> JLPieProgressView {
        let loopView = JLPieProgressView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        loopView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        loopView.autoresizingMask = [.flexibleBottomMargin,.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin]
        return loopView;
    }
    
    fileprivate func creatImageView(_ index:Int) -> UIImageView {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true;
        imageView.tag = index;

        

        let oneTap = UITapGestureRecognizer(target: self, action: #selector(self.photoTap(_:)))
        let zonTap = UITapGestureRecognizer(target: self, action: #selector(self.zonTap(_:)));
        zonTap.numberOfTapsRequired = 2;
        
        imageView.addGestureRecognizer(zonTap);
        imageView.addGestureRecognizer(oneTap);
        
        oneTap.require(toFail: zonTap);
        return imageView;
    }
    
    @objc fileprivate func zonTap(_ tap:UITapGestureRecognizer) {
        let scrollView:UIScrollView = tap.view?.superview as! UIScrollView
        
        UIView.animate(withDuration: 0.3) {
            scrollView.zoomScale = 3.0
        };
    }
    
    @objc fileprivate func photoTap(_ tap:UITapGestureRecognizer){
        
        //1.将图片缩小回一倍
        let scrollView:UIScrollView = tap.view?.superview as! UIScrollView
        scrollView.zoomScale = 1.0;
        
        
        //如果是长图，就将图片移至CGPoint(0，0)
        if (tap.view?.bounds.height)! > bounds.height {
            scrollView.contentOffset = CGPoint(x: 0, y: 0);
        }
        
        //取出原始的尺寸
        let originRact = self.originRects[(tap.view?.tag)!];
        
        UIView.animate(withDuration: 0.3, animations: {
            tap.view?.frame = originRact
            self.bgView.alpha = 0.0;
        }) { (true) in
            self.removeFromSuperview();
        };
        
    }
    
    fileprivate func setupImageViewFrame(_ index:Int,imageView:UIImageView){

        let scrollView:UIScrollView = imageView.superview as! UIScrollView
        imageView.frame = self.originRects[index];
        
        let ratio:CGFloat = (imageView.image?.size.height)! / (imageView.image?.size.width)!
        
        let imageViewH:CGFloat = ratio * bounds.width;
        
        let imageViewW:CGFloat = (keyWindow?.bounds.width)!
        let keyWH:CGFloat = (keyWindow?.bounds.height)!

        
        UIView.animate(withDuration: 0.3) {
            if (imageViewH < keyWH) {
                imageView.frame = CGRect(x: 0, y: 0, width: imageViewW, height: imageViewH)
                imageView.center = CGPoint(x: imageViewW/2, y: keyWH/2)
            }else{
                imageView.frame = CGRect(x: 0, y: 0, width: imageViewW, height: imageViewH)
                scrollView.contentSize = CGSize(width: imageViewW, height: imageViewH);
            }
        };
    }
    
    fileprivate func creatSmallScrollView(_ index:Int) -> UIScrollView {
        let scrollView = UIScrollView();
        scrollView.backgroundColor = UIColor.clear;
        scrollView.tag = index;
        scrollView.frame = CGRect(x: CGFloat(index) * bounds.width, y: 0, width: bounds.width, height: bounds.height)
        scrollView.delegate = self;
        
        scrollView.maximumZoomScale = 3.0;
        scrollView.minimumZoomScale = 1.0;

        self.bigScrollView.addSubview(scrollView);
        return scrollView;
    }
}

//MARK: 公开的方法
extension JLPhotoBrowserView {
    func show() {
        //1. 添加view
        keyWindow?.addSubview(self);
        //2. 获取原始的frame
        setupOriginRect();
        //3. 设置滚动距离
        self.bigScrollView.contentSize = CGSize(width: CGFloat(self.photos.count) * (keyWindow?.bounds.width)!, height: 0);
        self.bigScrollView.contentOffset = CGPoint(x: CGFloat(self.currentIndex) * (keyWindow?.bounds.width)!, y: 0);
        //4. 创建子试图
        setupSmallScrollView();
    }
}
