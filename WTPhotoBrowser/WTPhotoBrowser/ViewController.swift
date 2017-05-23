//
//  ViewController.swift
//  WTPhotoBrowser
//
//  Created by Yixue_ZhangWentong on 2017/5/23.
//  Copyright © 2017年 Yixue_ZhangWentong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let pb = WTPhotoBrowser(photos: [], currentIndex: 0)
        pb.indicatorStyle = .pageControl
        //        pb.indicatorPosition = .top
        //        let pb = PhotoBrowser(photos: photos, currentIndex: 0)
        
        present(pb, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

