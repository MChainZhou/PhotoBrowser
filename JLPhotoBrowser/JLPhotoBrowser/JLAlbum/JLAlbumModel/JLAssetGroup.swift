//
//  JLAssetGroup.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class JLAssetGroup: NSObject {
    //组名
    var groupName:String?
    //封面
    var posterImage:UIImage?
    //组里面的图片个数
    var assetsCount:Int?
    //类型
    var type:String?
    //组
    var group:ALAssetsGroup?

}
