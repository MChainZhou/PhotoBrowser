//
//  JLAlbumBrowserViewController.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import AssetsLibrary

let navigetionH:CGFloat = 64
let toolBarH:CGFloat = 44

enum JLScrollViewType {
    case left
    case mid
    case right
}

enum JLPhotoType {
    case AspectRatioThumbnail //按照比例缩放
    case FullResolutionImage //原始图
    case FullScreenImage //全屏图
}

enum JLDirection {
    case none  //在原地不动
    case left  //往右滑动
    case right //往左滑动
}


class JLAlbumBrowserViewController: UIViewController {
    
    //选中的数组
    var seleAssets = [ALAsset]()
    //所有的图片数据
    var assets = [ALAsset]()
    //当前属于哪张图片
    var currentIndex:Int = 0
    //选择按钮
    var selectedBtn:UIButton?
    //三个小的scrollView
    var scrollViews = [JLScrollView]()
    
    
    //
    var delegate:JLSelectedPhotoProtocol?
    
    
    //MARK:懒加载
    ///完成按钮
    fileprivate lazy var completeItem:UIBarButtonItem = {
        let completeItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(clickCompleteItem))
        completeItem.isEnabled = false
        completeItem.tintColor = UIColor(red: 253/255.0, green: 130/255.0, blue: 36/255.0, alpha: 1.0)
        completeItem.isEnabled = false
        return completeItem
    }()
    //徽章视图
    fileprivate lazy var badgeView:JLBadgeView = {
        let badgeView = JLBadgeView.badgeView()
        
        return badgeView;
    }()
    
    //大的scrollView
    fileprivate lazy var bigScrollView:UIScrollView = { [weak self] in
        let bigScrollView = UIScrollView()
        bigScrollView.showsVerticalScrollIndicator = false;
        bigScrollView.showsHorizontalScrollIndicator = false
        bigScrollView.frame = CGRect(x: 0, y: navigetionH, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-toolBarH-navigetionH)
        bigScrollView.isPagingEnabled = true
        bigScrollView.contentSize = CGSize(width:CGFloat((self?.assets.count)!) * UIScreen.main.bounds.width, height: CGFloat(0))
        bigScrollView.backgroundColor = UIColor.white
        bigScrollView.contentOffset = CGPoint(x: CGFloat((self?.currentIndex)!) * UIScreen.main.bounds.width, y: CGFloat(0))
        bigScrollView.delegate = self
        return bigScrollView
    }()
    
    fileprivate lazy var scrollViewDelegate:JLScrollViewDelegate = {
        let scrollViewDelegate = JLScrollViewDelegate()
        
        return scrollViewDelegate;
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupBasic()
        
        self.setupNav()
        
        self.setupTool()
        
        self.setupUI()
        
        //大的滚动视图里面的小的滚动视图
        self.creatScrollViews()
        
        self.setupScrollViews()
    
    }

}

//MARK:设置UI
extension JLAlbumBrowserViewController {
    fileprivate func setupBasic() {
        self.view.backgroundColor = UIColor.white
        
        self.navigationController?.navigationBar.tintColor = tintColor
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    fileprivate func setupNav() {
        
        let btn = UIButton(type: .custom)
        
        btn.setImage(UIImage(named: "compose_guide_check_box_default"), for: .normal)
        
        btn.setImage(UIImage(named: "compose_guide_check_box_right"), for: .selected)
        btn.addTarget(self, action: #selector(clickSelectedBtn(_:)), for: .touchUpInside)
        btn.sizeToFit()
        self.selectedBtn = btn
        let rightItem = UIBarButtonItem(customView: btn)
        
        self.navigationItem.rightBarButtonItem = rightItem;
        
    }
    
    fileprivate func setupTool(){
        self.navigationController?.isToolbarHidden = false;
    
        let tooFlexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        let toofixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
        
        let badgeItem = UIBarButtonItem(customView: self.badgeView)
        self.toolbarItems = [tooFlexibleItem,badgeItem,toofixedItem,self.completeItem]
        self.refreshBadge(false)
    }
    
    fileprivate func setupUI() {
        self.view.addSubview(self.bigScrollView);
    
    }
    
    fileprivate func creatScrollViews() {
        for _ in 0 ..< 3 {
            let scrollView = JLScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navigetionH - toolBarH))
            scrollView.delegate = self.scrollViewDelegate;
            self.scrollViews.append(scrollView)
        }
    }
    
    fileprivate func setupScrollViews() {
        self.title = "\(self.currentIndex+1)/\(self.assets.count)"
        let asset = self.assets[self.currentIndex]
        self.selectedBtn?.isSelected = self.seleAssets.contains(asset)
        
        //设置当前选中的图片
        self.setupScrollView(self.currentIndex, type: .mid)
        
        //设置右边的图片
        if self.currentIndex+2 <= self.assets.count {
            self.setupScrollView(self.currentIndex+1, type: .right)
        }
        //左边的图片
        if self.currentIndex > 0 {
            self.setupScrollView(self.currentIndex-1, type: .left)
        }
        
    }
    
    fileprivate func setupScrollView(_ index:Int,type:JLScrollViewType){
        let asset = self.assets[index]
        var scrollViewIndex = 0
        switch type {
            case .left:
                scrollViewIndex = 0
            case .mid:
                scrollViewIndex = 1
            case .right:
                scrollViewIndex = 2
        }
        
        let scrollView = self.scrollViews[scrollViewIndex]
        
        async_setupImageforScrollView(scrollView, asset, photoType: .AspectRatioThumbnail)
        
        if type == .mid {
            async_setupImageforScrollView(scrollView, asset, photoType: .FullScreenImage)
        }
        scrollView.frame.origin.x = UIScreen.main.bounds.width * CGFloat(index)
        self.bigScrollView.addSubview(scrollView)
    }
    
    fileprivate func async_setupImageforScrollView(_ scrollView:JLScrollView,_ asset:ALAsset,photoType:JLPhotoType){
        DispatchQueue.global().async {
            self.setupImageForScrollView(scrollView, asset, photoType)
        }
    }
    
    fileprivate func setupImageForScrollView(_ scrollView:JLScrollView,_ asset:ALAsset,_ photoType:JLPhotoType){
        var image:UIImage?
        
        switch photoType {
        case .AspectRatioThumbnail://缩略图
            image = UIImage(cgImage: asset.aspectRatioThumbnail().takeUnretainedValue())
        case .FullResolutionImage://原始图片
            image = UIImage(cgImage: asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue(), scale: CGFloat(asset.defaultRepresentation().scale()), orientation: UIImageOrientation(rawValue: asset.defaultRepresentation().orientation().rawValue)!)
        case .FullScreenImage://全屏图片
            image = UIImage(cgImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())

        }
        
        DispatchQueue.main.async {
            scrollView.image = image
        }
        
    }
}
extension JLAlbumBrowserViewController {
    fileprivate func refreshBadge(_ animation:Bool){
        self.badgeView.badgeCount = self.seleAssets.count;
        self.badgeView.setBadge(self.seleAssets.count, animation);
        self.completeItem.isEnabled = self.seleAssets.count != 0;
    }
}
//MARK:大的scrollViewDelegate
extension JLAlbumBrowserViewController:UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let direction = setupDriection(targetContentOffset.pointee)
        
        self.currentIndex = Int(targetContentOffset.pointee.x / UIScreen.main.bounds.width)
        self.title = "\(self.currentIndex + 1)/\(self.assets.count)"
        reuseScrollView(targetContentOffset.pointee, direction)
        
    }
    
    fileprivate func setupDriection(_ targetContentOffset:CGPoint)->JLDirection{
        let difference = targetContentOffset.x - UIScreen.main.bounds.width * CGFloat(self.currentIndex)
        var direction = JLDirection.none
        if difference > 0 {
            direction = JLDirection.right
        }else if difference < 0{
            direction = JLDirection.left
        }else{
            direction = JLDirection.none
        }
        
        return direction
    }
    
    fileprivate func reuseScrollView(_ targeContentOffset:CGPoint,_ direction:JLDirection){
        //没有滑动的时候时不需要刷新的
        if direction == .none {
            return
        }
        //更新按钮的状态
        let asset = self.assets[self.currentIndex];
        self.selectedBtn?.isSelected = asset.isSelected
        
        var resuseScrollView:JLScrollView? = nil
        if direction == .right {
            resuseScrollView = self.scrollViews[0];
            
            self.scrollViews.removeFirst()
            self.scrollViews.insert(resuseScrollView!, at: 2)
        }else{
            resuseScrollView = self.scrollViews[2];
            self.scrollViews.removeLast()
            self.scrollViews.insert(resuseScrollView!, at: 0)
        }
        //刷新中间的高清视图
        self.async_setupImageforScrollView(self.scrollViews[1], asset, photoType: .FullScreenImage)
        
        //设置退出屏幕的图片的缩放比例为1.0
        var pastScrollView:JLScrollView? = nil
        if direction == .right {
            pastScrollView = self.scrollViews[0]
        }else{
            pastScrollView = self.scrollViews[2]
        }
        pastScrollView?.zoomScale = 1.0
        
        //如果发现是第一张或者是最后一张旧不用刷新frame
        if self.currentIndex == 0 || self.currentIndex == self.assets.count - 1 {
            return
        }
        
        if direction == .right {
            resuseScrollView?.frame.origin.x = UIScreen.main.bounds.size.width * CGFloat(self.currentIndex + 1)
            
            //异步刷新图片
            self.async_setupImageforScrollView(resuseScrollView!, self.assets[self.currentIndex + 1], photoType: .AspectRatioThumbnail)
            
            self.async_setupImageforScrollView(self.scrollViews[0], self.assets[self.currentIndex - 1], photoType: .AspectRatioThumbnail)
        }else{
            resuseScrollView?.frame.origin.x = UIScreen.main.bounds.size.width * CGFloat(self.currentIndex - 1)
            
            //异步刷新图片
            self.async_setupImageforScrollView(resuseScrollView!, self.assets[self.currentIndex - 1], photoType: .AspectRatioThumbnail)
            
            self.async_setupImageforScrollView(self.scrollViews[2], self.assets[self.currentIndex + 1], photoType: .AspectRatioThumbnail)
        }
        
        self.bigScrollView.addSubview(resuseScrollView!)
        
    }
    
}

//MARK:按钮的点击事件
extension JLAlbumBrowserViewController{
    @objc fileprivate func clickSelectedBtn(_ btn:UIButton) {
        //1.先判断是否超过了9张图片
        if !btn.isSelected && (self.delegate?.checkSelectedCount())! {
            print("已经选择了9张图片");
            return;
        }
        
        btn.isSelected = !btn.isSelected
        let asset = self.assets[self.currentIndex]
        self.delegate?.refreshSelectedAssets(btn.isSelected, asset, true)
        self.refreshbadge(asset, true);

    }
    @objc fileprivate func clickCompleteItem() {
        self.delegate?.completeItemClick()
    }
    
    fileprivate func refreshbadge(_ asset:ALAsset,_ animataion:Bool) {
        var count = self.badgeView.badgeCount
        
        if asset.isSelected {
            count += 1;
        }else{
            count -= 1;
        }
        
        self.badgeView.badgeCount = count
        self.badgeView.setBadge(count, animataion);
        self.completeItem.isEnabled = count == 0 ? false : true;
    }
}
 
