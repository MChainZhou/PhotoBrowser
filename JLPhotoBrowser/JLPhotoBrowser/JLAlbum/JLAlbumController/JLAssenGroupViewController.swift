//
//  JLAssenGroupViewController.swift
//  JLPhotoBrowser
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class JLAssenGroupViewController: UIViewController {
    
    fileprivate var groups:[JLAssetGroup] = [JLAssetGroup]()

    fileprivate lazy var tableView:UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        
        setupUI()
        
        setupData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
        
    }
}

//MARK:UITableViewDelegate,UITableViewDataSource
extension JLAssenGroupViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        }
        let assertGroup = self.groups[indexPath.row]
        
        
        cell?.imageView?.image = assertGroup.posterImage
        cell?.textLabel?.text = assertGroup.groupName
        cell?.accessoryType = .disclosureIndicator
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let thumVc = JLThumbnailViewController()
        let assertGroup = self.groups[indexPath.row]
        thumVc.group = assertGroup.group
        self.navigationController?.pushViewController(thumVc, animated: true)
    }
}

//MARK:添加UI
extension JLAssenGroupViewController {
    fileprivate func setupNav() {
        let leftItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftItem
        
    }
    
    fileprivate func setupUI() {
        self.view.addSubview(self.tableView)
    }
    
    @objc func back (){
        self.navigationController?.dismiss(animated: true, completion: nil);
    }
    
    
    fileprivate func setupData() {
        var groups = [JLAssetGroup]()
        JLAssetsLibrary.shared.jl_enumeratePhotoGroup({ [weak self] (assertGroups) in
            groups = assertGroups
            self?.groups = groups
            self?.tableView.reloadData()
            
            }, { (error) in
                
        })
    }

}

