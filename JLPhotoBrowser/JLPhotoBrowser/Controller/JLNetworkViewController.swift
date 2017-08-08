//
//  JLNetworkViewController.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/27.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class JLNetworkViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI();
    }
}

extension JLNetworkViewController {
    fileprivate func setupUI(){
        view.backgroundColor = UIColor.white;
        
        let imageListView = JLImageListView(frame: CGRect(x: (view.bounds.width - 250)/2.0, y: 64+50, width: 250, height: 250))
        imageListView.backgroundColor = UIColor.red
        
        view.addSubview(imageListView);
    }
    
}
