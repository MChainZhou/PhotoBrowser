//
//  JLNavigetionController.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class JLNavigetionController: UINavigationController {
    
    var returnDelegate:JLReturnImageProtocol? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
}

//MARK:公开的方法
extension JLNavigetionController {
    class func navigationAlbumControllerWithProtocol(_ delegate:JLReturnImageProtocol) -> JLNavigetionController {
        let groupVC = JLAssenGroupViewController()
        let thumVC = JLThumbnailViewController()
        
        let naVC = JLNavigetionController(rootViewController: groupVC)
        thumVC.returnDelegate = naVC
        naVC.returnDelegate = delegate
        naVC.pushViewController(thumVC, animated: true)
        
        return naVC
    }
}


//MARK:JLReturnImageProtocol代理方法
extension JLNavigetionController:JLReturnImageProtocol {
    func returnImageDatas(_ imageDatas:[ALAsset]){
        if self.returnDelegate != nil {
            self.returnDelegate?.returnImageDatas(imageDatas)
        }
    }
}



