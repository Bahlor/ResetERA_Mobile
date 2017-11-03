//
//  StringExtension.swift
//  ResetERA_Mobile
//
//  Created by Christian Weber on 02.11.17.
//  Copyright © 2017 CW-Internetdienste. All rights reserved.
//

extension String {
    var length:Int {
        return self.length
    }
    
    func indexOf(target: String) -> Index? {
        
        let range = self.range(of: target)
        
        guard range != nil else {
            return nil
        }
        
        return range?.upperBound
        
    }
    func lastIndexOf(target: String) -> Index? {
        
        
        
        let range = self.range(of: target, options: String.CompareOptions.backwards)
        
        guard range != nil else {
            return nil
        }
        
        return range?.lowerBound
        
    }
    func contains(s: String) -> Bool {
        return (self.range(of: s) != nil) ? true : false
    }
}
