//
//  PhotoExtension.swift
//  PhotoBrowser-swift
//
//  Created by zhangwentong on 2017/5/30.
//  Copyright © 2017年 YiXue. All rights reserved.
//

import UIKit

extension UIImage {
    
    var frameWithScreenWidth: CGRect {
        
        let screenW = UIScreen.main.bounds.width
        
        let screenH = UIScreen.main.bounds.height
        
        
        let size = sizeWithScreenWidth;
        
        let x = (screenW - size.width) * 0.5
        let y = (screenH - size.height) * 0.5;
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
        
    }
    
    var sizeWithScreenWidth: CGSize {
        
        var width = size.width
        var height = size.height
        
        let screenW = UIScreen.main.bounds.width
        
        if (width > screenW) {
            
            width = screenW
            height = width * self.size.height / self.size.width;
            
        }
        
        return CGSize(width: width, height: height);
        
    }
    
    convenience init?(name: String) {
        
        var name = name
        if UIScreen.main.bounds.width == 414 {
            name += "@3x"
        }else {
            name += "@2x"
        }
        
        var resourceBundle: Bundle! = Bundle(for: WTPhoto.self)
        
        var resourcePath: String! = resourceBundle.path(forResource: "WTPhotoBrowser", ofType: "bundle")
        if resourcePath != nil  {
            resourceBundle = Bundle(path: resourcePath!)
        }
        
        resourcePath = resourceBundle.path(forResource: name, ofType: "png")
        
        self.init(contentsOfFile: resourcePath)
        
    }
    
   
}
