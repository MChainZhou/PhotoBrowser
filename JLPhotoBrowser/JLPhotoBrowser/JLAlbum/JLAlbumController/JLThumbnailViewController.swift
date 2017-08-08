//
//  JLThumbnailViewController.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import AssetsLibrary

let kCellMargin:CGFloat = 1
let kColumn:CGFloat = 4

let thumbCellID = "JLAlbumCollectionViewCell"
let tintColor = UIColor(red: 82.0/255.0, green: 82.0/255.0, blue: 82.0/255.0, alpha: 1.0)



class JLThumbnailViewController: UIViewController {

    var returnDelegate:JLReturnImageProtocol? = nil
    var group:ALAssetsGroup?
    var assetsArray = [ALAsset]()
    var selectAssets = [ALAsset]()
    
    ///完成按钮
    fileprivate lazy var completeItem:UIBarButtonItem = {
        let completeItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(clickCompleteItem))
        completeItem.isEnabled = false
        completeItem.tintColor = UIColor(red: 253/255.0, green: 130/255.0, blue: 36/255.0, alpha: 1.0)
        return completeItem
    }()
    ///预览按钮
    fileprivate lazy var previewItem:UIBarButtonItem = {
        let previewItem = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(clickPreviewItem))
        previewItem.isEnabled = false
        previewItem.tintColor = UIColor(red: 253/255.0, green: 130/255.0, blue: 36/255.0, alpha: 1.0)
        return previewItem
    }()
    ///徽章试图
    fileprivate lazy var badgeView:JLBadgeView = {
        let badgeView = JLBadgeView.badgeView();
        
        return badgeView
    }()
    
    
    
    
    fileprivate lazy var collectionView:UICollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1;
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 2*kCellMargin - kCellMargin*(kColumn - 1))/kColumn, height: (UIScreen.main.bounds.size.width - 2*kCellMargin - kCellMargin*(kColumn - 1))/kColumn)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 44), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "JLAlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: thumbCellID)

        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        
        setupUI()
        
        setupData()
        
        setupToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = false
    }
    
}

//MARK:按钮的点击
extension JLThumbnailViewController {
    @objc fileprivate func clickCompleteItem() {
        if self.returnDelegate != nil {
            self.returnDelegate?.returnImageDatas(self.selectAssets)
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func clickPreviewItem() {
        let browser = JLAlbumBrowserViewController()
        browser.seleAssets = selectAssets
        browser.assets = selectAssets
        browser.delegate = self
        self.navigationController?.pushViewController(browser, animated: true)
        
    }
}




extension JLThumbnailViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: thumbCellID, for: indexPath) as! JLAlbumCollectionViewCell
        cell.delegate = self
        cell.asset = self.assetsArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = JLAlbumBrowserViewController()
        browser.seleAssets = selectAssets
        browser.assets = self.assetsArray
        browser.currentIndex = indexPath.item
        browser.delegate = self
        self.navigationController?.pushViewController(browser, animated: true)
    }

}

//MARK:JLAlbumCollectionViewCellDelegate
extension JLThumbnailViewController:JLSelectedPhotoProtocol {
    func checkSelectedCount() -> Bool {
        return self.assetsArray.count == 9 ? true : false
    }
    
    func refreshSelectedAssets(_ isAdd: Bool, _ asset: ALAsset, _ refresh: Bool) {
        if isAdd {
            self.selectAssets.append(asset)
        }else{
            self.selectAssets.remove(at: self.selectAssets.index(of: asset)!)
        }
        asset.isSelected = isAdd
        self.badgeView.setBadge(self.selectAssets.count, true)
        self.completeItem.isEnabled = self.selectAssets.count != 0
        self.previewItem.isEnabled = self.selectAssets.count != 0
        if refresh {
            self.collectionView.reloadData()
        }
    }
    //点击完成按钮
    func completeItemClick() {
        self.clickCompleteItem()
    }
}

//MARK:处理UI
extension JLThumbnailViewController{
    fileprivate func setupNav() {
        let rightItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = rightItem;
        
        self.navigationController?.navigationBar.tintColor = tintColor;
        self.navigationController?.toolbar.barTintColor = UIColor.white
    }
    
    fileprivate func setupUI() {
        self.view.addSubview(self.collectionView)
    }
    
    @objc fileprivate func cancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupData(){
        if self.group == nil {
            JLAssetsLibrary.shared.jl_getCameraRollGroup({ (group) in
                self.group = group;
                self.title = group.value(forProperty: "ALAssetsGroupPropertyName") as? String
                self.loadAsset();
            }, { (error) in
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        }else{
            loadAsset();
        }
        
    }
    
    fileprivate func loadAsset(){
        JLAssetsLibrary.shared.jl_enumerateAssetsWithGroup(self.group!) { (assets) in
            self.assetsArray = assets;
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func setupToolBar() {
        self.navigationController?.isToolbarHidden = false;
        
        let tooFlexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        
        let toofixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
        
        toofixedItem.width -= 5;
        let badgeItem = UIBarButtonItem(customView: self.badgeView);
        
        self.toolbarItems = [self.previewItem,tooFlexibleItem,badgeItem,toofixedItem,self.completeItem]
        
        
    }
}
