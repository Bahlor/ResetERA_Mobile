//
//  StylesManager.swift
//  ResetERA_Mobile
//
//  Created by Christian Weber on 28.10.17.
//  Copyright © 2017 CW-Internetdienste. All rights reserved.
//

import Foundation

//{
//    "url": "https://userstyles.org/styles/150164/resetera-dark-theme",√
//    "name": "Resetera Dark Theme",√
//    "description": "A comfy dark theme, WIP!",√
//    "author": "Remy Perona",√
//    "created": "2017-10-26T00:08:45.000Z",√
//    "created_ago": "8 days",
//    "updated": "2017-10-30T00:14:57.000Z",√
//    "updated_ago": "4 days",
//    "category": "site",√
//    "subcategory": "resetera",√
//    "weekly_installs": 2180,
//    "total_installs": 3510,
//    "rating": "none",√
//    "screenshot": null,
//    "license": "http://creativecommons.org/licenses/by-nc/3.0/"
//}

class ERAStyle : Codable {
    let url         :   URL
    let name        :   String
    let description :   String
    let author      :   String
    let category    :   String
    let subcategory :   String?
    let license     :   String?
    let rating      :   String
    
    //let created     :   Date
    let created_ago :   String
    //let updated     :   Date
    let updated_ago :   String
    
    var finalURL   :   URL?   {
        return URL(string: "\(self.url).css")
    }
    
    var _fileName : String?
    var fileName : String {
        get {
            if let _f : String = self._fileName {
                return _f
            }
            
            let comps  :   [String]  =   self.url.pathComponents
            let id     :   String    =  comps[comps.count - 2].trimmingCharacters(in: .illegalCharacters).trimmingCharacters(in: .whitespacesAndNewlines)
            
            self._fileName  =   "\(self.url.lastPathComponent)_\(id).css"
            
            return self._fileName!
        }
    }
    
    public func isInstalled() -> Bool {
        return stylesManager.checkInstalledFile(fileName: self.fileName)
    }
    
    public func isDownloaded() -> Bool {
        return stylesManager.checkDownloadedFile(fileName: self.fileName)
    }
    
    /* shorthand functions */
    public func download(_ install : Bool = false, closure : @escaping (_ success : Bool) -> Void) -> Void {
        stylesManager.download(style: self,install, closure: closure)
    }
    
    public func uninstall(_ remove : Bool = false, closure : (_ success : Bool) -> Void) -> Void {
        stylesManager.uninstall(style: self,remove, closure: closure)
    }
    
    public func delete(closure : (_ success : Bool) -> Void) -> Void {
        stylesManager.delete(style: self,closure: closure)
    }
    
    public func install(closure : (_ success : Bool) -> Void) -> Void {
        stylesManager.install(style: self,closure: closure)
    }

}

class ERAStylesManager {
    static let instance     :   ERAStylesManager    =   ERAStylesManager()
    
    // folders
    var documentFolder      :   URL!
    var downloadFolder      :   URL!
    var installFolder       :   URL!
    
    var installedStyles     :   [ERAStyle]  =   []
    var uninstalledStyles   :   [ERAStyle]  =   []
    var availableStyles     :   [ERAStyle]  =   []
    
    var forceReload         :   Bool        =   false
    
    var cachedCSS           :   String      =   ""
    
    init() {
        self.getOrCreateStylesFolder()
        self.loadAvailableStyles() {() in
            print("loaded")
        }
    }
    
    private func getOrCreateStylesFolder() -> Void {
        guard let docFolder     :   URL     =   fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return; }
        let downloadFolder      :   URL     =   docFolder.appendingPathComponent(DOWNLOAD_FOLDER, isDirectory: true)
        let installFolder       :   URL     =   docFolder.appendingPathComponent(INSTALLED_FOLDER, isDirectory: true)
        
        if(!fm.fileExists(atPath: downloadFolder.path)) {
            do {
                try fm.createDirectory(at: downloadFolder, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        if(!fm.fileExists(atPath: installFolder.path)) {
            do {
                try fm.createDirectory(at: installFolder, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        self.documentFolder =   docFolder
        self.downloadFolder =   downloadFolder
        self.installFolder  =   installFolder
    }
    
    public func checkInstalledFile(fileName : String) -> Bool {
        return fm.fileExists(atPath: (URL(string: fileName, relativeTo: self.installFolder)?.path)!)
    }
    
    public func checkDownloadedFile(fileName : String) -> Bool {
        return fm.fileExists(atPath: (URL(string: fileName, relativeTo: self.downloadFolder)?.path)!)
    }
    
    private func generateFinalCSS() -> Void {
        var css : String = "var style = document.createElement('style');"
        // add stylesheets of themes
        for _style in self.installedStyles {
            do {
                if let url : URL    =   URL(string: _style.fileName, relativeTo: self.installFolder) {
                    var cssContent  =   try String(contentsOfFile: url.path, encoding: .utf8)
                    cssContent      =   cssContent.substring(from: cssContent.indexOf(target: "{")!)
                    cssContent      =   cssContent.substring(to: cssContent.lastIndexOf(target: "}")!)
                    
                    css     +=  self.preprocessCSS(src: cssContent)
                } else {
                    print("unable to get path for \(_style.name)")
                }
            } catch {
                print("unable to get css for \(_style.name)")
            }
        }
        // add our additional custom css
        guard let path = Bundle.main.path(forResource: "additions", ofType: "css") else { return }
        do {
            let cssContent = try String(contentsOfFile: path, encoding: .utf8)
            css     +=  self.preprocessCSS(src: cssContent)
        } catch {
            print("unable to get css")
        }
        
        css     +=  "document.head.appendChild(style);"
        
        self.cachedCSS   =   css
    }
    
    private func preprocessCSS(src : String) -> String {
        let javaScrStr = " style.innerHTML += '%@'; "
        var jsString = String(format: javaScrStr, src.replacingOccurrences(of: "'", with: "\\'"))
        jsString = jsString.replacingOccurrences(of: "\n", with: "")
        jsString = jsString.replacingOccurrences(of: "\r", with: "")
        jsString = jsString.replacingOccurrences(of: "\\\"", with: "\"")
        jsString = jsString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return jsString
    }
    
    public func getCSS() -> String {
        if(self.cachedCSS.isEmpty == true) {
            print("generate cached css")
            self.generateFinalCSS()
        }
        return self.cachedCSS
    }
    
    public func loadAvailableStyles( closure: @escaping () -> Void) -> Void {
        guard let overviewURL : URL     =   URL(string:"browse/resetera.json",relativeTo:API_PATH_URL) else {
            print("ERROR: INVALID OVERVIEW URL")
            return
        }
        urlSession.dataTask(with: overviewURL) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else {
                print("no data found")
                return
            }
            
            do {
                let stylesData  =   try JSONDecoder().decode([ERAStyle].self, from: data)
                
                DispatchQueue.main.async {
                    self.availableStyles    =   stylesData
                    self.processStyles()
                    closure()
                }
                
            } catch let jsonError {
                print("jsonError \(jsonError)")
            }
            
        }.resume()
    }
    
    public func processStyles() -> Void {
        self.installedStyles    =   []
        self.uninstalledStyles  =   []
        
        for _style in self.availableStyles {
            let downloaded  :   Bool    =   _style.isDownloaded()
            if(downloaded == true) {
                self.uninstalledStyles.append(_style)
            } else {
                let installed   :   Bool    =   _style.isInstalled()
                if(installed == true) {
                    self.installedStyles.append(_style)
                }
            }
        }
    }
    
    public func getInstalledStyles() -> [ERAStyle] {
        return self.installedStyles
    }
    
    public func getUninstalledStyles() -> [ERAStyle] {
        return self.uninstalledStyles
    }
    
    public func getAvailableStyles() -> [ERAStyle] {
        return self.availableStyles
    }
    
    public func download(style : ERAStyle, _ install : Bool = false, closure : @escaping (_ success : Bool) -> Void) -> Void {
        guard let fileURL   :   URL     =   style.finalURL else {
            print("No valid file url found")
            return
        }
        
        print(fileURL)
        print(fileURL.absoluteString)
        
        if(style.isDownloaded() || style.isInstalled()) {
            print("downloaded \(style.isDownloaded())")
            print("installed \(style.isInstalled())")
            closure(false)
            return
        }
        
        urlSession.downloadTask(with: fileURL) { (url, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let url = url else {
                print("ERROR: not temp url found")
                DispatchQueue.main.async {
                    closure(false)
                }
                return
            }
            
            let folder          :   URL =   (install == true) ? self.installFolder : self.downloadFolder
            guard let toFolder  :   URL =   URL(string: style.fileName, relativeTo: folder) else {
                print("ERROR: unable to get download folder url")
                DispatchQueue.main.async {
                    closure(false)
                }
                return
            }
            
            do {
                
                try fm.moveItem(at: url, to: toFolder)
                if(install == true) {
                    self.installedStyles.append(style)
                } else {
                    self.uninstalledStyles.append(style)
                }
                self.cachedCSS  =   ""
                DispatchQueue.main.async {
                    closure(true)
                }
                return
            } catch (let error) {
                print("Error while moving file: \(error)")
            }
            DispatchQueue.main.async {
                closure(false)
            }
        }.resume()
    }
    
    public func uninstall(style : ERAStyle, _ remove : Bool = false, closure : (_ success : Bool) -> Void) -> Void {
        if(!style.isInstalled()) {
            closure(false)
            return
        }
        
        if(remove) {
            self.delete(style: style, closure: closure)
        } else {
            guard let fromURL   :   URL     =   URL(string: style.fileName, relativeTo: self.installFolder) else {
                print("no valid file name in install folder")
                closure(false)
                return
            }
            guard let toURL     :   URL     =   URL(string: style.fileName, relativeTo: self.downloadFolder) else {
                print("no valid file name in download folder")
                closure(false)
                return
            }
            
            do {
                try fm.moveItem(at: fromURL, to: toURL)
                if let i = self.installedStyles.index(where: { (_s) -> Bool in
                    return (_s === style)
                }) {
                    self.installedStyles.remove(at: i)
                }
                self.uninstalledStyles.append(style)
                self.cachedCSS  =   ""
                closure(true)
                return
            } catch (let error) {
                print("Error while moving file: \(error)")
            }
            
            closure(false)
        }
    }
    
    public func delete(style : ERAStyle, closure : (_ success : Bool) -> Void) -> Void {
        if(!style.isDownloaded() && !style.isInstalled()) {
            print("downloaded \(style.isDownloaded())")
            print("installed \(style.isInstalled())")
            closure(false)
            return
        }
        
        let installed : Bool = style.isInstalled()
        
        guard let fileURL   :   URL     =   URL(string: style.fileName, relativeTo: ((installed) ? self.installFolder : self.downloadFolder)) else {
            print("Invalid file folder for deletion process")
            closure(false)
            return
        }
        
        if(!fm.isDeletableFile(atPath: fileURL.path)) {
            print("File is not deletable")
            closure(false)
            return
        }
        
        do {
            try fm.removeItem(at: fileURL)
            if(installed) {
                if let i = self.installedStyles.index(where: { (_s) -> Bool in
                    return (_s === style)
                }) {
                    self.installedStyles.remove(at: i)
                }
            } else {
                if let i = self.uninstalledStyles.index(where: { (_s) -> Bool in
                    return (_s === style)
                }) {
                    self.uninstalledStyles.remove(at: i)
                }
            }
            self.cachedCSS  =   ""
            closure(true)
            return
        } catch (let error) {
            print("Unable to delete file: \(error)")
        }
        
        closure(false)
    }
    
    public func install(style : ERAStyle, closure : (_ success : Bool) -> Void) -> Void {
        if(!style.isDownloaded()) {
            closure(false)
            return
        }
        
        guard let fromURL   :   URL     =   URL(string: style.fileName, relativeTo: self.downloadFolder) else {
            print("Unable to get file url in download folder")
            closure(false)
            return
        }
        
        guard let toURL   :   URL     =   URL(string: style.fileName, relativeTo: self.installFolder) else {
            print("Unable to get file url in install folder")
            closure(false)
            return
        }
        
        do {
            try fm.moveItem(at: fromURL, to: toURL)
            if let i = self.uninstalledStyles.index(where: { (_s) -> Bool in
                return (_s === style)
            }) {
                self.uninstalledStyles.remove(at: i)
            }
            self.installedStyles.append(style)
            self.cachedCSS  =   ""
            closure(true)
            return
        } catch (let error) {
            print("Unable to install file: \(error)")
        }
        
        closure(false)
    }
}
