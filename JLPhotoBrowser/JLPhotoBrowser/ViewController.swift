//
//  ViewController.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/4/26.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK:懒加载
    fileprivate lazy var tableView:UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI();
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        if indexPath.row == 0 {
            cell?.textLabel?.text = "从网络上读取图片"
        }else{
            cell?.textLabel?.text = "从本地相册读取图片"
        }
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let networkingVC = JLNetworkViewController()
            
            self.navigationController?.pushViewController(networkingVC, animated: true)
        }else{
            
            let albumVC = JLAlbumViewController()
            
            self.navigationController?.pushViewController(albumVC, animated: true)
            
        }
    }
}

extension ViewController {
    fileprivate func setupUI() {
        self.view.addSubview(self.tableView);

        }
}

