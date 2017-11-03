//
//  ERAStylesViewController.swift
//  ResetERA_Mobile
//
//  Created by Christian Weber on 02.11.17.
//  Copyright © 2017 CW-Internetdienste. All rights reserved.
//

import UIKit

class ERAStylesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var installedStyles     :   [ERAStyle] {
        get {
            return stylesManager.getInstalledStyles()
        }
    }
    var uninstalledStyles   :   [ERAStyle]  {
        get {
            return stylesManager.getUninstalledStyles()
        }
    }
    var availableStyles     :   [ERAStyle]  {
        get {
            return stylesManager.getAvailableStyles()
        }
    }
    
    
    @IBOutlet weak var stylesTable : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupTableView()
        self.loadResetERAStyles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupNavigationBar() -> Void {
        self.navigationItem.title               =   "ResetERA Styles Manager"
        self.navigationItem.hidesBackButton     =   true
        
        let closeButton :   UIBarButtonItem     =   UIBarButtonItem(title: "X", style: .done, target: self, action: #selector(ERAStylesViewController.dismissView))
        closeButton.tintColor                   =   PURPLE_COLOR
        self.navigationItem.leftBarButtonItem   =   closeButton
        
        let editButton  :   UIBarButtonItem     =   UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ERAStylesViewController.switchEditMode))
        editButton.tintColor                    =   PURPLE_COLOR
        self.navigationItem.rightBarButtonItem  =   editButton
    }
    
    func loadResetERAStyles() -> Void {
        stylesManager.loadAvailableStyles() { () in
            print("did load")
            self.stylesTable.reloadData()
        }
    }
    
    func forceBrowserReload() -> Void {
       stylesManager.forceReload    =   true
    }
    
    func setupTableView() -> Void {
        self.stylesTable.delegate   =   self
        self.stylesTable.dataSource =   self
        
        self.stylesTable.allowsMultipleSelection                =   false
        self.stylesTable.allowsMultipleSelectionDuringEditing   =   false
        self.stylesTable.allowsSelection                        =   false
        self.stylesTable.allowsSelectionDuringEditing           =   false
        self.stylesTable.dragInteractionEnabled                 =   true
    }
    
    @objc func dismissView() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func switchEditMode() -> Void {
        self.stylesTable.setEditing(!self.stylesTable.isEditing, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        switch(indexPath.section) {
        case 0:
            return getInstalledEditActions(indexPath)
        case 1:
            return getUninstalledEditActions(indexPath)
        case 2:
            return getAvailableEditActions(indexPath)
        default:
            return nil
        }
    }
    
    func getInstalledEditActions(_ indexPath : IndexPath) -> [UITableViewRowAction]? {
        let uninstall :   UITableViewRowAction    =   UITableViewRowAction(style: .default, title: "Uninstall") { (action, indexPath) in
            print("Uninstall")
            self.installedStyles[indexPath.row].uninstall() { (success : Bool) in
                if(success == true) {
                    self.forceBrowserReload()
                    self.stylesTable.reloadData()
                    //self.stylesTable.reloadSections(IndexSet([0,1]), with: UITableViewRowAnimation.none)
                } else {
                    print("Error: Unable to uninstall theme")
                }
            }
        }
        
        uninstall.backgroundColor   =   PURPLE_COLOR
        
        let uninstallAndRemove  :   UITableViewRowAction    =   UITableViewRowAction(style: .normal, title: "Uninstall and delete") { (action, indexPath) in
            print("Uninstall and delete")
            self.installedStyles[indexPath.row].uninstall(true) { (success : Bool) in
                if(success == true) {
                    self.forceBrowserReload()
                    self.stylesTable.reloadData()
                    //self.stylesTable.reloadSections(IndexSet([0,2]), with: UITableViewRowAnimation.none)
                } else {
                    print("Error: Unable to install theme")
                }
            }
        }
        uninstallAndRemove.backgroundColor  =   UIColor.red
        
        return [uninstall, uninstallAndRemove]
    }
    
    func getUninstalledEditActions(_ indexPath : IndexPath) -> [UITableViewRowAction]? {
        let install :   UITableViewRowAction    =   UITableViewRowAction(style: .default, title: "Install") { (action, indexPath) in
            print("Install")
            self.uninstalledStyles[indexPath.row].install() { (success : Bool) in
                if(success == true) {
                    self.forceBrowserReload()
                    self.stylesTable.reloadData()
                    //self.stylesTable.reloadSections(IndexSet([0,1]), with: UITableViewRowAnimation.none)
                } else {
                    print("Error: Unable to install theme")
                }
            }
        }
        
        install.backgroundColor =   UIColor.green
        
        let delete  :   UITableViewRowAction    =   UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            print("Delete")
            self.uninstalledStyles[indexPath.row].delete() { (success : Bool) in
                if(success == true) {
                    self.stylesTable.reloadData()
                    //self.stylesTable.reloadSections(IndexSet([1,2]), with: UITableViewRowAnimation.none)
                } else {
                    print("Error: Unable to delete theme")
                }
            }
        }
        delete.backgroundColor  =   UIColor.red
        
        return [install, delete]
    }
    
    func getAvailableEditActions(_ indexPath : IndexPath) -> [UITableViewRowAction]? {
        let download :   UITableViewRowAction    =   UITableViewRowAction(style: .default, title: "Download") { (action, indexPath) in
            print("Download")
            self.availableStyles[indexPath.row].download() { (success : Bool) in
                if(success == true) {
                    self.stylesTable.reloadData()
                    //self.stylesTable.reloadSections(IndexSet([1,2]), with: UITableViewRowAnimation.none)
                } else {
                    print("Error: Unable to donwload theme")
                }
            }
        }
        
        download.backgroundColor    =   PURPLE_COLOR
        
        let downloadAndInstall  :   UITableViewRowAction    =   UITableViewRowAction(style: .normal, title: "Download and install") { (action, indexPath) in
            print("Download and install")
            self.availableStyles[indexPath.row].download(true) { (success : Bool) in
                if(success == true) {
                    self.forceBrowserReload()
                    self.stylesTable.reloadData()
                    //self.stylesTable.reloadSections(IndexSet([0,2]), with: UITableViewRowAnimation.none)
                } else {
                    print("Error: Unable to download and install theme")
                }
            }
        }
        
        downloadAndInstall.backgroundColor  =   UIColor.green
        
        return [download, downloadAndInstall]
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor                      = UIColor.white
        let header                          = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor         = UIColor.white
        header.contentView.backgroundColor  = PURPLE_COLOR
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch(indexPath.section) {
        case 0:
            return (self.installedStyles.count > 0)
        case 1:
            return (self.uninstalledStyles.count > 0)
        case 2:
            return (self.availableStyles.count > 0)
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "Installed"
        case 1:
            return "Uninstalled"
        case 2:
            return "Available"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell!
        if let _tvc : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = _tvc
        } else {
            cell     =   UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        switch (indexPath.section) {
        case 0:
            return self.getInstalledCell(cell, indexPath)
        case 1:
            return self.getUninstalledCell(cell,indexPath)
        case 2:
            return self.getAvailableCell(cell,indexPath)
        default:
            return cell
        }
    }
    
    func getInstalledCell(_ cell : UITableViewCell, _ indexPath : IndexPath) -> UITableViewCell {
        if(self.installedStyles.count == 0) {
            cell.textLabel?.text        =   "Currently no styles installed"
            cell.detailTextLabel?.text  =   nil
        } else {
            cell.textLabel?.text        =   "\(self.installedStyles[indexPath.row].name) by \(self.installedStyles[indexPath.row].author)"
            cell.detailTextLabel?.text  =   "Installed"
        }
        return cell
    }
    
    func getUninstalledCell(_ cell : UITableViewCell,_ indexPath : IndexPath) -> UITableViewCell {
        if(self.uninstalledStyles.count == 0) {
            cell.textLabel?.text        =   "Currently no styles uninstalled"
            cell.detailTextLabel?.text  =   nil
        } else {
            cell.textLabel?.text        =   "\(self.uninstalledStyles[indexPath.row].name) by \(self.uninstalledStyles[indexPath.row].author)"
            cell.detailTextLabel?.text  =   "Uninstalled"
        }
        return cell
    }
    
    func getAvailableCell(_ cell : UITableViewCell,_ indexPath : IndexPath) -> UITableViewCell {
        if(self.availableStyles.count == 0) {
            cell.textLabel?.text        =   "Currently no styles available"
            cell.detailTextLabel?.text  =   nil
        } else {
            cell.textLabel?.text        =   "\(self.availableStyles[indexPath.row].name) by \(self.availableStyles[indexPath.row].author)"
            cell.detailTextLabel?.text  =   "Last update \(self.availableStyles[indexPath.row].updated_ago) ago"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return (self.installedStyles.count > 0)     ? self.installedStyles.count    : 1
        case 1:
            return (self.uninstalledStyles.count > 0)   ? self.uninstalledStyles.count  : 1
        case 2:
            return (self.availableStyles.count > 0)     ? self.availableStyles.count    : 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 0 && self.installedStyles.count > 0)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
}
