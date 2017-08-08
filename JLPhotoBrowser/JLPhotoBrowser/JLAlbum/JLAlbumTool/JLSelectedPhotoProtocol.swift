//
//  JLSelectedPhotoProtocol.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

import Foundation
import AssetsLibrary

protocol JLSelectedPhotoProtocol:NSObjectProtocol {
    //检查选择图片是否超过了9张
    func checkSelectedCount() -> Bool
    //刷新按钮状态
    func refreshSelectedAssets(_ isAdd:Bool,_ asset:ALAsset, _ refresh:Bool);
    //完成按钮点击
    func completeItemClick()
}

