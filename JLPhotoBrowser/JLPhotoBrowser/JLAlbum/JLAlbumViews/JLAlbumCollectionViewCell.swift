//
//  JLAlbumCollectionViewCell.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import AssetsLibrary



class JLAlbumCollectionViewCell: UICollectionViewCell {

    var delegate:JLSelectedPhotoProtocol?
    
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var asset:ALAsset?{
        didSet{
            self.imageView.image = UIImage(cgImage: (asset?.thumbnail().takeUnretainedValue())!)
            self.selectedBtn.isSelected = (asset?.isSelected)!
        }
    }
    @IBAction func clickSelectBtn(_ sender: UIButton) {
        if self.delegate != nil  && !sender.isSelected {
            if ((self.delegate?.checkSelectedCount())!) {return}
        }
        sender.isSelected = !sender.isSelected
//        self.asset?.isSelected = sender.isSelected
        
        if sender.isSelected {
            sender.startkeyFramesAnimation()
        }
        
        self.delegate?.refreshSelectedAssets(sender.isSelected, self.asset!, false)
    }
    
}
