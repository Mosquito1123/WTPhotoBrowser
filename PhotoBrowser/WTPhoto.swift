//
//  Photo.swift
//  PhotoBrowser-swift
//
//  Created by zhangwentong on 2017/5/30.
//  Copyright © 2017年 YiXue. All rights reserved.
//

import UIKit

public class WTPhoto {
    
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage?
    
    public init() {
        
    }
    
    public init(url: URL?) {
        
        self.url = url
        
    }
    
    public init(urlString: String?) {
        if let urlString = urlString {
            self.url = URL(string: urlString)
        }
        
    }
    
    public init(image: UIImage?) {
        
        self.image = image
        
    }

}
