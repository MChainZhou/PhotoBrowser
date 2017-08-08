//
//  JLAssetsGroup.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 apple. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import Photos

class JLAssetsLibrary: ALAssetsLibrary {
    
    static let shared = JLAssetsLibrary.init()
    
    private override init(){}

}

//MARK:检查相机的权限
extension JLAssetsLibrary {
    func checkAuthorizationStaus(callBack:@escaping (Bool)->Void) {
        
        checkAuthroizationStatus_BeforeiOS8(callBack: callBack);
        
    }
    
    
    fileprivate func checkAuthroizationStatus_BeforeiOS8(callBack:@escaping (Bool)->Void) {
        
        let status = ALAssetsLibrary.authorizationStatus()
        requestAuthorizationStatus_AfteriOS8(callBack: callBack)
        switch status {
        case ALAuthorizationStatus.notDetermined:
            
            break
        case ALAuthorizationStatus.restricted:
            callBack(false)
            break
        case ALAuthorizationStatus.denied:
            callBack(false)
            break
        case ALAuthorizationStatus.authorized:
            callBack(true)
            break
        }
        
    }
    
    fileprivate func requestAuthorizationStatus_AfteriOS8(callBack:@escaping (Bool)->Void) {
        
        
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async{
                switch status {
                case PHAuthorizationStatus.authorized:
                    callBack(true)
                    break
                default:
                    callBack(false)
                    break
                }
            }
        }
        
    }
}

//MARK:获取相机照片的分组
extension JLAssetsLibrary {
    //获取相册的分组
    func jl_enumeratePhotoGroup(_ callBack:@escaping ([JLAssetGroup])->Void,_ failure:@escaping (Error)->Void) {
        var groups = [JLAssetGroup]()
        JLAssetsLibrary.shared.enumerateGroups(withTypes: ALAssetsGroupType(ALAssetsGroupAll), using: { (group, stop) in
            if (group != nil) {
                let assetCount = group?.numberOfAssets()
                if assetCount! > 0 {
                    let assetGroup = JLAssetGroup()
                    assetGroup.group = group
                    assetGroup.groupName = group?.value(forProperty: "ALAssetsGroupPropertyName") as? String
                    let cgIamge = group?.posterImage().takeUnretainedValue()
                    assetGroup.posterImage = UIImage(cgImage: cgIamge!)
                    assetGroup.assetsCount = group?.numberOfAssets()
                    groups.append(assetGroup)
                }
            }else{
                callBack(groups)
            }
        }) { (error) in
            failure(error!)
        }
    }
    //获取相册的所有照片
    func jl_getCameraRollGroup(_ callBack:@escaping  (ALAssetsGroup)->Void,_ failure:@escaping (Error)->Void) {
        objc_sync_enter(self)
        enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { (group, stop) in
            if group != nil {
                let groupName = group?.value(forProperty: "ALAssetsGroupPropertyName") as! String
                if groupName == "Camera Roll" {
                    callBack(group!)
                }
            }
        }) { (error) in
            failure(error!)
        }
        objc_sync_exit(self)
    }
    //获取组下面的所有照片
    func jl_enumerateAssetsWithGroup(_ group:ALAssetsGroup,_ callBack:@escaping ([ALAsset])->Void) {
        objc_sync_enter(self)
        var assets = [ALAsset]()
        group.setAssetsFilter(ALAssetsFilter.allPhotos())
        
        group.enumerateAssets({ (result, index, stop) in
            if result != nil {
                result?.isSelected = false
                assets.append(result!)
            }else{
                callBack(assets)
            }
        })
        
        objc_sync_exit(self)
    }
}

//为ALAsset添加一个Bool属性:为了在浏览图片的时候选择或者取消选择图片的时候JLThumbnailViewController视图上的cell上徐泽按钮的变化
var isSelectedKey:String = "isSelectedKey"
extension ALAsset {
    var isSelected:Bool {
        get{
            return objc_getAssociatedObject(self, &isSelectedKey) as! Bool
        }
        set(newValue){
            objc_setAssociatedObject(self, &isSelectedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

