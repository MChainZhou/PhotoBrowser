//
//  JLAlbumViewController.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/27.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class JLAlbumViewController: UIViewController {

    @IBOutlet weak var showView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    
    @IBAction func clickBtn(_ sender: Any) {
        
        JLAssetsLibrary.shared.checkAuthorizationStaus { (resurt) in
            if resurt {
                let naVC = JLNavigetionController.navigationAlbumControllerWithProtocol(self as JLReturnImageProtocol)
                self.navigationController?.present(naVC, animated: true, completion: nil)
            }else {
                let alertView = UIAlertController(title: "提示", message: "未能取得相册访问权限", preferredStyle: .alert)
                let action = UIAlertAction(title: "我知道了", style: .cancel, handler:nil)
                alertView.addAction(action)
                
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }

    
}

extension JLAlbumViewController: JLReturnImageProtocol {
    func returnImageDatas(_ imageDatas: [ALAsset]) {
        showImages(imageDatas)
    }
    
    fileprivate func showImages(_ imageDatas:[ALAsset]) {
        for imageView in self.showView.subviews {
            imageView.removeFromSuperview()
        }
        
        
        let imageWH:CGFloat = 80
        let imageMargin:CGFloat = 5
        
        
        for asset in imageDatas {
            let index = imageDatas.index(of: asset)
            
            let imageView = UIImageView()
            
            //行数
            let row = index! / 3;
            //列数
            let column = index! % 3;
            imageView.frame = CGRect(x: CGFloat(column) * (imageWH + imageMargin), y: CGFloat(row) * (imageMargin + imageWH), width: imageWH, height: imageWH);
            imageView.image = UIImage(cgImage: asset.thumbnail().takeUnretainedValue())
            
            self.showView.addSubview(imageView);
            
        }
    }
}
